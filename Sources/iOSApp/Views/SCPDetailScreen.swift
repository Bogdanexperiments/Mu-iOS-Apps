import SwiftUI

struct SCPDetailScreen: View {
    @ObservedObject var store: SCPStore
    let object: SCPObject
    @State private var liveThreatLevel: Int = 55
    @State private var liveStatusText: String = "Не запущено для этой аномалии"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(object.id)
                        .font(.largeTitle)
                        .bold()
                    Text(object.title)
                        .font(.title3)
                    Label(object.zone.rawValue, systemImage: "map")
                    Label("\(object.containmentClass.rawValue) (\(object.containmentClass.description))", systemImage: "lock.shield")
                    Label(object.clearanceLevel.rawValue, systemImage: "person.badge.key")
                }
                .liquidGlassCard(cornerRadius: 18)

                section(title: "Кратко", text: object.shortDescription)
                section(title: "Процедура содержания", text: object.containmentProcedure)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Заметки об инцидентах")
                        .font(.headline)
                    ForEach(object.incidentNotes, id: \.self) { note in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text(note)
                        }
                    }
                }
                .liquidGlassCard(cornerRadius: 16)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Dynamic Island")
                        .font(.headline)

                    Text("Уровень угрозы: \(liveThreatLevel)%")
                        .font(.subheadline)

                    Slider(
                        value: Binding(
                            get: { Double(liveThreatLevel) },
                            set: { liveThreatLevel = Int($0) }
                        ),
                        in: 0...100,
                        step: 1
                    )

                    Text(liveStatusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        Button("Старт") {
                            Task {
                                let started = await ContainmentLiveActivityManager.shared.start(
                                    for: object,
                                    initialThreatLevel: liveThreatLevel
                                )
                                liveStatusText = started ? "Live Activity запущена для \(object.id)" : "Live Activity недоступна"
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Обновить") {
                            Task {
                                await ContainmentLiveActivityManager.shared.update(
                                    threatLevel: liveThreatLevel,
                                    for: object.id
                                )
                                liveStatusText = "\(object.id): обновлено до \(liveThreatLevel)%"
                            }
                        }
                        .buttonStyle(.bordered)

                        Button("Стоп") {
                            Task {
                                await ContainmentLiveActivityManager.shared.end(for: object.id)
                                liveStatusText = "Остановлено для \(object.id)"
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .liquidGlassCard(cornerRadius: 16)
            }
            .padding()
        }
        .background(Color.clear)
        .navigationTitle(object.id)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleFavorite(object)
                } label: {
                    Image(systemName: store.isFavorite(object) ? "star.fill" : "star")
                }
            }
        }
    }

    private func section(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(text)
                .font(.body)
        }
        .liquidGlassCard(cornerRadius: 16)
    }
}
