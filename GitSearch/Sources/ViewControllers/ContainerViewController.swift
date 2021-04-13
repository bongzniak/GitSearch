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
  }

  lazy var collectionNode = ASCollectionNode(collectionViewLayout: flowLayout).then {
    $0.view.isScrollEnabled = false
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.backgroundColor = .darkGray
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

    collectionNode.style.flexGrow = 1.f

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
    ASCellNode(viewControllerBlock: { () -> GitSearchViewController in
      self.gitSearchControllers[indexPath.row]
    }).then {
      let size = collectionNode.bounds.size
      $0.style.preferredSize = .init(width: size.width, height: size.height - 178.f)
    }
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
