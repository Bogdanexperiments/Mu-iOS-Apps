import SwiftUI
import PhotosUI

struct ProfileScreen: View {
    @EnvironmentObject private var auth: AuthStore
    @StateObject private var linkStore = O5RegistrationLinkStore()
    @StateObject private var avatarStore = ProfileAvatarStore()
    @State private var selectedPhoto: PhotosPickerItem?

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
                        if profile.clearance == .level5 {
                            O5RegistrationLinksPanel(store: linkStore, profile: profile)
                        }
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
            HStack(spacing: 14) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ProfileAvatarView(imageData: avatarStore.imageData, size: 76)
                }
                .buttonStyle(.plain)
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.title2.bold())
                    Text("Нажми на фото, чтобы изменить")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if let email = profile.email, !email.isEmpty {
                Text("Email: \(email)")
            }
            Text("ID: \(profile.workerId)")
            Text("Отдел: \(profile.department)")
            Text("Объект: \(profile.site)")
            Text("Допуск: \(profile.clearance.rawValue)")
        }
        .liquidGlassCard()
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run { avatarStore.save(data) }
                }
            }
        }
    }
}

private struct O5RegistrationLinksPanel: View {
    @ObservedObject var store: O5RegistrationLinkStore
    let profile: SCPWorkerProfile
    @State private var latestLink: O5RegistrationLink?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("O5 · ссылки регистрации", systemImage: "key.2.on.ring")
                .font(.headline)
            Text("Только допуск 5. Каждая ссылка действует 15 минут и может быть использована один раз.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                latestLink = store.issueLink(issuedBy: profile)
            } label: {
                Label("Создать уникальную ссылку", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if let latestLink {
                VStack(alignment: .leading, spacing: 8) {
                    Text(latestLink.url.absoluteString)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                    ShareLink(item: latestLink.url) {
                        Label("Поделиться ссылкой", systemImage: "square.and.arrow.up")
                    }
                }
                .padding(10)
                .background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            }

            ForEach(store.activeLinks) { link in
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Активна до \(link.expiresAt.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                        Text(link.token.prefix(12) + "…")
                            .font(.caption2.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        store.revoke(link)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .liquidGlassCard()
    }
}

struct O5RegistrationScreen: View {
    @ObservedObject var auth: AuthStore
    let link: O5RegistrationLink
    let onFinished: () -> Void

    @State private var name = ""
    @State private var email = ""
    @State private var workerId = ""
    @State private var department = "O5 Council"
    @State private var site = "Site-01"
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false

    var body: some View {
        Form {
            Section {
                Label("O5-приглашение подтверждено", systemImage: "checkmark.shield.fill")
                Text("Ссылка выдана: \(link.issuedBy). После регистрации будет назначен допуск 5.")
                    .font(.caption)
            }

            Section("Данные администратора") {
                TextField("Имя и фамилия", text: $name)
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                TextField("ID сотрудника", text: $workerId)
                    .textInputAutocapitalization(.characters)
                TextField("Отдел", text: $department)
                TextField("Объект / участок", text: $site)
                SecureField("Пароль (минимум 6 символов)", text: $password)
                SecureField("Повтори пароль", text: $repeatPassword)
            }

            if let errorMessage {
                Section { Text(errorMessage).foregroundStyle(.red) }
            }

            Section {
                Button {
                    Task { await register() }
                } label: {
                    if isSubmitting { ProgressView() } else { Text("Зарегистрировать администратора") }
                }
                .disabled(isSubmitting)
            }
        }
        .navigationTitle("Регистрация O5")
    }

    @MainActor
    private func register() async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !workerId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Заполни имя, email и ID сотрудника."
            return
        }
        guard password.count >= 6 else { errorMessage = "Пароль должен быть минимум 6 символов."; return }
        guard password == repeatPassword else { errorMessage = "Пароли не совпадают."; return }

        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await auth.registerOnline(
                profile: SCPWorkerProfile(
                    name: name,
                    email: email,
                    workerId: workerId,
                    department: department,
                    site: site,
                    clearance: .level5
                ),
                password: password,
                allowO5Invite: true
            )
            onFinished()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ошибка регистрации."
        }
    }
}
