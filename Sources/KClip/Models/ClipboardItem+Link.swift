import Foundation

extension ClipboardItem {
  var linkURL: URL? { plainText.flatMap(LinkTextClassifier.url(in:)) }
  var isLink: Bool { linkURL != nil }
}
