import Combine
import Foundation
import SwiftUI

struct SCPZoneSection: Identifiable {
    let zone: SCPZone
    let objects: [SCPObject]

    var id: SCPZone { zone }
}

final class SCPStore: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedContainment: SCPContainmentClass?
    @Published var selectedZone: SCPZone?
    @Published var appearance: AppAppearance
    @Published private(set) var objects: [SCPObject]
    @Published private(set) var favorites: Set<String>
    @Published private(set) var isRefreshingRemoteCatalog: Bool = false
    @Published private(set) var onlineCatalogStatus: String = "Онлайн-каталог не загружен."
    @Published private(set) var lastRemoteSyncDate: Date?
    @Published private(set) var onlineCatalogCount: Int = 0

    private let defaults: UserDefaults
    private let favoritesKey = "scp_favorites_v1"
    private let appearanceKey = "scp_appearance_v1"
    private static let remoteIndexURL = URL(string: "https://scp-data.tedivm.com/data/scp/items/index.json")!
    private static let remoteCacheFile = "scp_remote_index.json"

    init(
        objects: [SCPObject] = SCPRepository.sampleObjects,
        defaults: UserDefaults = .standard
    ) {
        let sortedObjects = objects.sorted { $0.id < $1.id }
        self.objects = sortedObjects
        self.defaults = defaults
        self.favorites = Set(defaults.stringArray(forKey: favoritesKey) ?? [])
        self.appearance = AppAppearance(rawValue: defaults.string(forKey: appearanceKey) ?? "") ?? .system
        self.onlineCatalogCount = sortedObjects.count

#if !os(watchOS)
        Task { [weak self] in
            await self?.loadRemoteCatalog(forceNetwork: false, userInitiated: false)
        }
#endif
    }

    var filteredObjects: [SCPObject] {
        objects.filter { object in
            let passesContainment = selectedContainment.map { $0 == object.containmentClass } ?? true
            let passesZone = selectedZone.map { $0 == object.zone } ?? true
            let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let passesSearch: Bool
            if text.isEmpty {
                passesSearch = true
            } else {
                passesSearch = object.id.localizedCaseInsensitiveContains(text)
                    || object.title.localizedCaseInsensitiveContains(text)
                    || object.shortDescription.localizedCaseInsensitiveContains(text)
            }
            return passesContainment && passesZone && passesSearch
        }
    }

    var filteredObjectsByZone: [SCPZoneSection] {
        let grouped = Dictionary(grouping: filteredObjects, by: \.zone)
        return SCPZone.allCases.compactMap { zone in
            guard let objects = grouped[zone], !objects.isEmpty else {
                return nil
            }
            return SCPZoneSection(zone: zone, objects: objects.sorted { $0.id < $1.id })
        }
    }

    var favoriteObjects: [SCPObject] {
        filteredObjects.filter { favorites.contains($0.id) }
    }

    var activeContainmentLabel: String {
        selectedContainment?.rawValue ?? "All"
    }

    var activeZoneLabel: String {
        selectedZone?.rawValue ?? "All Zones"
    }

    var activeAppearanceLabel: String {
        appearance.rawValue
    }

    var preferredColorScheme: ColorScheme? {
        switch appearance {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    func isFavorite(_ object: SCPObject) -> Bool {
        favorites.contains(object.id)
    }

    func toggleFavorite(_ object: SCPObject) {
        if favorites.contains(object.id) {
            favorites.remove(object.id)
        } else {
            favorites.insert(object.id)
        }
        saveFavorites()
    }

    func setContainmentFilter(_ value: SCPContainmentClass?) {
        selectedContainment = value
    }

    func setZoneFilter(_ value: SCPZone?) {
        selectedZone = value
    }

    func cycleZoneFilter() {
        let cycle: [SCPZone?] = [nil] + SCPZone.allCases
        guard let currentIndex = cycle.firstIndex(where: { $0 == selectedZone }) else {
            selectedZone = nil
            return
        }
        let nextIndex = (currentIndex + 1) % cycle.count
        selectedZone = cycle[nextIndex]
    }

    func cycleContainmentFilter() {
        let cycle: [SCPContainmentClass?] = [nil] + SCPContainmentClass.allCases
        guard let currentIndex = cycle.firstIndex(where: { $0 == selectedContainment }) else {
            selectedContainment = nil
            return
        }
        let nextIndex = (currentIndex + 1) % cycle.count
        selectedContainment = cycle[nextIndex]
    }

    func setAppearance(_ value: AppAppearance) {
        appearance = value
        defaults.set(value.rawValue, forKey: appearanceKey)
    }

    func cycleAppearance() {
        let cycle = AppAppearance.allCases
        guard let currentIndex = cycle.firstIndex(of: appearance) else {
            setAppearance(.system)
            return
        }
        let nextIndex = (currentIndex + 1) % cycle.count
        setAppearance(cycle[nextIndex])
    }

    private func saveFavorites() {
        defaults.set(Array(favorites).sorted(), forKey: favoritesKey)
    }

    @MainActor
    func refreshRemoteCatalog() async {
        await loadRemoteCatalog(forceNetwork: true, userInitiated: true)
    }

    @MainActor
    private func loadRemoteCatalog(forceNetwork: Bool, userInitiated: Bool) async {
        if isRefreshingRemoteCatalog {
            return
        }

        isRefreshingRemoteCatalog = true
        onlineCatalogStatus = userInitiated
            ? "Проверяем обновления онлайн-каталога..."
            : "Подключаем онлайн-каталог..."
        defer { isRefreshingRemoteCatalog = false }

        let previousObjects = objects
        let previousIDs = Set(previousObjects.map(\.id))
        let previousByID = Dictionary(uniqueKeysWithValues: previousObjects.map { ($0.id, $0) })

        guard let payload = await Self.fetchRemoteIndexData(forceNetwork: forceNetwork) else {
            onlineCatalogStatus = "Не удалось обновить онлайн-каталог. Оставил текущие данные."
            return
        }

        let fallbackBase = SCPRepository.sampleObjects + previousObjects
        let fallback = Dictionary(fallbackBase.map { ($0.id, $0) }, uniquingKeysWith: { current, _ in current })
        let remoteObjects = await Self.decodeRemoteObjects(from: payload.data, fallback: fallback)
        guard !remoteObjects.isEmpty else {
            onlineCatalogStatus = "Онлайн-каталог пришёл пустой. Оставил текущие данные."
            return
        }

        objects = remoteObjects
        onlineCatalogCount = remoteObjects.count
        lastRemoteSyncDate = Date()

        let remoteIDs = Set(remoteObjects.map(\.id))
        let newIDs = remoteIDs.subtracting(previousIDs)
        let updatedTitles = remoteObjects.reduce(into: 0) { result, object in
            guard let oldObject = previousByID[object.id] else { return }
            if oldObject.title != object.title {
                result += 1
            }
        }

        if payload.fromCache {
            onlineCatalogStatus = "Обновил из кэша: \(remoteObjects.count) объектов."
        } else if !newIDs.isEmpty {
            onlineCatalogStatus = "Найдено \(newIDs.count) новых объектов. Всего: \(remoteObjects.count)."
        } else if updatedTitles > 0 {
            onlineCatalogStatus = "Новых объектов нет, но обновлено названий: \(updatedTitles)."
        } else if userInitiated {
            onlineCatalogStatus = "Новых объектов нет. Всего: \(remoteObjects.count)."
        } else {
            onlineCatalogStatus = "Онлайн-каталог загружен: \(remoteObjects.count) объектов."
        }
    }

    private static func fetchRemoteIndexData(forceNetwork: Bool) async -> (data: Data, fromCache: Bool)? {
        let request = URLRequest(
            url: remoteIndexURL,
            cachePolicy: forceNetwork ? .reloadIgnoringLocalCacheData : .returnCacheDataElseLoad,
            timeoutInterval: 20
        )

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            saveRemoteCache(data)
            return (data, false)
        } catch {
            guard let cached = loadRemoteCache() else {
                return nil
            }
            return (cached, true)
        }
    }

    private static func decodeRemoteObjects(
        from data: Data,
        fallback: [String: SCPObject]
    ) async -> [SCPObject] {
        await Task.detached(priority: .utility) {
            do {
                let index = try JSONDecoder().decode([String: RemoteIndexItem].self, from: data)
                let objects = index.compactMap { id, item -> SCPObject? in
                    guard id.hasPrefix("SCP-") else {
                        return nil
                    }

                    let fallbackObject = fallback[id]
                    let title = cleanedTitle(
                        remoteTitle: item.title,
                        id: id,
                        fallbackTitle: fallbackObject?.title
                    )
                    let containmentClass = containmentClass(from: item.tags)
                        ?? fallbackObject?.containmentClass
                        ?? .euclid
                    let clearanceLevel = fallbackObject?.clearanceLevel ?? .level2
                    let shortDescription = fallbackObject?.shortDescription ?? "Описание пока недоступно."
                    let containmentProcedure = fallbackObject?.containmentProcedure ?? "Нет данных."
                    let incidentNotes = fallbackObject?.incidentNotes ?? []

                    return SCPObject(
                        id: id,
                        title: title,
                        containmentClass: containmentClass,
                        clearanceLevel: clearanceLevel,
                        zone: fallbackObject?.zone,
                        shortDescription: shortDescription,
                        containmentProcedure: containmentProcedure,
                        incidentNotes: incidentNotes
                    )
                }

                return objects.sorted { $0.id < $1.id }
            } catch {
                return []
            }
        }.value
    }

    private static func cleanedTitle(remoteTitle: String?, id: String, fallbackTitle: String?) -> String {
        let trimmed = remoteTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty || trimmed.caseInsensitiveCompare(id) == .orderedSame {
            return fallbackTitle ?? id
        }
        return trimmed
    }

    private static func containmentClass(from tags: [String]?) -> SCPContainmentClass? {
        guard let tags else {
            return nil
        }
        let tagSet = Set(tags.map { $0.lowercased() })
        if tagSet.contains("keter") { return .keter }
        if tagSet.contains("euclid") { return .euclid }
        if tagSet.contains("safe") { return .safe }
        if tagSet.contains("thaumiel") { return .thaumiel }
        return nil
    }

    private static func saveRemoteCache(_ data: Data) {
        guard let url = remoteCacheURL() else {
            return
        }
        try? data.write(to: url, options: [.atomic])
    }

    private static func loadRemoteCache() -> Data? {
        guard let url = remoteCacheURL() else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    private static func remoteCacheURL() -> URL? {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(remoteCacheFile)
    }
}

private struct RemoteIndexItem: Decodable {
    let title: String?
    let tags: [String]?
}
