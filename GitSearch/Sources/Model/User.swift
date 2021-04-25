import Foundation

class UserResponse: ModelType {
  enum Event {
  }

  var totalCount: Int
  var incompleteResults: Bool
  var items: [User]

  enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case incompleteResults = "incomplete_results"
    case items
  }
}

class User: ModelType {
  enum Event {
    case appendFavoriteUser(User)
    case removeFavoriteUser(User)
  }

  var id: Int
  var name: String?
  var avatarURL: URL?
  var favorite: Bool = false

  var sortName: String {
    (name ?? "").lowercased()
  }

  init(
    id: Int,
    name: String?,
    avatarURLString: String?,
    favorite: Bool = false
  ) {
    self.id = id
    self.name = name
    avatarURL = URL(string: avatarURLString ?? "")
    self.favorite = favorite
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name = "login"
    case avatarURL = "avatar_url"
  }
}
