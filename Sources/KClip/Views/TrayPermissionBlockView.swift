import SwiftUI

struct TrayPermissionBlockView: View {
  let onOpenPermissions: () -> Void
  let onRestart: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("Accessibility Required", systemImage: "lock.shield")
        .font(.system(size: 18, weight: .bold, design: .rounded))
      Text("Clipboard history is visible, but paste is locked until KClip is enabled in Accessibility.")
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundStyle(.secondary)
      HStack(spacing: 10) {
        actionButton("Open Permissions", action: onOpenPermissions)
        actionButton("Restart KClip", action: onRestart)
      }
    }
    .padding(18)
    .frame(width: 360, alignment: .leading)
    .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.black.opacity(0.34)))
    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 1))
    .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
  }

  private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(title, action: action)
      .buttonStyle(.plain)
      .font(.system(size: 11, weight: .bold, design: .rounded))
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(Capsule().fill(Color.white.opacity(0.08)))
      .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
  }
}
