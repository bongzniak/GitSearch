//
// Created by bongzniak on 2021/04/07.
//

import Foundation
import RxSwift

protocol GitSearchServiceType {
  func search(page: Int, name: String) -> Single<[User]>
  func addFavoriteUser(user: User) -> Single<Void>
  func removeFavoriteUser(userID: Int) -> Single<Void>
}

final class RemoteGitSearchService: GitSearchServiceType {

  private let networking: NetworkingProtocol

  init(networking: NetworkingProtocol) {
    self.networking = networking
  }

  func search(page: Int, name: String) -> Single<[User]> {
    networking
      .request(UserAPI.search(page: page, name: name))
      .map(UserResponse.self)
      .flatMap {
        Single.just($0.items)
      }
  }

  func addFavoriteUser(user: User) -> Single<Void> {
    User.event.onNext(.addFavoriteUser(user: user))
    return .just(())
  }

  func removeFavoriteUser(userID: Int) -> Single<Void> {
    User.event.onNext(.removeFavoriteUser(userID: userID))
    return .just(())
  }
}

final class LocalGitSearchService: GitSearchServiceType {

  private let coreDataManager: CoreDataManager

  init(coreDataManager: CoreDataManager) {
    self.coreDataManager = coreDataManager
  }

  func search(page: Int, name: String) -> Single<[User]> {
    .just([])
  }

  func addFavoriteUser(user: User) -> Single<Void> {
    coreDataManager.saveUser(
      id: Int64(user.id),
      name: user.name ?? "",
      avatarUrl: user.avatarURL ?? ""
    ) { _ in
      User.event.onNext(.addFavoriteUser(user: user))
    }

    return .just(())
  }

  func removeFavoriteUser(userID: Int) -> Single<Void> {
    coreDataManager.deleteUser(
      id: Int64(userID)
    ) { _ in
      User.event.onNext(.removeFavoriteUser(userID: userID))
    }

    return .just(())
  }
}
