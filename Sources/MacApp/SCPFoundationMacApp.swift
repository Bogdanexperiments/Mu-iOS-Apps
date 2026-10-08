import SwiftUI

@main
struct SCPFoundationMacApplication: App {
    @StateObject private var store = SCPStore()

    var body: some Scene {
        WindowGroup {
            DesktopFoundationRootView(store: store)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
