import SwiftUI

struct WatchRootView: View {
    @ObservedObject var store: SCPStore

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            NavigationStack {
                List {
                    ForEach(store.filteredObjectsByZone) { zoneSection in
                        Section(zoneSection.zone.rawValue) {
                            ForEach(zoneSection.objects) { object in
                                NavigationLink {
                                    WatchDetailView(store: store, object: object)
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(object.id)
                                            .font(.caption2.weight(.semibold))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        Text(object.title)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                    .liquidGlassCard(cornerRadius: 10, horizontalPadding: 6, verticalPadding: 5)
                                }
                                .listRowBackground(Color.clear)
                                .listRowInsets(.init(top: 2, leading: 4, bottom: 2, trailing: 4))
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .navigationTitle("SCP")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            store.cycleAppearance()
                        } label: {
                            Image(systemName: appearanceSymbol)
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            store.cycleContainmentFilter()
                        } label: {
                            Text(store.activeContainmentLabel)
                        }
                    }
                }
            }
            .dynamicTypeSize(.small ... .xLarge)
        }
        .preferredColorScheme(store.preferredColorScheme)
    }

    private var appearanceSymbol: String {
        switch store.appearance {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

private struct WatchDetailView: View {
    @ObservedObject var store: SCPStore
    let object: SCPObject

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(object.id)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Text(object.title)
                    .font(.caption2)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(object.zone.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(object.shortDescription)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)

                Button(store.isFavorite(object) ? "Убрать из избранного" : "В избранное") {
                    store.toggleFavorite(object)
                }
                .buttonStyle(.bordered)
                .font(.caption2)
            }
            .liquidGlassCard(cornerRadius: 10, horizontalPadding: 8, verticalPadding: 8)
            .padding(.horizontal, 2)
        }
        .background(Color.clear)
        .navigationTitle(object.id)
        .dynamicTypeSize(.small ... .xLarge)
    }
}
