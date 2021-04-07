//
//  GitSearchViewReactor.swift
//  GitSearch
//
//  Created by bongzniak on 2021/04/07.
//
//

import Foundation
import ReactorKit
import RxSwift

final class GitSearchViewReactor: Reactor {

  enum Action {
    case refresh(String)
    case next(page: Int, name: String)
    case addFavorite(User)
    case removeFavorite(Int)
  }

  enum Mutation {
    case setLoading(Bool)
    case setUsers([User])
  }

  struct State {
    var isLoading: Bool = false
    var users: [User] = []
  }

  let initialState = State()

  let service: GitSearchServiceType

  init(service: GitSearchServiceType) {
    self.service = service
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .refresh(name):
      return searchUsers(page: 0, name: name)

    case let .next(page, name):
      return searchUsers(page: page, name: name)

    case let .addFavorite(user):
      return service.addFavoriteUser(user: user)
        .asObservable()
        .flatMap { _ in
          Observable.empty()
        }

    case let .removeFavorite(userID):
      return service.removeFavoriteUser(userID: userID)
        .asObservable()
        .flatMap { _ in
          Observable.empty()
        }
    }
  }

  private func searchUsers(page: Int, name: String) -> Observable<Mutation> {
    let startLoading = Observable<Mutation>.just(.setLoading(true))
    let endLoading = Observable<Mutation>.just(.setLoading(false))
    let users = service.search(page: page, name: name)
      .asObservable()
      .map { users -> Mutation in
        .setUsers(users)
      }

    return .concat([startLoading, users, endLoading])
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setLoading(isLoading):
      state.isLoading = isLoading

    case let .setUsers(users):
      state.users = users
    }

    return state
  }
}
