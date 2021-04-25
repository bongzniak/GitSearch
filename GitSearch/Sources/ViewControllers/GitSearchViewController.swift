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

  var batchContext: ASBatchContext?

  lazy var dataSource = RxASCollectionSectionedReloadDataSource<UserSection>(
    configureCellBlock: { _, _, _, sectionItem in
      switch sectionItem {
      case let .user(item):
        return {
          self.userCellNodeFactory.create(payload: .init(user: item))
        }
      }
    },
    configureSupplementaryNode: { dataSource, _, _, indexPath in
      let sectionModel = dataSource.sectionModels[indexPath.section]
      if sectionModel.title.isNotEmpty {
        return SectionCellNode(title: sectionModel.title)
      } else {
        return ASCellNode()
      }
    }
  )

  // MARK: Node

  lazy var searchNode = SearchNode()

  let refreshControl = UIRefreshControl()

  lazy var collectionViewFlowLayout = UICollectionViewFlowLayout().then {
    $0.sectionHeadersPinToVisibleBounds = true
    $0.sectionInset = .init(top: 8.f, left: 0.f, bottom: 8.f, right: 0.f)
  }
  lazy var collectionNode = ASCollectionNode(collectionViewLayout: collectionViewFlowLayout).then {
    $0.style.flexGrow = 1
    $0.contentInset = .init(top: 0.f, left: 8.f, bottom: 0.f, right: 8.f)

    $0.registerSupplementaryNode(ofKind: UICollectionView.elementKindSectionHeader)
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
        Reactor.Action.refresh(reactor.currentState.name)
      }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    collectionNode.rx
      .setDelegate(self)
      .disposed(by: disposeBag)

    collectionNode.rx.willBeginBatchFetch
      .do(onNext: { [weak self] context in
        self?.batchContext = context
      }).map { _ in
        Reactor.Action.loadMore
      }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // State

    reactor.state
      .map {
        $0.sections
      }
      .map { [weak self] in
        self?.batchContext?.completeBatchFetching(true)
        self?.batchContext = nil

        return $0
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
      $0.style.flexGrow = 1.f
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

// MARK: ASCollectionDelegate

extension GitSearchViewController: ASCollectionDelegate {
  public func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
    guard let hasNext = reactor?.currentState.hasNext,
          let isLoading = reactor?.currentState.isLoading,
          hasNext && !isLoading
    else {
      return false
    }

    return batchContext == nil
  }
}

// MARK: ASCollectionDelegateFlowLayout

extension GitSearchViewController: ASCollectionDelegateFlowLayout {
  func collectionNode(
    _ collectionNode: ASCollectionNode,
    sizeRangeForHeaderInSection section: Int
  ) -> ASSizeRange {
    ASSizeRangeUnconstrained
  }
}
