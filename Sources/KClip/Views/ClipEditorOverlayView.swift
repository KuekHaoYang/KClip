import SwiftUI

struct ClipEditorOverlayView: View {
  let item: ClipboardItem
  @Binding var text: String
  let onCancel: () -> Void
  let onSave: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(editorTitle)
        .font(.system(size: 15, weight: .bold, design: .rounded))
      if let snippet = currentSnippet {
        renderedPreview(snippet)
          .transition(.asymmetric(insertion: .offset(y: 8).combined(with: .opacity), removal: .opacity))
      }
      TextEditor(text: $text)
        .scrollContentBackground(.hidden)
        .font(.system(size: 13, weight: .medium, design: .rounded))
        .padding(10)
        .frame(height: currentSnippet == nil ? 126 : 112)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white.opacity(0.06)))
      HStack(spacing: 10) {
        Spacer(minLength: 0)
        actionButton("Cancel", action: onCancel)
        actionButton("Save", action: onSave, isPrimary: true)
          .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }
    }
    .padding(18)
    .frame(width: 420)
    .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.regularMaterial))
    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 1))
    .animation(.spring(response: 0.24, dampingFraction: 0.86), value: currentSnippet?.language.rawValue)
    .animation(.spring(response: 0.24, dampingFraction: 0.86), value: currentSnippet != nil)
  }

  private var currentSnippet: CodeSnippet? { CodeSnippet.parse(text) }
  private var editorTitle: String { currentSnippet != nil ? "Edit Code" : (item.isLink ? "Edit Link" : "Edit Clip") }

  private func renderedPreview(_ snippet: CodeSnippet) -> some View {
    CodePreviewSummaryView(snippet: snippet, compact: false)
      .frame(height: 122)
  }

  private func actionButton(
    _ title: String,
    action: @escaping () -> Void,
    isPrimary: Bool = false
  ) -> some View {
    Button(title, action: action)
      .buttonStyle(.plain)
      .font(.system(size: 11, weight: .bold, design: .rounded))
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(Capsule().fill(isPrimary ? Color.white.opacity(0.18) : Color.white.opacity(0.08)))
      .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
  }
}
