import Foundation
import AsyncDisplayKit
import TextureSwiftSupport
import BonMot

final class UserCellNode: ASCellNode {

  enum Metric {
    static let imageSize: CGSize = .init(width: 50, height: 50)
    static let buttonSize: CGSize = .init(width: 50, height: 50)
    static let spacing: CGFloat = 8
    static let placeholderColor: UIColor = .init(
      red: 233.0 / 255.0,
      green: 237.0 / 255.0,
      blue: 240.0 / 255.0,
      alpha: 1.0
    )
  }

  enum AttributeStyle {
    static let title: StringStyle = .init([.font(.systemFont(ofSize: 15))])
  }

  let imageNode: ASNetworkImageNode = ASNetworkImageNode().then {
    $0.style.preferredSize = Metric.imageSize
    $0.placeholderFadeDuration = 0.3
    $0.placeholderColor = Metric.placeholderColor
    $0.cornerRadius = Metric.imageSize.width / 2.f
    $0.clipsToBounds = true
  }

  let titleNode: ASTextNode = ASTextNode().then {
    $0.maximumNumberOfLines = 2
    $0.style.flexShrink = 1.0
    $0.style.flexGrow = 1.0
  }

  let buttonNode: ASButtonNode = ASButtonNode().then {
    $0.style.preferredSize = Metric.buttonSize
    $0.backgroundColor = .gray
  }

  init(user: User) {
    super.init()
    automaticallyManagesSubnodes = true
    backgroundColor = .white
    selectionStyle = .none

    imageNode.url = URL(string: user.avatarURL ?? "")
    titleNode.attributedText = NSAttributedString(
      string: user.name ?? "",
      attributes: AttributeStyle.title.attributes
    )
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    LayoutSpec {
      InsetLayout(insets: .zero) {
        HStackLayout(spacing: Metric.spacing, alignItems: .center) {
          imageNode
          titleNode
          buttonNode
        }
          .width(UIScreen.main.bounds.width)
      }
    }
  }
}
