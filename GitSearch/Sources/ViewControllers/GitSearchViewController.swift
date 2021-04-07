//
//  GitSearchViewController.swift
//  GitSearch
//
//  Created by bongzniak on 2021/04/07.
//
//

import Foundation
import UIKit

import Pure
import ReactorKit
import AsyncDisplayKit
import RxSwift
import RxCocoa_Texture
import URLNavigator

final class GitSearchViewController: BaseViewController, FactoryModule, View {

  typealias Node = GitSearchViewController
  typealias Reactor = GitSearchViewReactor

  // MARK: Dependency

  struct Dependency {
    let reactor: Reactor
  }

  // MARK: Constants

  // MARK: Properties

  // MARK: Node

  // MARK: Initializing

  init(dependency: Dependency, payload: Payload) {
    defer { reactor = dependency.reactor }

    super.init()
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuring

  func bind(reactor: Reactor) {
    rx.viewDidLoad
      .map {
        Reactor.Action.refresh("bongzniak")
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
  }

  // MARK: Layout Spec

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    ASLayoutSpec()
  }
}
