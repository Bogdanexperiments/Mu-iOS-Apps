import XCTest
@testable import SCPFoundationIOS

final class SCPStoreTests: XCTestCase {
    func testSearchFiltersByID() {
        let store = makeStore()
        store.searchText = "173"

        XCTAssertEqual(store.filteredObjects.count, 1)
        XCTAssertEqual(store.filteredObjects.first?.id, "SCP-173")
    }

    func testContainmentFilter() {
        let store = makeStore()
        store.setContainmentFilter(.safe)

        XCTAssertFalse(store.filteredObjects.isEmpty)
        XCTAssertTrue(store.filteredObjects.allSatisfy { $0.containmentClass == .safe })
        XCTAssertTrue(store.filteredObjects.map(\.id).contains("SCP-999"))
    }

    func testFavoriteToggle() {
        let store = makeStore()
        let target = store.filteredObjects[0]

        XCTAssertFalse(store.isFavorite(target))
        store.toggleFavorite(target)
        XCTAssertTrue(store.isFavorite(target))
        store.toggleFavorite(target)
        XCTAssertFalse(store.isFavorite(target))
    }

    func testObjectsAreGroupedByZone() {
        let store = makeStore()

        let zones = store.filteredObjectsByZone.map(\.zone)
        XCTAssertEqual(zones, [.biological, .containment])
        XCTAssertEqual(store.filteredObjectsByZone.first?.objects.first?.id, "SCP-999")
    }

    func testIncidentDocsHaveValidURLs() {
        XCTAssertFalse(SCPIncidentRepository.docs.isEmpty)
        XCTAssertTrue(SCPIncidentRepository.docs.allSatisfy { $0.sourceURL != nil })
    }

    private func makeStore() -> SCPStore {
        let defaults = UserDefaults(suiteName: "SCPStoreTests-\(UUID().uuidString)")!
        defaults.removePersistentDomain(forName: defaultsSuiteName(defaults))

        return SCPStore(
            objects: [
                SCPObject(
                    id: "SCP-173",
                    title: "The Sculpture",
                    containmentClass: .euclid,
                    clearanceLevel: .level3,
                    shortDescription: "Moves when unobserved.",
                    containmentProcedure: "Watch it.",
                    incidentNotes: []
                ),
                SCPObject(
                    id: "SCP-999",
                    title: "Tickle Monster",
                    containmentClass: .safe,
                    clearanceLevel: .level1,
                    shortDescription: "Friendly jelly creature.",
                    containmentProcedure: "Standard room.",
                    incidentNotes: []
                )
            ],
            defaults: defaults
        )
    }

    private func defaultsSuiteName(_ defaults: UserDefaults) -> String {
        defaults.dictionaryRepresentation().description
    }
}
