import ActivityKit
import Foundation

struct ContainmentActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var threatLevel: Int
        var statusText: String
        var updatedAt: Date
    }

    var scpID: String
    var scpTitle: String
}
