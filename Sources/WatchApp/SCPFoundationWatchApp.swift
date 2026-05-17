import SwiftUI

@main
struct SCPFoundationWatchApp: App {
    @StateObject private var store = SCPStore()

    var body: some Scene {
        WindowGroup {
            WatchRootView(store: store)
        }
    }
}
