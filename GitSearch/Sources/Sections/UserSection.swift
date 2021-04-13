import RxDataSources_Texture

enum UserSection {
  case user(title: String, items: [UserSectionItem])
}

extension UserSection: AnimatableSectionModelType {

  typealias Identity = String

  var identity: String {
    switch self {
    case .user:
      return "user"
    }
  }

  var items: [UserSectionItem] {
    switch self {
    case let .user(_, items):
      return items
    }
  }

  var title: String {
    switch self {
    case let .user(title, _):
      return title
    }
  }

  init(original: UserSection, items: [UserSectionItem]) {
    switch original {
    case let .user(title, items):
      self = .user(title: title, items: items)
    }
  }
}

enum UserSectionItem {
  case user(User)
}

extension UserSectionItem: IdentifiableType {
  typealias Identity = Int

  var identity: Int {
    switch self {
    case let .user(user):
      return user.id
    }
  }
}

extension UserSectionItem: Equatable {
  static func == (lhs: UserSectionItem, rhs: UserSectionItem) -> Bool {
    lhs.identity == rhs.identity
  }
}
