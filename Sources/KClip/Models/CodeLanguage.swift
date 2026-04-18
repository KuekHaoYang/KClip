import Foundation

enum CodeLanguage: String, Equatable {
  case swift, python, typescript, javascript, json, html, css, shell, sql, yaml, plainText

  var title: String {
    switch self {
    case .swift: "Swift"
    case .python: "Python"
    case .typescript: "TypeScript"
    case .javascript: "JavaScript"
    case .json: "JSON"
    case .html: "HTML"
    case .css: "CSS"
    case .shell: "Shell"
    case .sql: "SQL"
    case .yaml: "YAML"
    case .plainText: "Plain Text"
    }
  }

  static func detect(in text: String, hint: String? = nil) -> CodeLanguage {
    if let hinted = fromFence(hint) { return hinted }
    let lower = text.lowercased()
    if isJSON(text) { return .json }
    if matches("(?m)^\\s*(import\\s+(SwiftUI|AppKit|Foundation)\\b|func\\s+\\w+\\s*\\(|struct\\s+\\w+|enum\\s+\\w+|var\\s+body\\s*:\\s*some\\s+View)", text) { return .swift }
    if matches("(?m)^\\s*(def\\s+\\w+\\s*\\(|from\\s+\\w+[\\.\\w]*\\s+import\\s+\\w+|print\\(|class\\s+\\w+:)", text) { return .python }
    if matches("(?m)^\\s*(type\\s+\\w+\\s*=|interface\\s+\\w+|export\\s+(type|interface|const)|const\\s+\\w+\\s*:)", text) { return .typescript }
    if matches("(?m)^\\s*(const\\s+\\w+\\s*=|let\\s+\\w+\\s*=|function\\s+\\w+\\s*\\(|console\\.log\\(|import\\s.+from\\s)", text) || lower.contains("=>") { return .javascript }
    if matches("(?m)^\\s*</?[a-z][^>]*>", text) { return .html }
    if matches("(?m)^\\s*[.#]?[a-z][\\w\\s>.#:-]*\\{\\s*$", text) && matches("(?m)^\\s*[a-z-]+\\s*:\\s*.+;\\s*$", text) { return .css }
    if matches("(?m)^\\s*(#!/|\\$\\s+|git\\s+|cd\\s+|ls\\s*$|swift\\s+|npm\\s+|pnpm\\s+|yarn\\s+)", text) { return .shell }
    if matches("(?im)^\\s*(select|with|insert|update|delete|create|alter|from|where|group by|order by)\\b", text) { return .sql }
    if matchCount("(?m)^\\s*(-\\s+)?[A-Za-z0-9_-]+:\\s*\\S.*$", text) > 1 { return .yaml }
    return .plainText
  }

  private static func fromFence(_ hint: String?) -> CodeLanguage? {
    switch hint?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "swift": .swift
    case "py", "python": .python
    case "ts", "tsx", "typescript": .typescript
    case "js", "jsx", "javascript": .javascript
    case "json": .json
    case "html": .html
    case "css": .css
    case "sh", "bash", "zsh", "shell": .shell
    case "sql": .sql
    case "yaml", "yml": .yaml
    default: nil
    }
  }

  private static func isJSON(_ text: String) -> Bool {
    guard text.trimmingCharacters(in: .whitespacesAndNewlines).first.map({ "{[".contains($0) }) == true else { return false }
    return (try? JSONSerialization.jsonObject(with: Data(text.utf8))) != nil
  }

  private static func matches(_ pattern: String, _ text: String) -> Bool {
    text.range(of: pattern, options: .regularExpression) != nil
  }

  private static func matchCount(_ pattern: String, _ text: String) -> Int {
    (try? NSRegularExpression(pattern: pattern))?.numberOfMatches(in: text, range: NSRange(text.startIndex..., in: text)) ?? 0
  }
}
