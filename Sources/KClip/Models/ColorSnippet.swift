import Foundation

struct ColorSnippet: Equatable {
  let source: String
  let samples: [ColorSample]

  static func parse(_ text: String) -> ColorSnippet? {
    let source = text.replacingOccurrences(of: "\r\n", with: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    guard source.isEmpty == false else { return nil }
    let matches = regex.matches(in: source, range: NSRange(source.startIndex..., in: source))
    guard matches.isEmpty == false, matches.count <= 8 else { return nil }
    guard residualText(in: source, excluding: matches).isEmpty else { return nil }
    let samples = matches.enumerated().compactMap { index, match -> ColorSample? in
      guard let range = Range(match.range, in: source) else { return nil }
      return ColorSample(id: index, code: String(source[range]), range: range)
    }
    guard samples.count == matches.count else { return nil }
    return ColorSnippet(source: source, samples: samples)
  }

  func replacingSample(at index: Int, with code: String) -> String {
    guard samples.indices.contains(index) else { return source }
    var updated = source
    updated.replaceSubrange(samples[index].range, with: code)
    return updated
  }

  private static func residualText(in source: String, excluding matches: [NSTextCheckingResult]) -> String {
    let masked = NSMutableString(string: source)
    for match in matches.reversed() { masked.replaceCharacters(in: match.range, with: " ") }
    return (masked as String).replacingOccurrences(of: #"[,\s;/|]+"#, with: "", options: .regularExpression)
  }

  private static let regex = try! NSRegularExpression(
    pattern: #"(?<![0-9A-Fa-f])#(?:[0-9A-Fa-f]{3}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})(?![0-9A-Fa-f])"#
  )
}

struct ColorSample: Equatable, Identifiable {
  let id: Int
  let range: Range<String.Index>
  let red: Double
  let green: Double
  let blue: Double
  let alpha: Double
  let displayCode: String

  init?(id: Int, code: String, range: Range<String.Index>) {
    guard let components = Self.components(from: code) else { return nil }
    self.id = id
    self.range = range
    red = components[0]
    green = components[1]
    blue = components[2]
    alpha = components.count == 4 ? components[3] : 1
    displayCode = Self.code(red: red, green: green, blue: blue, alpha: alpha)
  }

  static func code(red: Double, green: Double, blue: Double, alpha: Double) -> String {
    let parts = [red, green, blue] + (alpha < 0.999 ? [alpha] : [])
    return "#" + parts.map { String(format: "%02X", Int(($0 * 255).rounded())) }.joined()
  }

  private static func components(from code: String) -> [Double]? {
    let digits = code.replacingOccurrences(of: "#", with: "")
    let expanded: String
    switch digits.count {
    case 3, 4: expanded = digits.map { "\($0)\($0)" }.joined()
    case 6, 8: expanded = digits
    default: return nil
    }
    let pairs = stride(from: 0, to: expanded.count, by: 2).compactMap { offset -> Double? in
      let start = expanded.index(expanded.startIndex, offsetBy: offset)
      let end = expanded.index(start, offsetBy: 2)
      guard let value = Int(expanded[start..<end], radix: 16) else { return nil }
      return Double(value) / 255
    }
    return (pairs.count == 3 || pairs.count == 4) ? pairs : nil
  }
}
