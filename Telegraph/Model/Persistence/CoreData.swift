import UIKit
import CoreData

/// `CoreData` wrapper enumeration
enum CoreData {
    /// Saves profile entry.
    /// - parameter uuid: profile internal UUID.
    /// - parameter profile: saved profile.
    /// - returns: operation success.
    @discardableResult
    static func save(uuid: UUID, profile: Profile) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Profile", in: managedContext)!
        let saved = NSManagedObject(entity: entity, insertInto: managedContext)

        saved.setValue(uuid, forKey: "uuid")
        saved.setValue(profile.shortName, forKey: "shortName")
        saved.setValue(profile.authorName, forKey: "authorName")
        saved.setValue(profile.authorUrl, forKey: "authorUrl")
        saved.setValue(profile.pageCount, forKey: "pageCount")
        saved.setValue(profile.profileImage?.jpegData(compressionQuality: 1.0), forKey: "profileImage")

        do {
            try managedContext.save()
            return true
        } catch {
            return false
        }
    }

    /// Deletes profile entry.
    /// - parameter uuid: profile internal UUID.
    /// - returns: operation success.
    @discardableResult
    static func delete(uuid: UUID) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")

        guard let profiles = try? managedContext.fetch(fetchRequest) else {
            return false
        }

        for profile in profiles {
            if let id = profile.value(forKey: "uuid") as? UUID, uuid == id {
                managedContext.delete(profile)

                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    return false
                }
                return true
            }
        }
        return false
    }

    /// Updates profile entry.
    /// - parameter uuid: profile internal UUID.
    /// - returns: operation success.
    @discardableResult
    static func update(uuid: UUID, profile: Profile) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "uuid", uuid as CVarArg)

        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count == 1 {
                results?[0].setValue(profile.uuid, forKey: "uuid")
                results?[0].setValue(profile.shortName, forKey: "shortName")
                results?[0].setValue(profile.authorName, forKey: "authorName")
                results?[0].setValue(profile.authorUrl, forKey: "authorUrl")
                results?[0].setValue(profile.pageCount, forKey: "pageCount")
                results?[0].setValue(profile.profileImage?.jpegData(compressionQuality: 1.0), forKey: "profileImage")
            }
        } catch {
            return false
        }

        do {
            try managedContext.save()
        } catch {
            return false
        }
        return true
    }

    /// Loades all saved entries.
    /// - returns: Loaded profiles.
    static func fetch() -> [Profile?] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")

        guard let profiles = try? managedContext.fetch(fetchRequest) else {
            return []
        }
        return profiles.map {
            guard let uuid = $0.value(forKey: "uuid") as? UUID else {
                return nil
            }

            let profile = Profile(existingAccount:
            Telegraph.Account(
                shortName: $0.value(forKey: "shortName") as? String,
                authorName: $0.value(forKey: "authorName") as? String,
                authorUrl: $0.value(forKey: "authorUrl") as? String,
                pageCount: $0.value(forKey: "pageCount") as? Int),
            with: uuid)

            if let imageData = $0.value(forKey: "profileImage") as? Data {
                profile?.profileImage = UIImage(data: imageData)
            }
            return profile
        }
    }
}
