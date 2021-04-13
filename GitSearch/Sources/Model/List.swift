import Foundation

struct List<Element> {
  var items: [Element]
  var totalCount: Int
  var hasNext: Bool = false

  init(items: [Element], totalCount: Int) {
    self.items = items
    self.totalCount = totalCount
    self.hasNext = items.count != totalCount
  }
}
