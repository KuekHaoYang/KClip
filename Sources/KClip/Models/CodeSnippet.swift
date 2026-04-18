import Foundation

struct CodeSnippet: Equatable {
  let body: String
  let language: CodeLanguage

  static func parse(_ text: String) -> CodeSnippet? {
    let normalized = text.replacingOccurrences(of: "\r\n", with: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    guard normalized.isEmpty == false else { return nil }
    let fenced = fencedBlock(in: normalized)
    let body = (fenced?.body ?? normalized).trimmingCharacters(in: .whitespacesAndNewlines)
    let lines = body.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    guard lines.isEmpty == false else { return nil }
    let language = CodeLanguage.detect(in: body, hint: fenced?.languageHint)
    var codeLines = 0
    for line in lines {
      switch classify(line, fallback: language) {
      case .comment, .neutral: continue
      case .code: codeLines += 1
      case .text: return nil
      }
    }
    guard codeLines > 0 || language != .plainText else { return nil }
    return CodeSnippet(body: body, language: language)
  }

  private enum LineKind { case code, comment, neutral, text }

  private static func classify(_ raw: String, fallback: CodeLanguage) -> LineKind {
    let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    if line.isEmpty { return .neutral }
    if isComment(line) { return .comment }
    if fallback == .yaml && line.range(of: "^\\s*(-\\s+)?[A-Za-z0-9_-]+:\\s*\\S.*$", options: .regularExpression) != nil { return .code }
    if fallback != .plainText && CodeLanguage.detect(in: line) == fallback { return .code }
    if isCode(line) { return .code }
    if line.allSatisfy({ "{}[]()<>:,".contains($0) }) { return .neutral }
    return .text
  }

  private static func isComment(_ line: String) -> Bool {
    ["//", "#", "/*", "*", "--", "<!--", "*/"].contains { line.hasPrefix($0) }
  }

  private static func isCode(_ line: String) -> Bool {
    let lower = line.lowercased()
    let prefixes = ["func ", "let ", "var ", "struct ", "enum ", "class ", "protocol ", "extension ", "guard ", "return ", "if ", "for ", "while ", "switch ", "case ", "def ", "from ", "import ", "const ", "export ", "interface ", "type ", "select ", "with ", "insert ", "update ", "delete ", "<", "</"]
    if prefixes.contains(where: lower.hasPrefix) { return true }
    if line.contains("{") || line.contains("}") || line.contains(";") || line.contains("->") || line.contains("=>") { return true }
    if line.range(of: "^\\s*#?\"[^\"]+\"\\s*:\\s*.+$|^\\s*\\w+\\s*=\\s*.+$|^\\s*\\w+\\([^)]*\\)$", options: .regularExpression) != nil { return true }
    return false
  }

  private static func fencedBlock(in text: String) -> (body: String, languageHint: String?)? {
    guard text.hasPrefix("```"), let newline = text.firstIndex(of: "\n"), text.hasSuffix("```") else { return nil }
    let hint = String(text[text.index(text.startIndex, offsetBy: 3)..<newline])
    let bodyEnd = text.index(text.endIndex, offsetBy: -3)
    return (String(text[text.index(after: newline)..<bodyEnd]), hint)
  }
}
