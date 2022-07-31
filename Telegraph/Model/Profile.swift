import UIKit
import Foundation

class Profile {
    // Profile storable UUID
    var uuid: UUID

    // Profile API data
    var accessToken: String
    var shortName: String?
    var authorName: String?
    var authorUrl: String?
    var authUrl: String?
    var pageCount: Int?

    // Profile local data
    var profileImage: UIImage?

    /// Translate all Telegraph data to Profile
    private func translateAccount(account: Telegraph.Account) {
        self.shortName = account.shortName
        self.authorUrl = account.authorUrl
        self.authorName = account.authorName
        self.authUrl = account.authUrl
        self.pageCount = account.pageCount
    }

    /// Initialize Profile via Telegraph account and its UUID.
    ///
    /// Purpose: Transfers all loaded data to Profile and recieves its access token.
    init?(existingAccount: Telegraph.Account, with uuid: UUID) {
        guard let token = Keychain.copy(key: uuid.uuidString) else {
            return nil
        }
        self.uuid = uuid
        self.accessToken = token
        translateAccount(account: existingAccount)
    }

    /// Initialize Profile via Telegraph account.
    ///
    /// Purpose: Transfers all user-collected data to Profile after Telegraph API account verification.
    init?(newAccount: Telegraph.Account) {
        guard let token = newAccount.accessToken else {
            return nil
        }
        self.uuid = UUID()
        self.accessToken = token
        translateAccount(account: newAccount)
    }

    /// Save all account information on device.
    func save() {
        Keychain.add(key: uuid.uuidString, value: accessToken)
        CoreData.save(uuid: uuid, profile: self)
    }

    /// Deletes all account information from device.
    func delete() {
        Keychain.delete(key: uuid.uuidString)
        CoreData.delete(uuid: uuid)
    }

    /// Update access token.
    func updateToken(token: String) {
        if token != self.accessToken {
            Keychain.update(key: uuid.uuidString, newValue: token)
            self.accessToken = token
        }
    }

    func updateImage(image: UIImage) {
        self.profileImage = image
        CoreData.update(uuid: self.uuid, profile: self)
    }
}
