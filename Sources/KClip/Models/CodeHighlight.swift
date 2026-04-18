import Foundation

enum CodeHighlightRole: Equatable { case plain, keyword, type, string, comment, number, accent }

struct CodeHighlightRun: Equatable {
  let text: String
  let role: CodeHighlightRole
}

enum CodeHighlight {
  static func runs(for snippet: CodeSnippet) -> [CodeHighlightRun] {
    var runs: [CodeHighlightRun] = []
    let text = snippet.body
    var index = text.startIndex
    while index < text.endIndex {
      if text[index...].hasPrefix("//") { append(String(text[index..<(text[index...].firstIndex(of: "\n") ?? text.endIndex)]), .comment, to: &runs); index = text[index...].firstIndex(of: "\n") ?? text.endIndex; continue }
      if text[index...].hasPrefix("/*"), let end = text[index...].range(of: "*/")?.upperBound { append(String(text[index..<end]), .comment, to: &runs); index = end; continue }
      let character = text[index]
      if character == "\"" || character == "'" { let end = stringEnd(in: text, from: index, quote: character); append(String(text[index..<end]), .string, to: &runs); index = end; continue }
      if character.isNumber { let end = consume(in: text, from: index) { $0.isNumber || $0 == "." }; append(String(text[index..<end]), .number, to: &runs); index = end; continue }
      if isTokenLead(character) { let end = consume(in: text, from: index) { isTokenLead($0) || $0.isNumber }; let token = String(text[index..<end]); append(token, classify(token, snippet.language), to: &runs); index = end; continue }
      append(String(character), .plain, to: &runs)
      index = text.index(after: index)
    }
    return runs
  }

  private static func classify(_ token: String, _ language: CodeLanguage) -> CodeHighlightRole {
    let bare = token.trimmingCharacters(in: CharacterSet(charactersIn: "@."))
    let lower = bare.lowercased()
    if token.hasPrefix("@") || keywords(language).contains(lower) { return .keyword }
    if token.hasPrefix(".") { return .accent }
    if ["true", "false", "nil", "null", "self"].contains(lower) { return .number }
    if bare.first?.isUppercase == true { return .type }
    return .plain
  }

  private static func keywords(_ language: CodeLanguage) -> Set<String> {
    switch language {
    case .swift: ["import", "struct", "class", "enum", "protocol", "extension", "func", "let", "var", "return", "if", "else", "guard", "for", "while", "switch", "case", "in", "where", "some"]
    case .python: ["import", "from", "def", "class", "return", "if", "else", "elif", "for", "while", "in", "and", "or", "not", "async", "await"]
    case .javascript, .typescript: ["import", "from", "export", "const", "let", "var", "function", "return", "if", "else", "for", "while", "class", "interface", "type", "async", "await", "new"]
    case .shell: ["if", "then", "fi", "for", "do", "done", "case", "esac", "function", "export"]
    case .sql: ["select", "from", "where", "insert", "update", "delete", "create", "alter", "join", "group", "order", "by", "having", "with"]
    default: []
    }
  }

  private static func append(_ text: String, _ role: CodeHighlightRole, to runs: inout [CodeHighlightRun]) {
    guard text.isEmpty == false else { return }
    if let last = runs.last, last.role == role { runs[runs.count - 1] = CodeHighlightRun(text: last.text + text, role: role) }
    else { runs.append(CodeHighlightRun(text: text, role: role)) }
  }

  private static func isTokenLead(_ character: Character) -> Bool {
    character.isLetter || character == "_" || character == "@" || character == "."
  }

  private static func consume(in text: String, from index: String.Index, while include: (Character) -> Bool) -> String.Index {
    var current = index
    while current < text.endIndex, include(text[current]) { current = text.index(after: current) }
    return current
  }

  private static func stringEnd(in text: String, from index: String.Index, quote: Character) -> String.Index {
    var current = text.index(after: index)
    while current < text.endIndex {
      if text[current] == "\\" { current = text.index(current, offsetBy: 2, limitedBy: text.endIndex) ?? text.endIndex; continue }
      current = text.index(after: current)
      if text[text.index(before: current)] == quote { break }
    }
    return current
  }
}
