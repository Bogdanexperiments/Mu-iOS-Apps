import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject private var auth: AuthStore

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Профиль сотрудника")
                        .font(.title.bold())
                        .liquidGlassCard()

                    if let profile = auth.profile {
                        profileCard(profile)
                    } else if auth.isSkipped {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ты входишь без регистрации.")
                            Text("Хочешь заполнить данные?")
                                .foregroundStyle(.secondary)
                        }
                        .liquidGlassCard()
                    } else {
                        Text("Данные профиля не заполнены.")
                            .liquidGlassCard()
                    }

                    Button {
                        auth.resetAuthorization()
                    } label: {
                        Text("Перерегистрироваться")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .liquidGlassCard()
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
    }

    @ViewBuilder
    private func profileCard(_ profile: SCPWorkerProfile) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(profile.name)
                .font(.title2.bold())
            if let email = profile.email, !email.isEmpty {
                Text("Email: \(email)")
            }
            Text("ID: \(profile.workerId)")
            Text("Отдел: \(profile.department)")
            Text("Объект: \(profile.site)")
            Text("Допуск: \(profile.clearance.rawValue)")
        }
        .liquidGlassCard()
    }
}
