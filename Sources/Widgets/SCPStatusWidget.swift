import SwiftUI
import WidgetKit

struct SCPStatusWidgetEntry: TimelineEntry {
    let date: Date
    let document: SCPIncidentDoc
}

struct SCPStatusWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SCPStatusWidgetEntry {
        SCPStatusWidgetEntry(date: Date(), document: Self.fallbackDocument)
    }

    func getSnapshot(in context: Context, completion: @escaping (SCPStatusWidgetEntry) -> Void) {
        completion(SCPStatusWidgetEntry(date: Date(), document: Self.fallbackDocument))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SCPStatusWidgetEntry>) -> Void) {
        let entry = SCPStatusWidgetEntry(
            date: Date(),
            document: SCPIncidentRepository.docs.first ?? Self.fallbackDocument
        )
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(30 * 60))))
    }

    private static let fallbackDocument = SCPIncidentDoc(
        id: "SCP-173-STATUS",
        title: "Демонстрационный статус",
        relatedSCP: "SCP-173",
        dateLabel: "Текущая запись",
        summary: "Объект находится под наблюдением.",
        sourceURLString: "https://scp-wiki.wikidot.com/scp-173"
    )
}

struct SCPStatusWidgetEntryView: View {
    let entry: SCPStatusWidgetProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.document.relatedSCP)
                .font(.headline)
            Text(entry.document.title)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
            Text(entry.document.summary)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
        .widgetURL(entry.document.sourceURL)
    }
}

struct SCPStatusWidget: Widget {
    let kind = "SCPStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SCPStatusWidgetProvider()) { entry in
            SCPStatusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Статус SCP")
        .description("Показывает текущую запись об аномалии.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
