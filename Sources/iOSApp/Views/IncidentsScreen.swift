import SwiftUI

struct IncidentsScreen: View {
    @State private var searchText: String = ""

    private var filteredDocs: [SCPIncidentDoc] {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            return SCPIncidentRepository.docs
        }

        return SCPIncidentRepository.docs.filter { doc in
            doc.id.localizedCaseInsensitiveContains(text)
                || doc.title.localizedCaseInsensitiveContains(text)
                || doc.relatedSCP.localizedCaseInsensitiveContains(text)
                || doc.summary.localizedCaseInsensitiveContains(text)
        }
    }

    var body: some View {
        List(filteredDocs) { doc in
            NavigationLink {
                IncidentDetailScreen(doc: doc)
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(doc.id)
                        .font(.headline)
                    Text(doc.title)
                        .font(.subheadline)
                    Text("\(doc.relatedSCP) • \(doc.dateLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .liquidGlassCard(cornerRadius: 14, horizontalPadding: 12, verticalPadding: 10)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .listStyle(.plain)
        .navigationTitle("Документы инцидентов")
        .searchable(text: $searchText, prompt: "Поиск инцидентов")
    }
}

private struct IncidentDetailScreen: View {
    let doc: SCPIncidentDoc

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(doc.id)
                    .font(.title3.weight(.semibold))
                Text(doc.title)
                    .font(.headline)
                Label(doc.relatedSCP, systemImage: "waveform.path.ecg")
                Label(doc.dateLabel, systemImage: "calendar")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Кратко")
                        .font(.headline)
                    Text(doc.summary)
                        .font(.body)
                }
                .liquidGlassCard(cornerRadius: 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Источник")
                        .font(.headline)
                    if let sourceURL = doc.sourceURL {
                        Link("Открыть источник на SCP Wiki", destination: sourceURL)
                            .font(.body)
                    } else {
                        Text(doc.sourceURLString)
                            .font(.footnote)
                    }
                }
                .liquidGlassCard(cornerRadius: 16)
            }
            .padding()
        }
        .background(Color.clear)
        .navigationTitle(doc.id)
        .navigationBarTitleDisplayMode(.inline)
    }
}
