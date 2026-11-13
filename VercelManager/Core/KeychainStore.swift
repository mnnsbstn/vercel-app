import Foundation
import Security

enum KeychainStore {
    private static let service = "com.mnnsbstn.vercelmanager"
    private static let account = "vercel-personal-access-token"

    enum Failure: LocalizedError {
        case status(OSStatus)

        var errorDescription: String? {
            "Der Token konnte nicht sicher gespeichert werden (Keychain: \(code))."
        }

        private var code: OSStatus {
            if case .status(let status) = self { return status }
            return errSecSuccess
        }
    }

    static func read() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    static func save(_ token: String) throws {
        delete()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: Data(token.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let result = SecItemAdd(query as CFDictionary, nil)
        guard result == errSecSuccess else {
            throw Failure.status(result)
        }
    }

    static func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
