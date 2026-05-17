import ActivityKit
import SwiftUI
import WidgetKit

struct ContainmentActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ContainmentActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 8) {
                Text(context.attributes.scpID)
                    .font(.headline)
                Text(context.attributes.scpTitle)
                    .font(.subheadline)
                    .lineLimit(1)
                HStack {
                    Text("Угроза")
                    Spacer()
                    Text("\(context.state.threatLevel)%")
                }
                .font(.caption)
                ProgressView(value: Double(context.state.threatLevel), total: 100)
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.scpID)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.threatLevel)%")
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.scpTitle)
                            .lineLimit(1)
                        Text(context.state.statusText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Text("SCP")
            } compactTrailing: {
                Text("\(context.state.threatLevel)")
            } minimal: {
                Text("\(context.state.threatLevel)")
            }
            .widgetURL(URL(string: "scp://live-activity"))
            .keylineTint(.red)
        }
    }
}
