import Foundation
import UIKit

import AsyncDisplayKit
import BonMot

protocol BaseSegmentedControlDelegate: class {
  func onChangeIndex(to index: Int)
}

final class BaseSegmentedControl: BaseASDisplayNode {

  // MARK: Constants

  enum Metric {
    static let segmentedControlHeight = ASDimension(unit: .points, value: 44.f)
  }

  enum AttributeStyle {
    static let normalTitleStyle = StringStyle(
      [.font(.systemFont(ofSize: 16.f)), .color(.lightGray)]
    )
    static let selectedTitleStyle = StringStyle(
      [.font(.systemFont(ofSize: 16.f)), .color(.darkText)]
    )
  }

  // MARK: Properties

  weak var delegate: BaseSegmentedControlDelegate?

  private var currentIndex: Int = 0
  private let items: [String]

  // MARK: Node

  lazy var buttons: [ASButtonNode] = items.map { title in
    makeSegmentedButton(title: title)
  }

  lazy var underlineNode = ASDisplayNode().then {
    $0.style.width = .init(unit: .fraction, value: 1.f / items.count.f)
    $0.style.height = .init(unit: .points, value: 4.f)
    $0.backgroundColor = .darkText
  }

  // MARK: View Life Cycle

  init(items: [String]) {
    self.items = items

    super.init()

    if let button = buttons.first {
      button.isSelected = true
    }

    for (index, button) in buttons.enumerated() {
      button.rx.tap
        .subscribe(onNext: {
          self.buttonsUnselected()
          button.isSelected = !button.isSelected
          self.currentIndex = index

          self.delegate?.onChangeIndex(to: index)

          self.transitionLayout(withAnimation: true,
                                shouldMeasureAsync: true,
                                measurementCompletion: nil)
        })
        .disposed(by: disposeBag)
    }
  }

  // MARK: Private func

  private func buttonsUnselected() {
    buttons = buttons.map { button -> ASButtonNode in
      button.isSelected = false
      return button
    }
  }

  // MARK: Layout Spec

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let itemWidth = constrainedSize.max.width / items.count.f

    let horizontalButtonsSpec = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 0.0,
      justifyContent: .start,
      alignItems: .stretch,
      children: buttons
    ).then {
      $0.style.preferredSize = .init(
        width: constrainedSize.max.width,
        height: Metric.segmentedControlHeight.value
      )
    }

    underlineNode.style.preferredSize = .init(width: itemWidth, height: 4.f)
    let underLineSpec = ASInsetLayoutSpec(
      insets: .init(top: 0, left: currentIndex.f * itemWidth, bottom: 0, right: 0),
      child: underlineNode
    )

    return ASStackLayoutSpec(direction: .vertical,
                             spacing: 0.0,
                             justifyContent: .start,
                             alignItems: .start,
                             children: [horizontalButtonsSpec, underLineSpec])

  }

  private func makeSegmentedButton(title: String) -> ASButtonNode {
    ASButtonNode().then {
      $0.setAttributedTitle(title.styled(with: AttributeStyle.normalTitleStyle), for: .normal)
      $0.setAttributedTitle(title.styled(with: AttributeStyle.selectedTitleStyle), for: .selected)
      $0.style.height = Metric.segmentedControlHeight
      $0.style.width = ASDimension(unit: .fraction, value: 1.f / items.count.f)
    }
  }

  // MARK: Layout Transition

  override func animateLayoutTransition(_ context: ASContextTransitioning) {
    underlineNode.frame = context.initialFrame(for: underlineNode)

    UIView.animate(
      withDuration: 0.35,
      animations: {
        self.underlineNode.frame = context.finalFrame(for: self.underlineNode)
      },
      completion: { isCompleted in
        context.completeTransition(isCompleted)
      })
  }
}
