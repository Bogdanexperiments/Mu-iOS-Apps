import SwiftUI

struct FavoritesScreen: View {
    @ObservedObject var store: SCPStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isPadLayout: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        Group {
            if store.favoriteObjects.isEmpty {
                ContentUnavailableView(
                    "Пока нет избранного",
                    systemImage: "star",
                    description: Text("Открой SCP и нажми звезду, чтобы сохранить здесь.")
                )
            } else {
                List(store.favoriteObjects) { object in
                    NavigationLink {
                        SCPDetailScreen(store: store, object: object)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(object.id)
                                .font(isPadLayout ? .title3.weight(.semibold) : .headline)
                            Text(object.title)
                                .font(isPadLayout ? .title3 : .subheadline)
                                .foregroundStyle(.secondary)
                            Text(object.zone.rawValue)
                                .font(isPadLayout ? .body : .caption)
                                .foregroundStyle(.secondary)
                        }
                        .liquidGlassCard(cornerRadius: 14, horizontalPadding: 12, verticalPadding: 10)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listStyle(.plain)
            }
        }
        .navigationTitle("Избранное")
        .searchable(text: $store.searchText)
    }
}
