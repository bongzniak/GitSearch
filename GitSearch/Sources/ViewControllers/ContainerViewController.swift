//
//  ContainerViewControllerController.swift
//  GitSearch
//
//  Created by bongzniak on 2021/04/09.
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

final class ContainerViewController: BaseViewController, FactoryModule, View {

  typealias Node = ContainerViewController
  typealias Reactor = ContainerViewReactor

  // MARK: Dependency

  struct Dependency {
    let reactor: Reactor
    let gitSearchControllers: [GitSearchViewController]
  }

  // MARK: Constants

  // MARK: Properties

  let segmentedItems: [String]
  let gitSearchControllers: [GitSearchViewController]

  // MARK: Node

  lazy var segmentedControl = BaseSegmentedControl(items: segmentedItems)

  lazy var flowLayout = ASPagerFlowLayout().then {
    $0.minimumLineSpacing = 0
    $0.minimumInteritemSpacing = 0
    $0.scrollDirection = .horizontal
    $0.sectionInset = .zero
    $0.itemSize = .init(width: UIScreen.main.bounds.width, height: 670.f)
  }

  lazy var collectionNode = ASCollectionNode(collectionViewLayout: flowLayout).then {
    $0.view.isPagingEnabled = false
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.backgroundColor = .clear
  }

  // MARK: Initializing

  init(dependency: Dependency, payload: Payload) {
    defer {
      reactor = dependency.reactor
    }

    gitSearchControllers = dependency.gitSearchControllers
    segmentedItems = dependency.gitSearchControllers.map { $0.segmentedItem }

    super.init()

    segmentedControl.delegate = self

    collectionNode.delegate = self
    collectionNode.dataSource = self
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuring

  func bind(reactor: Reactor) {

    rx.viewDidLoad
      .subscribe(onNext: { [unowned self] in
        title = "Github Stars"
      })
      .disposed(by: disposeBag)
  }

  // MARK: Layout Spec

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    collectionNode.style.flexGrow = 1.0

    let verticalSpec = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0,
      justifyContent: .start,
      alignItems: .start,
      children: [segmentedControl, collectionNode]
    )

    return ASInsetLayoutSpec(insets: view.safeAreaInsets, child: verticalSpec)
  }
}

// MARK: ASCollectionDataSource

extension ContainerViewController: ASCollectionDataSource {

  func collectionNode(
    _ collectionNode: ASCollectionNode,
    numberOfItemsInSection section: Int
  ) -> Int {
    gitSearchControllers.count
  }

  public func collectionNode(
    _ collectionNode: ASCollectionNode,
    nodeForItemAt indexPath: IndexPath
  ) -> ASCellNode {
    let node = ASCellNode(viewControllerBlock: { () -> GitSearchViewController in
      self.gitSearchControllers[indexPath.row]
    })

    return node
  }
}

extension ContainerViewController: ASCollectionDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//    let scrollWidth = scrollView.frame.width
//    let index = Int(floor((scrollView.contentOffset.x - scrollWidth / 2) / scrollWidth ) + 1)
  }
}

// MARK: BaseSegmentedControlDelegate

extension ContainerViewController: BaseSegmentedControlDelegate {
  func onChangeIndex(to index: Int) {
    collectionNode.scrollToItem(
      at: .init(row: index, section: 0),
      at: .centeredHorizontally,
      animated: true
    )
  }
}
