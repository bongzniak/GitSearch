//
// Created by bongzniak on 2021/04/07.
//

import UIKit
import CoreData

class CoreDataManager {
  static let shared: CoreDataManager = CoreDataManager()

  let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
  lazy var context = appDelegate?.persistentContainer.viewContext

  let modelName: String = "Users"

  func getUsers(name: String? = nil) -> [UserCoreData] {
    var models: [UserCoreData] = []

    if let context = context {
      let fetchRequest = filteredRequest(with: name)
      do {
        if let fetchResult: [UserCoreData] = try context.fetch(fetchRequest) as? [UserCoreData] {
          models = fetchResult
        }
      } catch let error as NSError {
        print("Could not fetch🥺: \(error), \(error.userInfo)")
      }
    }

    return models
  }

  func saveUser(
    id: Int64,
    name: String,
    avatarUrl: String,
    onSuccess: @escaping (Bool) -> Void
  ) {
    if let context = context,
       let entity = NSEntityDescription.entity(forEntityName: modelName, in: context) {

      if let user: UserCoreData = NSManagedObject(
        entity: entity,
        insertInto: context
      ) as? UserCoreData {
        user.id = id
        user.name = name
        user.avatarUrl = avatarUrl

        contextSave { success in
          onSuccess(success)
        }
      }
    }
  }

  func deleteUser(id: Int64, onSuccess: @escaping (Bool) -> Void) {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(with: id)

    do {
      if let results: [UserCoreData] = try context?.fetch(fetchRequest) as? [UserCoreData] {
        if results.count != 0 {
          context?.delete(results[0])
        }
      }
    } catch let error as NSError {
      print("Could not fatch🥺: \(error), \(error.userInfo)")
      onSuccess(false)
    }

    contextSave { success in
      onSuccess(success)
    }
  }
}

extension CoreDataManager {
  fileprivate func filteredRequest(with id: Int64) -> NSFetchRequest<NSFetchRequestResult> {
    NSFetchRequest<NSFetchRequestResult>(entityName: modelName).then {
      $0.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
    }
  }

  fileprivate func filteredRequest(
    with name: String? = nil
  ) -> NSFetchRequest<NSFetchRequestResult> {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: modelName).then {
      $0.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
    }
    if let name = name {
      fetchRequest.predicate = NSPredicate(format: "name LIKE %@", name)
    }

    return fetchRequest
  }

  fileprivate func contextSave(onSuccess: (Bool) -> Void) {
    do {
      try context?.save()
      onSuccess(true)
    } catch let error as NSError {
      print("Could not save🥶: \(error), \(error.userInfo)")
      onSuccess(false)
    }
  }
}
