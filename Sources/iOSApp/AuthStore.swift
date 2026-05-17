import Foundation

struct SCPWorkerProfile: Codable, Hashable {
    let name: String
    let email: String?
    let workerId: String
    let department: String
    let site: String
    let clearance: SCPClearanceLevel
}

@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var profile: SCPWorkerProfile?
    @Published private(set) var isSkipped: Bool

    private let defaults: UserDefaults
    private let profileKey = "scp_worker_profile_v1"
    private let skipKey = "scp_worker_skip_v1"
    private static let registrationURL = URL(string: "https://dummyjson.com/users/add")!
    private static let loginURL = URL(string: "https://dummyjson.com/auth/login")!

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isSkipped = defaults.bool(forKey: skipKey)
        self.profile = Self.loadProfile(defaults: defaults, key: profileKey)
    }

    var isAuthorized: Bool {
        profile != nil
    }

    var canEnterApp: Bool {
        isAuthorized || isSkipped
    }

    func register(profile: SCPWorkerProfile) {
        self.profile = profile
        self.isSkipped = false
        saveProfile(profile)
        defaults.set(false, forKey: skipKey)
    }

    func signInOnline(accountID: String, password: String) async throws {
        let cleanedAccountID = accountID.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedAccountID.isEmpty else {
            throw AuthStoreError.invalidAccountID
        }
        guard !cleanedPassword.isEmpty else {
            throw AuthStoreError.emptyPassword
        }

        var request = URLRequest(url: Self.loginURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = OnlineLoginPayload(
            username: cleanedAccountID,
            password: cleanedPassword
        )
        request.httpBody = try JSONEncoder().encode(payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthStoreError.serverUnavailable
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw AuthStoreError.invalidCredentials
            }

            let login = try JSONDecoder().decode(OnlineLoginResponse.self, from: data)
            let fullName = [login.firstName, login.lastName]
                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: " ")

            let profile = SCPWorkerProfile(
                name: fullName.isEmpty ? cleanedAccountID : fullName,
                email: login.email,
                workerId: login.username?.isEmpty == false ? (login.username ?? cleanedAccountID) : cleanedAccountID,
                department: "Не указано",
                site: "Не указано",
                clearance: .level2
            )
            register(profile: profile)
        } catch let error as AuthStoreError {
            throw error
        } catch is DecodingError {
            throw AuthStoreError.invalidCredentials
        } catch {
            throw AuthStoreError.networkFailure
        }
    }

    func registerOnline(profile: SCPWorkerProfile, password: String) async throws {
        let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanedPassword.count >= 6 else {
            throw AuthStoreError.weakPassword
        }

        guard let email = profile.email?.trimmingCharacters(in: .whitespacesAndNewlines),
              isValidEmail(email) else {
            throw AuthStoreError.invalidEmail
        }

        let nameParts = profile.name.split(separator: " ", maxSplits: 1).map(String.init)
        let firstName = nameParts.first?.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = nameParts.count > 1 ? nameParts[1].trimmingCharacters(in: .whitespacesAndNewlines) : "SCP"

        guard let firstName, !firstName.isEmpty else {
            throw AuthStoreError.invalidName
        }

        var request = URLRequest(url: Self.registrationURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = OnlineRegistrationPayload(
            firstName: firstName,
            lastName: lastName,
            email: email,
            username: profile.workerId.lowercased(),
            password: cleanedPassword
        )
        request.httpBody = try JSONEncoder().encode(payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthStoreError.serverUnavailable
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw AuthStoreError.registrationRejected
            }

            _ = try? JSONDecoder().decode(OnlineRegistrationResponse.self, from: data)
            register(profile: profile)
        } catch let error as AuthStoreError {
            throw error
        } catch {
            throw AuthStoreError.networkFailure
        }
    }

    func skipAuthorization() {
        isSkipped = true
        defaults.set(true, forKey: skipKey)
    }

    func resetAuthorization() {
        profile = nil
        isSkipped = false
        defaults.removeObject(forKey: profileKey)
        defaults.set(false, forKey: skipKey)
    }

    private func saveProfile(_ profile: SCPWorkerProfile) {
        guard let data = try? JSONEncoder().encode(profile) else {
            return
        }
        defaults.set(data, forKey: profileKey)
    }

    private static func loadProfile(defaults: UserDefaults, key: String) -> SCPWorkerProfile? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(SCPWorkerProfile.self, from: data)
    }

    private func isValidEmail(_ value: String) -> Bool {
        value.contains("@") && value.contains(".")
    }
}

private struct OnlineRegistrationPayload: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let username: String
    let password: String
}

private struct OnlineRegistrationResponse: Codable {
    let id: Int?
}

private struct OnlineLoginPayload: Codable {
    let username: String
    let password: String
}

private struct OnlineLoginResponse: Codable {
    let firstName: String?
    let lastName: String?
    let username: String?
    let email: String?
}

enum AuthStoreError: LocalizedError {
    case invalidName
    case invalidEmail
    case invalidAccountID
    case emptyPassword
    case weakPassword
    case invalidCredentials
    case serverUnavailable
    case registrationRejected
    case networkFailure

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Введи корректное имя."
        case .invalidEmail:
            return "Введи корректный email."
        case .invalidAccountID:
            return "Введи ID аккаунта."
        case .emptyPassword:
            return "Введи пароль."
        case .weakPassword:
            return "Пароль должен быть минимум 6 символов."
        case .invalidCredentials:
            return "Неверный аккаунт или пароль."
        case .serverUnavailable:
            return "Сервер сейчас недоступен."
        case .registrationRejected:
            return "Регистрация отклонена сервером."
        case .networkFailure:
            return "Ошибка сети. Проверь интернет и попробуй ещё раз."
        }
    }
}
