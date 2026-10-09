import SwiftUI

@main
struct SCPFoundationIOSApp: App {
    @StateObject private var store = SCPStore()
    @StateObject private var auth = AuthStore()
    @StateObject private var registrationLinks = O5RegistrationLinkStore()
    @State private var registrationLink: O5RegistrationLink?

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
            .onOpenURL { url in
                let isCurrentInvite = url.scheme == "scp" &&
                    url.host == "auth" &&
                    url.path == "/invite"
                let isLegacyInvite = url.scheme == "scpfoundation" &&
                    url.host == "admin" &&
                    url.path == "/register"
                guard isCurrentInvite || isLegacyInvite,
                      let token = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                        .queryItems?.first(where: { $0.name == "token" })?.value else { return }
                registrationLink = registrationLinks.link(for: token)
            }
            .sheet(item: $registrationLink) { link in
                NavigationStack {
                    O5RegistrationScreen(auth: auth, link: link) {
                        _ = registrationLinks.consume(token: link.token)
                        registrationLink = nil
                    }
                }
            }
        }
    }
}
