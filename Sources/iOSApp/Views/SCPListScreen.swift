import SwiftUI

struct SCPListScreen: View {
    @ObservedObject var store: SCPStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isPadLayout: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        List {
            Section("Онлайн-каталог") {
                VStack(alignment: .leading, spacing: 10) {
                    Text(store.onlineCatalogStatus)
                        .font(.subheadline)

                    Text("Объектов в каталоге: \(store.onlineCatalogCount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let lastSync = store.lastRemoteSyncDate {
                        Text("Последняя проверка: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        Task {
                            await store.refreshRemoteCatalog()
                        }
                    } label: {
                        if store.isRefreshingRemoteCatalog {
                            Label("Проверяем...", systemImage: "arrow.triangle.2.circlepath")
                        } else {
                            Label("Проверить обновления", systemImage: "arrow.clockwise")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(store.isRefreshingRemoteCatalog)
                }
                .liquidGlassCard(cornerRadius: 14, horizontalPadding: 12, verticalPadding: 10)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))

            ForEach(store.filteredObjectsByZone) { zoneSection in
                Section(zoneSection.zone.rawValue) {
                    ForEach(zoneSection.objects) { object in
                        NavigationLink {
                            SCPDetailScreen(store: store, object: object)
                        } label: {
                            SCPRow(
                                object: object,
                                isFavorite: store.isFavorite(object),
                                isPadLayout: isPadLayout
                            )
                            .liquidGlassCard(cornerRadius: 14, horizontalPadding: 12, verticalPadding: 10)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .listStyle(.plain)
        .navigationTitle("Каталог SCP")
        .searchable(text: $store.searchText, prompt: "Поиск по номеру или названию")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section("Класс содержания") {
                        Button("Все") {
                            store.setContainmentFilter(nil)
                        }
                        ForEach(SCPContainmentClass.allCases, id: \.self) { level in
                            Button(level.rawValue) {
                                store.setContainmentFilter(level)
                            }
                        }
                    }

                    Section("Зона") {
                        Button("Все зоны") {
                            store.setZoneFilter(nil)
                        }
                        ForEach(SCPZone.allCases, id: \.self) { zone in
                            Button(zone.rawValue) {
                                store.setZoneFilter(zone)
                            }
                        }
                    }
                } label: {
                    Label("Фильтр", systemImage: "line.3.horizontal.decrease.circle")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(AppAppearance.allCases, id: \.self) { mode in
                        Button(mode.rawValue) {
                            store.setAppearance(mode)
                        }
                    }
                } label: {
                    Label(store.activeAppearanceLabel, systemImage: "circle.lefthalf.filled")
                }
            }
        }
    }
}

private struct SCPRow: View {
    let object: SCPObject
    let isFavorite: Bool
    let isPadLayout: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(object.id)
                    .font(isPadLayout ? .title3.weight(.semibold) : .headline)
                if isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
            }
            Text(object.title)
                .font(isPadLayout ? .title3 : .subheadline)
            Text("\(object.zone.rawValue) • \(object.containmentClass.rawValue) • \(object.clearanceLevel.rawValue)")
                .font(isPadLayout ? .body : .caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
