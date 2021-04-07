import MoyaSugar

enum UserAPI {
  case search(page: Int, name: String)
}

extension UserAPI: SugarTargetType {
  var baseURL: URL {
    URL(string: "https://api.github.com/search/users")!
  }

  var headers: [String: String]? {
    ["Accept": "application/vnd.github.v3+json"]
  }

  var route: Route {
    switch self {
    case let .search(_, name):
      return .get("")
    }
  }

  var parameters: Parameters? {
    switch self {
    case let .search(page, name):
      return ["q": name]
    }
  }

  var sampleData: Data {
    Data()
  }
}
