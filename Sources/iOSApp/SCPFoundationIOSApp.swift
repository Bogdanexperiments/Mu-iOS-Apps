import SwiftUI

@main
struct SCPFoundationIOSApp: App {
    @StateObject private var store = SCPStore()
    @StateObject private var auth = AuthStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.canEnterApp {
                    IOSRootView(store: store)
                        .environmentObject(auth)
                } else {
                    AuthorizationScreen(auth: auth)
                        .environmentObject(auth)
                }
            }
            .preferredColorScheme(store.preferredColorScheme)
        }
    }
}
