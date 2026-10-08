import SwiftUI

struct DesktopFoundationRootView: View {
    @ObservedObject var store: SCPStore

    var body: some View {
        NavigationSplitView {
            List {
                Section("Каталог") {
                    Label("Все объекты", systemImage: "books.vertical")
                    Label("Избранное", systemImage: "star.fill")
                    Label("Инциденты", systemImage: "doc.text.magnifyingglass")
                }
                Section("Система") {
                    Label("Справка", systemImage: "shield")
                    Label("Профиль", systemImage: "person.crop.circle")
                }
            }
            .navigationTitle("SCP Foundation")
        } detail: {
            NavigationStack {
                SCPDesktopCatalogView(store: store)
            }
        }
        .frame(minWidth: 980, minHeight: 640)
    }
}

private struct SCPDesktopCatalogView: View {
    @ObservedObject var store: SCPStore
    @State private var selectedID: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Каталог аномальных объектов")
                .font(.largeTitle.bold())
            Text("Рабочее desktop-представление для macOS и Apple Vision Pro")
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: 20) {
                List(store.filteredObjects, selection: $selectedID) { object in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(object.id).font(.headline.monospaced())
                        Text(object.title).font(.subheadline)
                        Text(object.zone.rawValue).font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 5)
                }
                .frame(minWidth: 330)

                if let selectedID,
                   let object = store.filteredObjects.first(where: { $0.id == selectedID }) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(object.id).font(.title.bold().monospaced())
                            Text(object.title).font(.title2)
                            Label(object.containmentClass.rawValue, systemImage: "lock.shield")
                                .foregroundStyle(object.containmentClass.glowColor)
                                .font(.headline)
                            Label(object.zone.rawValue, systemImage: "map")
                            Divider()
                            Text("Описание").font(.headline)
                            Text(object.shortDescription)
                            Text("Процедуры содержания").font(.headline)
                            Text(object.containmentProcedure)
                            if let report = object.fullReport {
                                Divider()
                                Text("Полный отчёт").font(.title2.bold())
                                desktopReportSection("Обзор", report.overview)
                                desktopReportSection("Аномальные свойства", report.anomalousProperties)
                                desktopReportSection("Обоснование содержания", report.containmentRationale)
                                desktopReportSection("Оценка риска", report.riskAssessment)
                                desktopReportSection("Операционная история", report.operationalHistory)
                                if let sourceURL = report.sourceURL {
                                    Link("Первоисточник на SCP Wiki", destination: sourceURL)
                                        .font(.caption.weight(.semibold))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                    }
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .scpClassGlow(object.containmentClass)
                } else {
                    ContentUnavailableView("Выбери объект", systemImage: "circle.dashed")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .padding(24)
    }

    private func desktopReportSection(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.headline)
            Text(text)
        }
    }
}
