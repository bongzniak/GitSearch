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
    case setUsers([User], Bool)
    case appendUsers([User], Bool)
  }

  struct State {
    var page: Int = 1
    var isRefreshing: Bool = false
    var isLoading: Bool = false
    var hasNext: Bool = false
    var users: [User] = []
    var sections: [UserSection] = []
    var name: String = ""
  }

  let initialState = State()

  let service: GitSearchServiceType
  let hasSection: Bool

  init(service: GitSearchServiceType) {
    self.service = service
    self.hasSection = service.hasSection
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .refresh(name):
      guard !currentState.isRefreshing
      else {
        return .empty()
      }
      guard !currentState.isLoading
      else {
        return .empty()
      }

      let startRefreshing = Observable<Mutation>.just(.setRefreshing(true))
      let endRefreshing = Observable<Mutation>.just(.setRefreshing(false))
      let searchName = Observable<Mutation>.just(.setName(name))
      let users = service.search(page: 1, name: name)
        .asObservable()
        .map { list -> Mutation in
          .setUsers(list.items, list.hasNext)
        }

      return .concat([startRefreshing, searchName, users, endRefreshing])

    case .loadMore:
      guard !currentState.isRefreshing
      else {
        return .empty()
      }
      guard !currentState.isLoading
      else {
        return .empty()
      }

      let startLoading = Observable<Mutation>.just(.setLoading(true))
      let endLoading = Observable<Mutation>.just(.setLoading(false))
      let users = service.search(page: currentState.page, name: currentState.name)
        .asObservable()
        .map { list -> Mutation in
          .appendUsers(list.items, list.hasNext)
        }

      return .concat([startLoading, users, endLoading])
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
        .map { [weak self] users -> Mutation in
          .setUsers(users, self?.currentState.hasNext ?? false)
        }

    case let .removeFavoriteUser(user):
      return service.removeFavoriteUser(currentState.users, target: user)
        .asObservable()
        .map { [weak self] users -> Mutation in
          .setUsers(users, self?.currentState.hasNext ?? false)
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

    case let .setUsers(users, hasNext):
      state.users = users
      state.hasNext = hasNext
      state.page = 1 + (hasNext ? 1 : 0)
      state.sections = transformSections(state.users, includeHeader: service.hasSection)

    case let .appendUsers(users, hasNext):
      state.users.append(contentsOf: users)
      state.hasNext = hasNext
      state.page += hasNext ? 1 : 0
      state.sections = transformSections(state.users, includeHeader: service.hasSection)
    }
    return state
  }
}

extension GitSearchViewReactor {
  private func transformSections(_ users: [User], includeHeader: Bool) -> [UserSection] {
    includeHeader
      ? transformUserSectionsWithHeader(users)
      : [UserSection.user(title: "", items: users.map { UserSectionItem.user($0) })]
  }

  private func transformUserSectionsWithHeader(_ users: [User]) -> [UserSection] {
    var sectionGroup: [String: [User]] = [:]
    users.forEach {
      let name = $0.name ?? ""
      let unicode = name
        .decomposedStringWithCompatibilityMapping
        .unicodeScalars
        .map { String($0).uppercased() }
        .first ?? ""
      sectionGroup[unicode] = (sectionGroup[unicode] ?? []) + [$0]
    }

    var sections: [UserSection] = sectionGroup
      .map {
        UserSection.user(
          title: "\($0.key) (\($0.value.count))",
          items: $0.value.map {
            UserSectionItem.user($0)
          }
        )
      }
      .sorted(by: { $0.title ?? "" < $1.title ?? "" })

    return sections
  }
}
