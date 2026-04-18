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
    Text(snippet.body)
      .font(.system(size: compact ? 12 : 13, weight: .medium, design: .monospaced))
      .lineSpacing(compact ? 1.5 : 2)
      .foregroundStyle(Color.white.opacity(0.92))
      .frame(maxWidth: .infinity, alignment: .topLeading)
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
}
