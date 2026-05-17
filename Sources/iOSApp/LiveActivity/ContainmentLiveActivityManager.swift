import ActivityKit
import Foundation

@MainActor
final class ContainmentLiveActivityManager {
    static let shared = ContainmentLiveActivityManager()

    private var activitiesByObjectID: [String: Activity<ContainmentActivityAttributes>] = [:]
    private var lastSelectedObjectID: String?

    var isRunning: Bool {
        !activitiesByObjectID.isEmpty
    }

    func isRunning(for objectID: String) -> Bool {
        activitiesByObjectID[objectID] != nil
    }

    private init() {}

    func start(for object: SCPObject, initialThreatLevel: Int = 55) async -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return false
        }

        if activitiesByObjectID[object.id] != nil {
            await update(threatLevel: initialThreatLevel, for: object.id)
            lastSelectedObjectID = object.id
            return true
        }

        let attributes = ContainmentActivityAttributes(
            scpID: object.id,
            scpTitle: object.title
        )
        let initialState = ContainmentActivityAttributes.ContentState(
            threatLevel: clampedThreat(initialThreatLevel),
            statusText: riskLabel(for: initialThreatLevel),
            updatedAt: Date()
        )

        do {
            let newActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: Date().addingTimeInterval(120)),
                pushType: nil
            )
            activitiesByObjectID[object.id] = newActivity
            lastSelectedObjectID = object.id
            return true
        } catch {
            return false
        }
    }

    func update(threatLevel: Int, for objectID: String? = nil) async {
        guard let activity = resolveActivity(for: objectID) else { return }
        let level = clampedThreat(threatLevel)
        let state = ContainmentActivityAttributes.ContentState(
            threatLevel: level,
            statusText: riskLabel(for: level),
            updatedAt: Date()
        )
        await activity.update(
            ActivityContent(state: state, staleDate: Date().addingTimeInterval(120))
        )
    }

    func end(for objectID: String? = nil) async {
        guard let activity = resolveActivity(for: objectID) else { return }
        let finalState = ContainmentActivityAttributes.ContentState(
            threatLevel: 0,
            statusText: "Закрыто",
            updatedAt: Date()
        )
        await activity.end(
            ActivityContent(state: finalState, staleDate: Date()),
            dismissalPolicy: .immediate
        )
        if let objectID {
            activitiesByObjectID.removeValue(forKey: objectID)
        } else if let currentID = lastSelectedObjectID {
            activitiesByObjectID.removeValue(forKey: currentID)
        } else if let first = activitiesByObjectID.first {
            activitiesByObjectID.removeValue(forKey: first.key)
        }

        if activitiesByObjectID.isEmpty {
            lastSelectedObjectID = nil
        }
    }

    private func clampedThreat(_ value: Int) -> Int {
        max(0, min(100, value))
    }

    private func riskLabel(for value: Int) -> String {
        switch value {
        case 0..<30:
            return "Низкий"
        case 30..<70:
            return "Средний"
        default:
            return "Критический"
        }
    }

    private func resolveActivity(for objectID: String?) -> Activity<ContainmentActivityAttributes>? {
        if let objectID {
            lastSelectedObjectID = objectID
            return activitiesByObjectID[objectID]
        }
        if let lastSelectedObjectID {
            return activitiesByObjectID[lastSelectedObjectID]
        }
        if let first = activitiesByObjectID.first {
            lastSelectedObjectID = first.key
            return first.value
        }
        return nil
    }
}
