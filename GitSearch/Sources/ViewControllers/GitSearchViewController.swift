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
import RxDataSources_Texture

final class GitSearchViewController: BaseViewController, FactoryModule, View {

  typealias Node = GitSearchViewController
  typealias Reactor = GitSearchViewReactor

  // MARK: Dependency

  struct Dependency {
    let reactor: Reactor
    let userCellNodeFactory: UserCellNode.Factory
  }

  struct Payload {
    let segmentedItem: String
  }

  // MARK: Constants

  // MARK: Properties

  let userCellNodeFactory: UserCellNode.Factory
  let segmentedItem: String

  lazy var dataSource = RxASCollectionSectionedReloadDataSource<SectionModel<String, User>>(
    configureCellBlock: { (_, _, _, user) in
      {
        self.userCellNodeFactory.create(payload: .init(user: user))
      }
    }
  )

  var batchContext: ASBatchContext?

  // MARK: Node

  lazy var searchNode = SearchNode()

  let refreshControl = UIRefreshControl()

  lazy var collectionViewFlowLayout = UICollectionViewFlowLayout()
  lazy var collectionNode = ASCollectionNode(collectionViewLayout: collectionViewFlowLayout).then {
    $0.style.flexGrow = 1
    $0.contentInset = .init(top: 0, left: 8.f, bottom: 0, right: 8.f)
  }

  // MARK: Initializing

  init(dependency: Dependency, payload: Payload) {
    defer {
      reactor = dependency.reactor
    }

    userCellNodeFactory = dependency.userCellNodeFactory
    segmentedItem = payload.segmentedItem

    super.init()

    searchNode.delegate = self
    collectionNode.view.refreshControl = refreshControl
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuring

  func bind(reactor: Reactor) {

    // Action

    refreshControl.rx.controlEvent(.valueChanged)
      .map {
        let name = reactor.currentState.name ?? ""
        return Reactor.Action.refresh(name)
      }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // State

    reactor.state
      .map {
        $0.users
      }
      .map {
        [SectionModel(model: "", items: $0)]
      }
      .bind(to: collectionNode.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)

    reactor.state
      .map {
        $0.isRefreshing
      }
      .bind(to: refreshControl.rx.isRefreshing)
      .disposed(by: disposeBag)
  }

  // MARK: Layout Spec

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vStackLayout = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0.f,
      justifyContent: .start,
      alignItems: .start,
      children: [searchNode, collectionNode]
    )

    return ASWrapperLayoutSpec(layoutElements: [vStackLayout]).then {
      $0.style.preferredSize = constrainedSize.max
    }
  }
}

extension GitSearchViewController: SearchNodeDelegate {
  func onChangeText(text: String) {
    guard let reactor = reactor
    else {
      return
    }

    Observable.just(Reactor.Action.refresh(text))
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}
