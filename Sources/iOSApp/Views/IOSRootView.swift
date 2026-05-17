import SwiftUI

struct IOSRootView: View {
    @ObservedObject var store: SCPStore

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            TabView {
                NavigationStack {
                    SCPListScreen(store: store)
                }
                .tabItem {
                    Label("Каталог", systemImage: "books.vertical")
                }

                NavigationStack {
                    FavoritesScreen(store: store)
                }
                .tabItem {
                    Label("Избранное", systemImage: "star.fill")
                }

                NavigationStack {
                    IncidentsScreen()
                }
                .tabItem {
                    Label("Инциденты", systemImage: "doc.text.magnifyingglass")
                }

                NavigationStack {
                    BriefingScreen()
                }
                .tabItem {
                    Label("Справка", systemImage: "shield")
                }

                NavigationStack {
                    ProfileScreen()
                }
                .tabItem {
                    Label("Профиль", systemImage: "person.crop.circle")
                }
            }
        }
        .preferredColorScheme(store.preferredColorScheme)
    }
}
