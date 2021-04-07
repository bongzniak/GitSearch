//
// Created by bongzniak on 2021/04/07.
//

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

class User: NSObject, ModelType {
  enum Event {
    case addFavoriteUser(user: User)
    case removeFavoriteUser(userID: Int)
  }

  var id: Int
  var name: String?
  var avatarURL: String?

  init(
    id: Int,
    name: String?,
    avatarURL: String?
  ) {
    self.id = id
    self.name = name
    self.avatarURL = avatarURL
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name = "login"
    case avatarURL = "avatar_url"
  }
}
