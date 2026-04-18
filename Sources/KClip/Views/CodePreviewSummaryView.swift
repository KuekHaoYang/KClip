import SwiftUI

struct CodePreviewSummaryView: View {
  let snippet: CodeSnippet
  let compact: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: compact ? 8 : 10) {
      HStack(spacing: 8) {
        languageBadge
        if compact == false {
          Text("Rendered")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.46))
        }
      }
      previewText
    }
    .padding(compact ? 10 : 14)
    .frame(maxWidth: .infinity, alignment: .topLeading)
    .background(RoundedRectangle(cornerRadius: compact ? 18 : 20, style: .continuous).fill(Color.black.opacity(compact ? 0.18 : 0.22)))
    .overlay(RoundedRectangle(cornerRadius: compact ? 18 : 20, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
  }

  private var previewText: some View {
    Group {
      if compact {
        codeText.lineLimit(4).mask { OverflowFadeView(isEnabled: snippet.body.count > 82) }
      } else {
        ScrollView { codeText.frame(maxWidth: .infinity, alignment: .topLeading) }
          .textSelection(.enabled)
      }
    }
  }

  private var codeText: some View {
    highlightedText
      .font(.system(size: compact ? 12 : 13, weight: .medium, design: .monospaced))
      .lineSpacing(compact ? 1.5 : 2)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .animation(.easeOut(duration: 0.18), value: snippet.body)
  }

  private var languageBadge: some View {
    Text(snippet.language.title)
      .font(.system(size: 10, weight: .bold, design: .rounded))
      .foregroundStyle(Color(red: 0.54, green: 0.80, blue: 1.00))
      .padding(.horizontal, 9)
      .padding(.vertical, 5)
      .background(Capsule().fill(Color.white.opacity(0.08)))
      .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
  }

  private var highlightedText: Text {
    CodeHighlight.runs(for: snippet).reduce(Text(""), combine)
  }

  private func combine(_ partial: Text, _ run: CodeHighlightRun) -> Text {
    partial + Text(run.text).foregroundColor(color(for: run.role))
  }

  private func color(for role: CodeHighlightRole) -> Color {
    switch role {
    case .plain: Color.white.opacity(0.92)
    case .keyword: Color(red: 0.50, green: 0.78, blue: 1.00)
    case .type: Color(red: 0.52, green: 0.90, blue: 0.77)
    case .string: Color(red: 0.98, green: 0.78, blue: 0.46)
    case .comment: Color.white.opacity(0.38)
    case .number: Color(red: 1.00, green: 0.63, blue: 0.43)
    case .accent: Color(red: 0.72, green: 0.86, blue: 1.00)
    }
  }
}
