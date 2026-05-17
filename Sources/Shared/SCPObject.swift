import Foundation

enum SCPContainmentClass: String, CaseIterable, Codable, Hashable {
    case safe = "Безопасный"
    case euclid = "Euclid"
    case keter = "Keter"
    case thaumiel = "Thaumiel"

    var description: String {
        switch self {
        case .safe:
            return "легко содержать"
        case .euclid:
            return "нужен постоянный контроль"
        case .keter:
            return "высокая опасность"
        case .thaumiel:
            return "используется для сдерживания других SCP"
        }
    }
}

enum SCPClearanceLevel: String, CaseIterable, Codable, Hashable {
    case level1 = "Уровень 1"
    case level2 = "Уровень 2"
    case level3 = "Уровень 3"
    case level4 = "Уровень 4"
    case level5 = "Уровень 5"
}

enum SCPZone: String, CaseIterable, Codable, Hashable, Identifiable {
    case biological = "Биологическая зона"
    case humanoid = "Гуманоидная зона"
    case dimensional = "Пространственная зона"
    case armed = "Вооружённая зона"
    case research = "Исследовательская зона"
    case storage = "Зона хранения"
    case containment = "Зона содержания"

    var id: String { rawValue }

    static func inferredZone(for objectID: String) -> SCPZone {
        switch objectID {
        case "SCP-008", "SCP-939", "SCP-999":
            return .biological
        case "SCP-049", "SCP-073", "SCP-076", "SCP-096", "SCP-105", "SCP-239":
            return .humanoid
        case "SCP-087", "SCP-093", "SCP-3008":
            return .dimensional
        case "SCP-457", "SCP-682":
            return .armed
        case "SCP-055", "SCP-079", "SCP-914", "SCP-2000":
            return .research
        case "SCP-261", "SCP-500":
            return .storage
        default:
            return .containment
        }
    }
}

enum AppAppearance: String, CaseIterable, Codable, Hashable, Identifiable {
    case system = "Системная"
    case light = "Светлая"
    case dark = "Тёмная"

    var id: String { rawValue }
}

struct SCPObject: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let containmentClass: SCPContainmentClass
    let clearanceLevel: SCPClearanceLevel
    let zone: SCPZone
    let shortDescription: String
    let containmentProcedure: String
    let incidentNotes: [String]

    init(
        id: String,
        title: String,
        containmentClass: SCPContainmentClass,
        clearanceLevel: SCPClearanceLevel,
        zone: SCPZone? = nil,
        shortDescription: String,
        containmentProcedure: String,
        incidentNotes: [String]
    ) {
        self.id = id
        self.title = title
        self.containmentClass = containmentClass
        self.clearanceLevel = clearanceLevel
        self.zone = zone ?? SCPZone.inferredZone(for: id)
        self.shortDescription = shortDescription
        self.containmentProcedure = containmentProcedure
        self.incidentNotes = incidentNotes
    }
}
