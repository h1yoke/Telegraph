import UIKit
import CoreData

/// `CoreData` wrapper enumeration
enum CoreData {
    /// Saves account entry.
    /// - parameter uuid: account internal UUID.
    /// - parameter account: saved account.
    /// - returns: nothing.
    static func save(uuid: UUID, account: Telegraph.Account) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Account", in: managedContext)!
        let acc = NSManagedObject(entity: entity, insertInto: managedContext)

        acc.setValue(uuid, forKey: "uuid")
        acc.setValue(account.shortName, forKey: "shortName")
        acc.setValue(account.authorName, forKey: "authorName")
        acc.setValue(account.authorUrl, forKey: "authorUrl")
        acc.setValue(account.pageCount, forKey: "pageCount")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    /// Deletes account entry.
    /// - parameter uuid: account internal UUID.
    /// - returns: operation success.
    @discardableResult
    static func delete(uuid: UUID) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")

        guard let accounts = try? managedContext.fetch(fetchRequest) else {
            return false
        }

        for account in accounts {
            if let id = account.value(forKey: "uuid") as? UUID, uuid == id {
                managedContext.delete(account)

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

    /// Loades all saved entries.
    /// - returns: UUID, Account pairs.
    static func fetch() -> [(UUID, Telegraph.Account)?] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")

        guard let accounts = try? managedContext.fetch(fetchRequest) else {
            return []
        }
        return accounts.map {
            guard let uuid = $0.value(forKey: "uuid") as? UUID,
                  let shortName = $0.value(forKey: "shortName") as? String else {
                      return nil
            }

            return (uuid, Telegraph.Account(
                shortName: shortName,
                authorName: $0.value(forKey: "authorName") as? String,
                authorUrl: $0.value(forKey: "authorUrl") as? String,
                pageCount: $0.value(forKey: "pageCount") as? Int)
            )
        }
    }
}
