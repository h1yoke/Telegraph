import Foundation
import UIKit

/// Profile saving/loading manager single-tone.
class ProfileManager {
    /// Profile manager single-tone instance.
    static let shared = ProfileManager()

    /// Default initializer.
    ///
    /// Loades all stored profiles from Core Data.
    private init() {
        let data = CoreData.fetch()
        profiles = []
        data.forEach {
            if let loadedProfile = $0 {
                profiles.append(loadedProfile)
            }
        }
    }

    /// Operating profiles array.
    private var profiles = [Profile]()
    /// *Current* profile ID. Can be selected by `select(id: Int)` method.
    private var currentId = -1

    /// Operating profiles count.
    var count: Int { profiles.count }
    /// *Current* profile selected by `select(id: Int)` method.
    var current: Profile? {
        get {
            if 0..<count ~= currentId {
                return profiles[currentId]
            }
            return nil
        }
        set {
            // swaps current profile, or creates first one
            if let newValue = newValue {
                if currentId == -1 {
                    profiles.append(newValue)
                    currentId = 0
                } else {
                    profiles[currentId] = newValue
                }
            }
        }
    }

    /// Adds a new profile to the system.
    /// - parameter profile: profile to be added.
    /// - returns: `true` if success, `false` othrewise.
    @discardableResult
    func add(profile: Profile) -> Bool {
        profiles.append(profile)
        profile.save()
        return true
    }

    /// Returns a profile by an id in array.
    /// - parameter profile: profile to be found.
    /// - returns: `true` if success, `false` othrewise.
    func get(id: Int) -> Profile {
        return profiles[id]
    }

    /// Selects *current* profile by its ID.
    /// - parameter by id: profile id to be selected.
    /// - returns: `true` if success, `false` othrewise.
    @discardableResult
    func select(id: Int) -> Bool {
        if id < count {
            currentId = id
            return true
        }
        return false
    }

    /// Replaces profile with updated one.
    /// - parameter by id: profile id to be updated.
    /// - parameter newProfile: new profile.
    /// - returns: `true` if success, `false` othrewise.
    @discardableResult
    func edit(id: Int, newProfile: Profile) -> Bool {
        /// TODO: update other things
        profiles[id].updateToken(token: newProfile.accessToken)
        return true
    }

    /// Deletes profile by its id.
    /// - parameter by id: profile id
    func delete(id: Int) {
        profiles[id].delete()

        var last = id
        for cur in id + 1..<count {
            profiles[last] = profiles[cur]
            last = cur
        }
        _ = profiles.popLast()
    }
}
