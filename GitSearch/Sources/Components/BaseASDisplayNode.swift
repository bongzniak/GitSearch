//
// Created by bongzniak on 2021/04/07.
//

import Foundation

import AsyncDisplayKit
import RxSwift

class BaseASDisplayNode: ASDisplayNode {

  // MARK: Rx

  var disposeBag = DisposeBag()

  // MARK: View Life Cycle

  override init() {
    super.init()

    automaticallyManagesSubnodes = true
  }
}
