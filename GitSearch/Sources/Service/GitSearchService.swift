import Foundation
import RxSwift

protocol GitSearchServiceType {
  func search(page: Int, name: String) -> Single<[User]>
  func appendFavoriteUser(_ users: [User], target user: User) -> Single<[User]>
  func removeFavoriteUser(_ users: [User], target user: User) -> Single<[User]>
}

final class RemoteGitSearchService: GitSearchServiceType {

  private let networking: NetworkingProtocol

  init(networking: NetworkingProtocol) {
    self.networking = networking
  }

  func search(page: Int, name: String) -> Single<[User]> {
    guard name.isNotEmpty
    else {
      return Single.just([])
    }

    return networking
      .request(UserAPI.search(page: page, name: name))
      .map(UserResponse.self)
      .flatMap {
        var users = $0.items

        let localUsers = CoreDataManager.shared.getUsers()

        users = users.map { user in
          let findUser = localUsers.first { $0.id == user.id }
          user.favorite = (findUser != nil)
          return user
        }

        return Single.just(users)
      }
  }

  func appendFavoriteUser(_ users: [User], target user: User) -> Single<[User]> {
    let result = users

    if let index = users.firstIndex(where: { $0.id == user.id }) {
      result[index].favorite = true
    }

    return .just(result)
  }

  func removeFavoriteUser(_ users: [User], target user: User) -> Single<[User]> {
    let result = users

    if let index = users.firstIndex(where: { $0.id == user.id }) {
      result[index].favorite = false
    }

    return .just(result)
  }
}

final class LocalGitSearchService: GitSearchServiceType {

  func search(page: Int, name: String) -> Single<[User]> {
    let users = CoreDataManager.shared.getUsers()
      .map {
        User(id: Int($0.id), name: $0.name, avatarURLString: $0.avatarUrl, favorite: true)
      }

    return .just(users)
  }

  func appendFavoriteUser(_ users: [User], target user: User) -> Single<[User]> {
    var result = users

    if users.firstIndex(where: { $0.id == user.id }) == nil  {
      result.append(user)
      result = result.sorted(by: { $0.sortName < $1.sortName })

      // Save CoreData
      saveUser(users, target: user)
    }

    return .just(result)
  }

  func removeFavoriteUser(_ users: [User], target user: User) -> Single<[User]> {
    var result = users

    if let user = result.first(where: { $0.id == user.id }) {
      result = result.filter { $0.id != user.id }

      // remove CoreData
      deleteUser(users, target: user)
    }

    return .just(result)
  }

  // MARK: CoreData

  private func saveUser(_ users: [User], target user: User) {
    CoreDataManager.shared.saveUser(
      id: Int64(user.id),
      name: user.name ?? "",
      avatarUrl: user.avatarURL?.absoluteString ?? ""
    ) { success in
      if !success {
        User.Event.removeFavoriteUser(user)
        self.appendFavoriteUser(users, target: user)
      }
    }
  }

  private func deleteUser(_ users: [User], target user: User) {
    CoreDataManager.shared.deleteUser(
      id: Int64(user.id)
    ) { success in
      if !success {
        User.Event.appendFavoriteUser(user)
        self.removeFavoriteUser(users, target: user)
      }
    }
  }
}
