import MoyaSugar

enum UserAPI {
  case search(page: Int, name: String)
}

extension UserAPI: SugarTargetType {
  var baseURL: URL {
    URL(string: "https://api.github.com")!
  }

  var headers: [String: String]? {
    ["Accept": "application/vnd.github.v3+json"]
  }

  var route: Route {
    switch self {
    case .search:
      return .get("/search/users")
    }
  }

  var parameters: Parameters? {
    switch self {
    case let .search(page, name):
      return [
        "q": "\(name) in:login", "page": page, "per_page": 100, "sort": "login", "order": "asc"
      ]
    }
  }

  var sampleData: Data {
    Data()
  }
}
