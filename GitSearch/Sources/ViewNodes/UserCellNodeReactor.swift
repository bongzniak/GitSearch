//
// Created by bongzniak on 2021/04/12.
//

import Foundation

import ReactorKit
import RxSwift

final class UserCellNodeReactor: Reactor {
  typealias Action = NoAction

  struct State {
    var id: Int
    var name: String?
    var avatarURL: URL?
    var favorite: Bool = false
  }

  let initialState: State

  init(user: User) {
    initialState = State(
      id: user.id,
      name: user.name,
      avatarURL: user.avatarURL,
      favorite: user.favorite
    )
  }
}
