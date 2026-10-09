import XCTest
@testable import SCPFoundationIOS

@MainActor
final class O5RegistrationTests: XCTestCase {
    func testLevel5RegistrationRequiresInviteToken() async {
        let auth = AuthStore(
            defaults: UserDefaults(suiteName: "O5RegistrationTests-\(UUID().uuidString)")!
        )
        let profile = SCPWorkerProfile(
            name: "O5 Administrator",
            email: "ioiopiphone@icloud.com",
            workerId: "O5-BOOTSTRAP",
            department: "O5 Council",
            site: "Site-01",
            clearance: .level5
        )

        do {
            try await auth.registerOnline(profile: profile, password: "secure-test-password")
            XCTFail("Level 5 registration must require a verified invite token")
        } catch let error as AuthStoreError {
            guard case .o5LinkRequired = error else {
                XCTFail("Unexpected auth error: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testO5LinkUsesAuthInviteScheme() {
        let profile = SCPWorkerProfile(
            name: "O5 Administrator",
            email: "admin@example.com",
            workerId: "O5-001",
            department: "O5 Council",
            site: "Site-01",
            clearance: .level5
        )
        let store = O5RegistrationLinkStore(
            defaults: UserDefaults(suiteName: "O5RegistrationTests-\(UUID().uuidString)")!
        )

        let link = store.issueLink(issuedBy: profile)

        XCTAssertNotNil(link)
        XCTAssertEqual(link?.url.scheme, "scp")
        XCTAssertEqual(link?.url.host, "auth")
        XCTAssertEqual(link?.url.path, "/invite")
        XCTAssertNotNil(link?.url.query)
        XCTAssertFalse(link?.url.absoluteString.contains("level=5") ?? true)
    }

    func testNonO5ProfileCannotIssueInvitation() {
        let profile = SCPWorkerProfile(
            name: "Researcher",
            email: "researcher@example.com",
            workerId: "R-001",
            department: "Research",
            site: "Site-19",
            clearance: .level2
        )
        let store = O5RegistrationLinkStore(
            defaults: UserDefaults(suiteName: "O5RegistrationTests-\(UUID().uuidString)")!
        )

        XCTAssertNil(store.issueLink(issuedBy: profile))
        XCTAssertTrue(store.activeLinks.isEmpty)
    }

    func testO5InvitationIsSingleUse() {
        let profile = SCPWorkerProfile(
            name: "O5 Administrator",
            email: "admin@example.com",
            workerId: "O5-002",
            department: "O5 Council",
            site: "Site-01",
            clearance: .level5
        )
        let store = O5RegistrationLinkStore(
            defaults: UserDefaults(suiteName: "O5RegistrationTests-\(UUID().uuidString)")!
        )
        let link = try! XCTUnwrap(store.issueLink(issuedBy: profile))

        XCTAssertNotNil(store.consume(token: link.token))
        XCTAssertNil(store.consume(token: link.token))
    }
}
