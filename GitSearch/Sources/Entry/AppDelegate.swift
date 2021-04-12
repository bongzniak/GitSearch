import UIKit
import CoreData

class AppDelegate: UIResponder, UIApplicationDelegate {

  private let dependency: AppDependency

  // MARK: - CoreData

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Model")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

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
}
