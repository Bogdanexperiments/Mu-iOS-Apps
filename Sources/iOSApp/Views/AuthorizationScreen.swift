import SwiftUI

private enum AuthorizationMode: String, CaseIterable, Identifiable {
    case signIn = "Вход"
    case register = "Регистрация"

    var id: String { rawValue }
}

struct AuthorizationScreen: View {
    @ObservedObject var auth: AuthStore

    @State private var mode: AuthorizationMode = .signIn
    @State private var accountID: String = ""
    @State private var signInPassword: String = ""

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var workerId: String = ""
    @State private var department: String = ""
    @State private var site: String = ""
    @State private var password: String = ""
    @State private var passwordRepeat: String = ""
    @State private var clearance: SCPClearanceLevel = .level2
    @State private var errorMessage: String?
    @State private var isSubmitting: Bool = false

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Доступ сотрудника SCP")
                            .font(.largeTitle.bold())
                        Text(mode == .signIn ? "Проверь аккаунт по ID и паролю." : "Создай аккаунт онлайн с паролем.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .liquidGlassCard()

                    Picker("Режим", selection: $mode) {
                        ForEach(AuthorizationMode.allCases) { current in
                            Text(current.rawValue).tag(current)
                        }
                    }
                    .pickerStyle(.segmented)
                    .liquidGlassCard()

                    VStack(alignment: .leading, spacing: 12) {
                        if mode == .signIn {
                            TextField("ID аккаунта", text: $accountID)
                                .textInputAutocapitalization(.never)
                            SecureField("Пароль", text: $signInPassword)
                        } else {
                            TextField("Имя и фамилия", text: $name)
                                .textInputAutocapitalization(.words)
                            TextField("Email", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                            TextField("Идентификатор сотрудника", text: $workerId)
                                .textInputAutocapitalization(.characters)
                            TextField("Отдел", text: $department)
                                .textInputAutocapitalization(.words)
                            TextField("Объект / участок", text: $site)
                                .textInputAutocapitalization(.words)
                            SecureField("Пароль (минимум 6 символов)", text: $password)
                            SecureField("Повтори пароль", text: $passwordRepeat)

                            Picker("Уровень допуска", selection: $clearance) {
                                ForEach(SCPClearanceLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .liquidGlassCard()

                    VStack(spacing: 10) {
                        Button {
                            Task {
                                if mode == .signIn {
                                    await signIn()
                                } else {
                                    await register()
                                }
                            }
                        } label: {
                            if isSubmitting {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text(mode == .signIn ? "Войти" : "Зарегистрироваться")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isSubmitting)

                        Button {
                            auth.skipAuthorization()
                        } label: {
                            Text("Пропустить")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .liquidGlassCard()
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
        }
    }

    @MainActor
    private func signIn() async {
        let cleanedAccountID = accountID.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPassword = signInPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedAccountID.isEmpty, !cleanedPassword.isEmpty else {
            errorMessage = "Введи ID аккаунта и пароль."
            return
        }

        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await auth.signInOnline(accountID: cleanedAccountID, password: cleanedPassword)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ошибка входа."
        }
    }

    @MainActor
    private func register() async {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedWorkerId = workerId.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedDepartment = department.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedSite = site.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPasswordRepeat = passwordRepeat.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedName.isEmpty,
              !cleanedEmail.isEmpty,
              !cleanedWorkerId.isEmpty,
              !cleanedDepartment.isEmpty,
              !cleanedSite.isEmpty,
              !cleanedPassword.isEmpty,
              !cleanedPasswordRepeat.isEmpty else {
            errorMessage = "Заполни все поля."
            return
        }

        guard cleanedPassword == cleanedPasswordRepeat else {
            errorMessage = "Пароли не совпадают."
            return
        }

        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await auth.registerOnline(
                profile: SCPWorkerProfile(
                    name: cleanedName,
                    email: cleanedEmail,
                    workerId: cleanedWorkerId,
                    department: cleanedDepartment,
                    site: cleanedSite,
                    clearance: clearance
                ),
                password: cleanedPassword
            )
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ошибка регистрации."
        }
    }
}
