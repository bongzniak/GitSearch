import Pure
import PureSwinject

struct AppDependency {
  let window: UIWindow
}

extension AppDependency {
  private static let container = Container()

  static func resolve() -> AppDependency {

    let window = UIWindow()

    // User Cell Node
    container.register(UserCellNode.Factory.self) { _ in
      UserCellNode.Factory(dependency: .init(
        reactorFactory: { (user: User) -> UserCellNodeReactor in
          UserCellNodeReactor(user: user)
        }
      ))
    }

    let network = Networking(plugins: [LoggingPlugin()])

    // Remote Search View Controller
    let remoteGitService = RemoteGitSearchService(networking: network)
    let remoteGitSearchViewController = GitSearchViewController(
      dependency: .init(
        reactor: GitSearchViewReactor(service: remoteGitService),
        userCellNodeFactory: container.resolve(UserCellNode.Factory.self)!
      ),
      payload: .init(segmentedItem: "Remote")
    )

    // Local Search View Controller
    let localGitService = LocalGitSearchService()
    let localGitSearchViewController = GitSearchViewController(
      dependency: .init(
        reactor: GitSearchViewReactor(service: localGitService),
        userCellNodeFactory: container.resolve(UserCellNode.Factory.self)!
      ),
      payload: .init(segmentedItem: "Local")
    )

    // Container View Controller
    let containerViewController = ContainerViewController(
      dependency: .init(
        reactor: ContainerViewReactor(),
        gitSearchControllers: [remoteGitSearchViewController, localGitSearchViewController]
      )
    )

    // Navigation Controller
    let navigationController = UINavigationController(
      rootViewController: containerViewController
    ).then {
      $0.navigationBar.prefersLargeTitles = true
    }

    window.rootViewController = navigationController

    return AppDependency(
      window: window
    )
  }
}
