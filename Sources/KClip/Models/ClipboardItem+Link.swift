import Foundation

extension ClipboardItem {
  var linkURL: URL? { LinkTextClassifier.url(in: text) }
  var isLink: Bool { linkURL != nil }
}
