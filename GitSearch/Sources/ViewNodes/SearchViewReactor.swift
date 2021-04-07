//
//  SearchViewCellReactor.swift
//  GitSearch
//
//  Created by bongzniak on 2021/04/07.
//
//

import Foundation
import ReactorKit
import RxSwift

final class SearchViewReactor: Reactor {

  enum Action {
  }

  enum Mutation {
  }

  struct State {
  }

  let initialState = State()

  init() {
  }

  func mutate(action: Action) -> Observable<Mutation> {
    // switch action {
    // }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    // switch mutation {
    // }
    return state
  }
}
