import Foundation

import Pure
import ReactorKit
import AsyncDisplayKit
import BonMot

final class UserCellNode: BaseASCellNode, FactoryModule, View {

  typealias Node = SearchNode
  typealias Reactor = UserCellNodeReactor

  // MARK: Dependency

  struct Dependency {
    let reactorFactory: (User) -> UserCellNodeReactor
  }

  struct Payload {
    let user: User
  }

  // MARK: Constants

  enum Metric {
    static let imageSize = CGSize.init(width: 50, height: 50)
    static let buttonSize = CGSize.init(width: 50, height: 50)
    static let spacing = 8.f
  }

  enum Image {
    static let favoriteImage = UIImage(named: "icon-like")
    static let favoriteFillImage = UIImage(named: "icon-like-selected")
  }

  enum AttributeStyle {
    static let title = StringStyle.init([.font(.systemFont(ofSize: 15))])
  }

  // MARK: Properties

  private let user: User

  // MARK: Node

  let imageNode = ASNetworkImageNode().then {
    $0.style.preferredSize = Metric.imageSize
    $0.placeholderColor = .placeholderColor
    $0.cornerRadius = Metric.imageSize.width / 2.f
    $0.clipsToBounds = true
  }

  let titleNode = ASTextNode().then {
    $0.maximumNumberOfLines = 1
    $0.style.flexShrink = 1.f
    $0.style.flexGrow = 1.f
  }

  let buttonNode = ASButtonNode().then {
    $0.style.preferredSize = Metric.buttonSize

    $0.setImage(Image.favoriteImage, for: .normal)
    $0.setImage(Image.favoriteFillImage, for: .selected)
  }

  // MARK: Initializing

  init(dependency: Dependency, payload: Payload) {
    defer {
      reactor = dependency.reactorFactory(payload.user)
    }

    user = payload.user

    super.init()
  }

  // MARK: Configuring

  func bind(reactor: UserCellNodeReactor) {

    // Action

    buttonNode.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [unowned self] in
        !buttonNode.isSelected
          ? User.event.onNext(.appendFavoriteUser(user))
          : User.event.onNext(.removeFavoriteUser(user))
        buttonNode.isSelected = !buttonNode.isSelected
      })
      .disposed(by: disposeBag)

    // State

    reactor.state
      .map {
        $0.avatarURL
      }
      .bind(to: imageNode.rx.url)
      .disposed(by: disposeBag)

    reactor.state
      .map {
        $0.name
      }
      .bind(to: titleNode.rx.text(AttributeStyle.title.attributes))
      .disposed(by: disposeBag)

    reactor.state
      .map {
        $0.favorite
      }
      .bind(to: buttonNode.rx.isSelected)
      .disposed(by: disposeBag)

    reactor.state.map { _ in
      }
      .bind(to: rx.setNeedsLayout)
      .disposed(by: self.disposeBag)
  }

  // MARK: Layout Spec

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let verticalSpec = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: Metric.spacing,
      justifyContent: .start,
      alignItems: .center,
      children: [imageNode, titleNode, buttonNode]
    ).then {
      $0.style.width = ASDimension(unit: .fraction, value: 1.f)
    }

    return ASInsetLayoutSpec(insets: .zero, child: verticalSpec)
  }
}
