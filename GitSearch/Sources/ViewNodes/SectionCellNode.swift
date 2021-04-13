import Foundation

import AsyncDisplayKit

class SectionCellNode: BaseASCellNode {

  lazy var titleTextNode = ASTextNode().then {
    $0.maximumNumberOfLines = 1
    $0.style.flexShrink = 1.f
    $0.style.flexGrow = 1.f
  }

  init(title: String) {
    super.init()

    titleTextNode.attributedText = title.styled(with: .init(
      .font(UIFont.systemFont(ofSize: 16.f))
    ))

    backgroundColor = .lightGray
  }

  // MARK: Layout Spec

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    ASInsetLayoutSpec(
      insets: .init(top: 8.f, left: 8.f, bottom: 8.f, right: 8.f),
      child: titleTextNode
    )
  }
}
