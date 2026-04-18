import Foundation

enum LinkTextClassifier {
  static func url(in text: String) -> URL? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.isEmpty == false else { return nil }
    let types = NSTextCheckingResult.CheckingType.link.rawValue
    guard let detector = try? NSDataDetector(types: types) else { return nil }
    let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
    let matches = detector.matches(in: trimmed, options: [], range: range)
    guard matches.count == 1, matches[0].range == range, let url = matches[0].url else { return nil }
    guard let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme), url.host?.isEmpty == false else {
      return nil
    }
    return url
  }
}
