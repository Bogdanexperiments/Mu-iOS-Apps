import SwiftUI

struct BriefingScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                section(
                    title: "О приложении",
                    lines: [
                        "Это компактный каталог SCP с быстрым поиском и избранным.",
                        "Сделано на SwiftUI для iOS 18+, iPadOS 18+ и watchOS 10+."
                    ]
                )

                section(
                    title: "Как пользоваться",
                    lines: [
                        "1. Открой вкладку «Каталог».",
                        "2. Ищи по номеру SCP или названию.",
                        "3. Открой запись и нажми звезду.",
                        "4. Открой «Избранное» для быстрого доступа."
                    ]
                )

                section(
                    title: "Важно",
                    lines: [
                        "SCP — это совместная художественная вселенная. Здесь используются примерные данные для демонстрации."
                    ]
                )
            }
            .padding()
        }
        .background(Color.clear)
        .navigationTitle("Справка")
    }

    private func section(title: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.body)
            }
        }
        .liquidGlassCard(cornerRadius: 16)
    }
}
