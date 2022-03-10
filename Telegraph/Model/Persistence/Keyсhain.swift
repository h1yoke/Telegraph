import Foundation

/// `Keychain` wrapper enumeration.
enum Keychain {
    /// Adds registry to `Keychain` via key-value pair.
    /// - parameter key: registry search key.
    /// - parameter value: stored value.
    /// - returns: `true` if succeeded, `false` otherwise.
    @discardableResult
    static func add(key: String, value: String) -> Bool {
        guard let keyData = key.data(using: .utf8),
              let valueData = value.data(using: .utf8)
        else {
            return false
        }
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyData,
            kSecValueData: valueData
        ] as CFDictionary
        return SecItemAdd(query, nil) == errSecSuccess
    }

    /// Deletes registry from `Keychain` via key.
    /// - parameter key: registry search key.
    /// - returns: `true` if succeeded, `false` otherwise.
    @discardableResult
    static func delete(key: String) -> Bool {
        guard let keyData = key.data(using: .utf8) else {
            return false
        }
        let query = [
             kSecClass: kSecClassGenericPassword,
             kSecAttrAccount: keyData
        ] as CFDictionary
        return SecItemDelete(query) == errSecSuccess
    }

    /// Updates registry from `Keychain` via key-value pair.
    /// - parameter key: registry search key.
    /// - parameter newValue: new stored value.
    /// - returns: `true` if succeeded, `false` otherwise.
    @discardableResult
    static func update(key: String, newValue: String) -> Bool {
        guard let keyData = key.data(using: .utf8),
              let valueData = newValue.data(using: .utf8)
        else {
            return false
        }
        let query = [
             kSecClass: kSecClassGenericPassword,
             kSecAttrAccount: keyData
        ] as CFDictionary
        let updateFields = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyData,
            kSecValueData: valueData
        ] as CFDictionary
        return SecItemUpdate(query, updateFields) == errSecSuccess
    }

    /// Loads registry from `Keychain` via key.
    /// - parameter key: registry search key.
    /// - returns: loaded registry
    @discardableResult
    static func copy(key: String) -> String? {
        guard let keyData = key.data(using: .utf8) else {
            return nil
        }
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyData,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary
        var reference: AnyObject?
        guard SecItemCopyMatching(query, &reference) == errSecSuccess,
              let result = reference as? NSDictionary,
              let loadedData = result[kSecValueData] as? Data
        else {
            return nil
        }
        return String(decoding: loadedData, as: UTF8.self)
    }
}
