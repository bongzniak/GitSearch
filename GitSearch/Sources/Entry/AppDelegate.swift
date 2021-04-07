import UIKit

import CoreData

class AppDelegate: UIResponder, UIApplicationDelegate {

  private let dependency: AppDependency

  private override init() {
    dependency = AppDependency.resolve()
    super.init()
  }

  init(dependency: AppDependency) {
    self.dependency = dependency
  }

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    window = dependency.window.then {
      $0.frame = UIScreen.main.bounds
      $0.backgroundColor = .black
      $0.makeKeyAndVisible()
    }
    return true
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoreData")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}
