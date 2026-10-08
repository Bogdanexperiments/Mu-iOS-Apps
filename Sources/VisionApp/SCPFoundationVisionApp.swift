import SwiftUI

@main
struct SCPFoundationVisionApplication: App {
    @StateObject private var store = SCPStore()

    var body: some Scene {
        WindowGroup {
            DesktopFoundationRootView(store: store)
                .padding(24)
        }
        .defaultSize(width: 1200, height: 800)
    }
}
