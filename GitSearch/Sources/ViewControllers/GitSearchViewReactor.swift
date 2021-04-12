import Foundation

import ReactorKit
import RxSwift

final class GitSearchViewReactor: Reactor {

  enum Action {
    case refresh(String)
    case loadMore
  }

  enum Mutation {
    case setRefreshing(Bool)
    case setLoading(Bool)
    case setName(String)
    case setUsers([User])
    case setPage(Int)
  }

  struct State {
    var page: Int = 1
    var isRefreshing: Bool = false
    var isLoading: Bool = false
    var users: [User] = []
    var name: String = ""
  }

  let initialState = State()

  let service: GitSearchServiceType

  init(service: GitSearchServiceType) {
    self.service = service
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .refresh(name):
      guard !currentState.isRefreshing else { return .empty() }
      guard !currentState.isLoading else { return .empty() }

      let startRefreshing = Observable<Mutation>.just(.setRefreshing(true))
      let endRefreshing = Observable<Mutation>.just(.setRefreshing(false))
      let searchName = Observable<Mutation>.just(.setName(name))
      let users = service.search(page: 1, name: name)
        .asObservable()
        .map { users -> Mutation in
          .setUsers(users)
        }

      return .concat([startRefreshing, searchName, users, endRefreshing])

    case .loadMore:
      guard !currentState.isRefreshing else { return .empty() }
      guard !currentState.isLoading else { return .empty() }

      let startLoading = Observable<Mutation>.just(.setLoading(true))
      let endLoading = Observable<Mutation>.just(.setLoading(false))
      let users = service.search(page: currentState.page, name: currentState.name)
        .asObservable()
        .map { users -> Mutation in
          .setUsers(users)
        }
      let nextPage = Observable<Mutation>.just(.setPage(currentState.page + 1))

      return .concat([startLoading, users, nextPage, endLoading])
    }
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let fromShotEvent = User.event.flatMap { [weak self] event in
      self?.mutation(from: event) ?? .empty()
    }
    return Observable.of(mutation, fromShotEvent).merge()
  }

  func mutation(from event: User.Event) -> Observable<Mutation> {
    switch event {
    case let .appendFavoriteUser(user):
      return service.appendFavoriteUser(currentState.users, target: user)
        .asObservable()
        .map { users -> Mutation in
          .setUsers(users)
        }

    case let .removeFavoriteUser(user):
      return service.removeFavoriteUser(currentState.users, target: user)
        .asObservable()
        .map { users -> Mutation in
          .setUsers(users)
        }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setRefreshing(isRefreshing):
      state.isRefreshing = isRefreshing

    case let .setLoading(isLoading):
      state.isLoading = isLoading

    case let .setName(name):
      state.name = name

    case let .setUsers(users):
      state.users = users

    case let .setPage(page):
      state.page = page
    }

    return state
  }
}
