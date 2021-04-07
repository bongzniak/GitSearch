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
import TextureSwiftSupport

final class GitSearchViewController: BaseViewController, FactoryModule, View {

  typealias Node = GitSearchViewController
  typealias Reactor = GitSearchViewReactor

  // MARK: Dependency

  struct Dependency {
    let reactor: Reactor
  }

  // MARK: Constants

  // MARK: Properties

  let dataSource = RxASCollectionSectionedReloadDataSource<SectionModel<String, User>>(
    configureCellBlock: { (_, _, _, user) in
      {
        UserCellNode(user: user)
      }
    }
  )

  // MARK: Node

  lazy var searchNode = SearchNode()
  lazy var collectionViewFlowLayout = UICollectionViewFlowLayout()
  lazy var collectionNode = ASCollectionNode(collectionViewLayout: collectionViewFlowLayout).then {
    $0.style.flexGrow = 1
    $0.contentInset = .init(top: 0, left: 8.f, bottom: 0, right: 8.f)
    $0.alwaysBounceVertical = true
  }

  // MARK: Initializing

  init(dependency: Dependency, payload: Payload) {
    defer {
      reactor = dependency.reactor
    }

    super.init()

    searchNode.delegate = self
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
      .disposed(by: disposeBag)

    reactor.state
      .map { $0.users }
      .map {
        [SectionModel(model: "", items: $0)]
      }
      .bind(to: collectionNode.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }

  // MARK: Layout Spec

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    LayoutSpec {
      InsetLayout(insets: view.safeAreaInsets) {
        VStackLayout {
          searchNode
          collectionNode
        }
      }
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
