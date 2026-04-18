import SwiftUI

struct ClipEditorOverlayView: View {
  @Binding var text: String
  let onCancel: () -> Void
  let onSave: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Edit Clip")
        .font(.system(size: 15, weight: .bold, design: .rounded))
      TextEditor(text: $text)
        .scrollContentBackground(.hidden)
        .font(.system(size: 13, weight: .medium, design: .rounded))
        .padding(10)
        .frame(height: 126)
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
