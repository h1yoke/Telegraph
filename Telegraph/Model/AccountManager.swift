import Foundation
import UIKit

/// Account saving/loading manager single-tone.
class AccountManager {
    /// Internal Account wrapper class.
    fileprivate class Account {
        /// Core Data UUID for account.
        let uuid: UUID
        /// Account instance.
        var account: Telegraph.Account

        /// Clears account access token.
        /// - parameter account: Telegraph account.
        /// - returns: cleared Telegraph account.
        private func clearToken(_ account: Telegraph.Account) -> Telegraph.Account {
            return Telegraph.Account(
                shortName: account.shortName,
                authorName: account.authorName,
                authorUrl: account.authorUrl,
                accessToken: nil,
                authUrl: account.authUrl,
                pageCount: account.pageCount)
        }

        /// Initializes `self` via Telegraph.Account and add it to keychain.
        /// - parameter account: new account.
        init(account: Telegraph.Account) {
            self.account = account
            self.uuid = UUID()

            guard let token = account.accessToken else {
                return
            }
            Keychain.add(key: self.uuid.uuidString, value: token)
            CoreData.save(uuid: uuid, account: clearToken(account))
            print(self.uuid)
        }

        /// Initializes `self` with existed Telegraph.Account by loading it from keychain.
        /// - parameter uuid: account uuid.
        /// - parameter account: telegraph account.
        init(uuid: UUID, account: Telegraph.Account) {
            self.uuid = uuid
            self.account = {
                var tmp = account
                tmp.accessToken = Keychain.copy(key: uuid.uuidString)
                return tmp
            }()
        }

        /// Updates keychain registry.
        /// - parameter account: new account.
        func update(account: Telegraph.Account) {
            if let token = account.accessToken, token != self.account.accessToken {
                Keychain.update(key: uuid.uuidString, newValue: token)
            }
            self.account.accessToken = account.accessToken
            self.account.authUrl = account.authUrl
        }

        /// Deletes keychain registry.
        func delete() {
            Keychain.delete(key: uuid.uuidString)
        }
    }

    /// Single-tone instance.
    static let shared = AccountManager()
    /// Loades all saved accounts.
    init() {
        let data = CoreData.fetch()
        accounts = []
        data.forEach {
            if let loadedAccount = $0 {
                accounts.append(Account(uuid: loadedAccount.0, account: loadedAccount.1))
            }
        }
    }

    /// Accounts array.
    private var accounts = [Account]()
    /// *Current* account ID.
    private var currentId = -1

    /// Accounts count.
    var count: Int { accounts.count }
    /// Current account.
    var current: Telegraph.Account? {
        get {
            if 0..<count ~= currentId {
                return accounts[currentId].account
            }
            return nil
        }
        set {
            if let newValue = newValue {
                accounts[currentId].account = newValue
            }
        }
    }

    /// Adds new account to program.
    /// Requiers `access_token` and to be valid.
    /// - parameter account: account to be added.
    /// - returns: `true` if success, `false` othrewise.
    @discardableResult
    func add(account: Telegraph.Account) -> Bool {
        guard account.accessToken != nil else { return false }
        accounts.append(Account(account: account))
        return true
    }

    /// Returns *current* account.
    /// - parameter account: account to be added.
    /// - returns: `true` if success, `false` othrewise.
    func get(by id: Int) -> Telegraph.Account? {
        return accounts[id].account
    }

    /// Selects *current* account with ID.
    /// - parameter by id: account id to be selected.
    /// - returns: `true` if success, `false` othrewise.
    @discardableResult
    func select(by id: Int) -> Bool {
        if id < count {
            currentId = id
            return true
        }
        return false
    }

    /// Replaces account with updated one.
    /// - parameter by id: account id to be updated.
    /// - parameter newAccount: new account.
    /// - returns: `true` if success, `false` othrewise.
    @discardableResult
    func edit(by id: Int, newAccount: Telegraph.Account) -> Bool {
        guard newAccount.accessToken != nil else { return false }
        accounts[id].update(account: newAccount)
        return true
    }

    /// Reloads account from Telegraph API server.
    /// - parameter by id: account id to be updated.
    /// - parameter complition: closure that will be executed after server response.
    func update(by id: Int, complition: @escaping (Telegraph.Account?) -> Void) {
        guard let token = accounts[id].account.accessToken else {
            return
        }

        let method = Telegraph.Method.getAccountInfo(accessToken: token,
            fields: ["short_name", "author_name", "author_url", "auth_url", "page_count"])
        let success: (Telegraph.Account) -> Void = { self.accounts[id].account = $0; complition($0) }
        let failure: (String) -> Void = { print($0) }

        try? Telegraph.query(method: method, completion: { (response: Telegraph.Response<Telegraph.Account>) in
                Telegraph.unwrapResponse(response, success: success, failure: failure)
        })
    }
}
