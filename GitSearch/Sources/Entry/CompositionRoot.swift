import Pure
import PureSwinject

struct AppDependency {
  let window: UIWindow
}

extension AppDependency {
  private static let container = Container()

  static func resolve() -> AppDependency {
    let window = UIWindow()
    container.register(UIWindow.self) { _ in  window }

    let remoteGitSearchService: GitSearchServiceType = RemoteGitSearchService(
      networking: Networking(plugins: [LoggingPlugin()])
    )
    let remoteGitSearchViewController = GitSearchViewController(
      dependency: .init(reactor: GitSearchViewReactor(service: remoteGitSearchService))
    )

    window.rootViewController = remoteGitSearchViewController

    return AppDependency(
      window: window
    )
  }
}
