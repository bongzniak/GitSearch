//
//  SearchViewCellNode.swift
//  GitSearch
//
//  Created by bongzniak on 2021/04/07.
//
//

import Foundation
import UIKit

import AsyncDisplayKit
import RxSwift
import RxCocoa

protocol SearchNodeDelegate: class {
  func onChangeText(text: String)
}

final class SearchNode: BaseASDisplayNode {

  typealias Node = SearchNode

  // MARK: Dependency

  // MARK: Constants

  enum Metric {
    static let barHeight = 50.f
  }

  // MARK: Properties

  weak var delegate: SearchNodeDelegate?

  // MARK: Node

  var bar: UISearchBar? {
    view as? UISearchBar
  }

  let searchBar = UISearchBar(frame: .zero).then {
    $0.placeholder = "검색어를 입력하세요"
    $0.backgroundImage = nil
    $0.backgroundColor = .clear
    $0.searchBarStyle = .minimal
  }

  // MARK: Initializing

  override init() {

    super.init()

    setViewBlock({
      self.searchBar
    })

    style.height = .init(unit: .points, value: Metric.barHeight)
    backgroundColor = .white

    searchBar.rx.text
      .debounce(.milliseconds(750), scheduler: MainScheduler.instance)
      .bind { [unowned self] text in
        delegate?.onChangeText(text: text ?? "")
      }
      .disposed(by: disposeBag)
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
