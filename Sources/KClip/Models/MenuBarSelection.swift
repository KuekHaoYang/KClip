struct MenuBarSelection {
  var index = 0

  mutating func move(delta: Int, itemCount: Int) {
    guard itemCount > 0 else {
      index = 0
      return
    }

    index = min(max(index + delta, 0), itemCount - 1)
  }

  mutating func normalize(itemCount: Int) {
    guard itemCount > 0 else {
      index = 0
      return
    }

    index = min(index, itemCount - 1)
  }

  func quickIndex(forCommandNumber number: Int, itemCount: Int) -> Int? {
    let quickIndex = number - 1
    guard quickIndex >= 0, quickIndex < itemCount else {
      return nil
    }
    return quickIndex
  }
}
