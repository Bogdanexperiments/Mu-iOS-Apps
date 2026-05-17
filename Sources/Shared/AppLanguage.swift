import Foundation

enum AppLanguage: String, CaseIterable, Codable, Hashable {
    case english = "en"
    case russian = "ru"

    var menuTitle: String {
        switch self {
        case .english:
            return "English"
        case .russian:
            return "Русский"
        }
    }
}

enum UIKey {
    case catalogTab
    case favoritesTab
    case briefingTab
    case catalogTitle
    case favoritesTitle
    case briefingTitle
    case searchPrompt
    case all
    case filter
    case language
    case summary
    case containmentProcedure
    case incidentNotes
    case noFavoritesTitle
    case noFavoritesDescription
    case addFavorite
    case removeFavorite
    case about
    case howToUse
    case disclaimer
    case aboutLine1
    case aboutLine2
    case howToStep1
    case howToStep2
    case howToStep3
    case howToStep4
    case disclaimerLine
}

enum L10n {
    static func text(_ key: UIKey, language: AppLanguage) -> String {
        switch language {
        case .english:
            switch key {
            case .catalogTab: return "Catalog"
            case .favoritesTab: return "Favorites"
            case .briefingTab: return "Briefing"
            case .catalogTitle: return "SCP Catalog"
            case .favoritesTitle: return "Favorites"
            case .briefingTitle: return "Briefing"
            case .searchPrompt: return "Search by number or title"
            case .all: return "All"
            case .filter: return "Filter"
            case .language: return "Language"
            case .summary: return "Summary"
            case .containmentProcedure: return "Containment Procedure"
            case .incidentNotes: return "Incident Notes"
            case .noFavoritesTitle: return "No favorites yet"
            case .noFavoritesDescription: return "Open an SCP and tap the star to keep it here."
            case .addFavorite: return "Add Favorite"
            case .removeFavorite: return "Remove Favorite"
            case .about: return "About"
            case .howToUse: return "How to use"
            case .disclaimer: return "Disclaimer"
            case .aboutLine1: return "This app is a compact SCP catalog with quick search and favorites."
            case .aboutLine2: return "Built with SwiftUI for iOS 18+, iPadOS 18+, and watchOS 10+."
            case .howToStep1: return "1. Open Catalog."
            case .howToStep2: return "2. Search by SCP number or name."
            case .howToStep3: return "3. Open any entry and tap the star."
            case .howToStep4: return "4. Check Favorites for quick access."
            case .disclaimerLine: return "SCP is a collaborative fiction universe. This app uses sample data for demonstration."
            }
        case .russian:
            switch key {
            case .catalogTab: return "Каталог"
            case .favoritesTab: return "Избранное"
            case .briefingTab: return "Справка"
            case .catalogTitle: return "Каталог SCP"
            case .favoritesTitle: return "Избранное"
            case .briefingTitle: return "Справка"
            case .searchPrompt: return "Поиск по номеру или названию"
            case .all: return "Все"
            case .filter: return "Фильтр"
            case .language: return "Язык"
            case .summary: return "Кратко"
            case .containmentProcedure: return "Процедура содержания"
            case .incidentNotes: return "Заметки об инцидентах"
            case .noFavoritesTitle: return "Пока нет избранного"
            case .noFavoritesDescription: return "Открой SCP и нажми звезду, чтобы сохранить здесь."
            case .addFavorite: return "В избранное"
            case .removeFavorite: return "Убрать из избранного"
            case .about: return "О приложении"
            case .howToUse: return "Как пользоваться"
            case .disclaimer: return "Важно"
            case .aboutLine1: return "Это компактный каталог SCP с быстрым поиском и избранным."
            case .aboutLine2: return "Сделано на SwiftUI для iOS 18+, iPadOS 18+ и watchOS 10+."
            case .howToStep1: return "1. Открой вкладку «Каталог»."
            case .howToStep2: return "2. Ищи по номеру SCP или названию."
            case .howToStep3: return "3. Открой запись и нажми звезду."
            case .howToStep4: return "4. Открой «Избранное» для быстрого доступа."
            case .disclaimerLine: return "SCP — это совместная художественная вселенная. Здесь используются примерные данные для демонстрации."
            }
        }
    }
}
