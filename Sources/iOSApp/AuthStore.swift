import Foundation
import Combine

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
    private static var supabaseURL: URL? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              !raw.isEmpty else { return nil }
        return URL(string: raw)
    }

    private static var supabaseAnonKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
              !value.isEmpty else { return nil }
        return value
    }

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

        guard let supabaseURL = Self.supabaseURL,
              let anonKey = Self.supabaseAnonKey else {
            throw AuthStoreError.serverUnavailable
        }

        var request = URLRequest(url: supabaseURL.appendingPathComponent("auth/v1/token")
            .appending(queryItems: [URLQueryItem(name: "grant_type", value: "password")]))
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")

        let payload = SupabasePasswordPayload(email: cleanedAccountID, password: cleanedPassword)
        request.httpBody = try JSONEncoder().encode(payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthStoreError.serverUnavailable
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw AuthStoreError.invalidCredentials
            }

            let profile = SCPWorkerProfile(
                name: cleanedAccountID,
                email: cleanedAccountID,
                workerId: cleanedAccountID,
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

    func registerOnline(profile: SCPWorkerProfile, password: String, allowO5Invite: Bool = false) async throws {
        if profile.clearance == .level5 && !allowO5Invite {
            throw AuthStoreError.o5LinkRequired
        }
        let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanedPassword.count >= 6 else {
            throw AuthStoreError.weakPassword
        }

        guard let email = profile.email?.trimmingCharacters(in: .whitespacesAndNewlines),
              isValidEmail(email) else {
            throw AuthStoreError.invalidEmail
        }

        guard !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthStoreError.invalidName
        }

        guard let supabaseURL = Self.supabaseURL,
              let anonKey = Self.supabaseAnonKey else {
            throw AuthStoreError.serverUnavailable
        }

        var request = URLRequest(url: supabaseURL.appendingPathComponent("auth/v1/signup"))
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")

        let payload = SupabaseSignupPayload(
            email: email,
            password: cleanedPassword,
            data: [
                "display_name": profile.name,
                "worker_id": profile.workerId,
                "department": profile.department,
                "site": profile.site,
                "clearance": profile.clearance.rawValue
            ]
        )
        request.httpBody = try JSONEncoder().encode(payload)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthStoreError.serverUnavailable
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw AuthStoreError.registrationRejected
            }

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

private struct SupabaseSignupPayload: Codable {
    let email: String
    let password: String
    let data: [String: String]
}

private struct SupabasePasswordPayload: Codable {
    let email: String
    let password: String
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
    case o5LinkRequired

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
        case .o5LinkRequired:
            return "Для допуска O5 нужна действующая уникальная ссылка администратора."
        }
    }
}


// MARK: - O5 registration links

struct O5RegistrationLink: Codable, Identifiable, Hashable {
    let id: UUID
    let token: String
    let createdAt: Date
    let expiresAt: Date
    let issuedBy: String
    var usedAt: Date?

    var isExpired: Bool { Date() >= expiresAt }
    var isUsable: Bool { usedAt == nil && !isExpired }
    var url: URL {
        var components = URLComponents()
        components.scheme = "scpfoundation"
        components.host = "admin"
        components.path = "/register"
        components.queryItems = [URLQueryItem(name: "token", value: token)]
        return components.url!
    }
}

@MainActor
final class O5RegistrationLinkStore: ObservableObject {
    @Published private(set) var links: [O5RegistrationLink] = []

    private let defaults: UserDefaults
    private let storageKey = "scp_o5_registration_links_v1"
    private let lifetime: TimeInterval = 15 * 60

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.links = Self.load(defaults: defaults, key: storageKey)
    }

    var activeLinks: [O5RegistrationLink] {
        links.filter(\.isUsable)
    }

    func issueLink(issuedBy profile: SCPWorkerProfile) -> O5RegistrationLink? {
        guard profile.clearance == .level5 else { return nil }
        let now = Date()
        let link = O5RegistrationLink(
            id: UUID(),
            token: Self.secureToken(),
            createdAt: now,
            expiresAt: now.addingTimeInterval(lifetime),
            issuedBy: profile.workerId,
            usedAt: nil
        )
        links.insert(link, at: 0)
        save()
        return link
    }

    func consume(token: String) -> O5RegistrationLink? {
        guard let index = links.firstIndex(where: { $0.token == token && $0.isUsable }) else {
            return nil
        }
        links[index].usedAt = Date()
        save()
        return links[index]
    }

    func link(for token: String) -> O5RegistrationLink? {
        links.first { $0.token == token && $0.isUsable }
    }

    func revoke(_ link: O5RegistrationLink) {
        links.removeAll { $0.id == link.id }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(links) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private static func load(defaults: UserDefaults, key: String) -> [O5RegistrationLink] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([O5RegistrationLink].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func secureToken() -> String {
        UUID().uuidString.replacingOccurrences(of: "-", with: "")
            + UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
}
