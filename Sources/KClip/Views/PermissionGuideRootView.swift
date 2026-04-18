import SwiftUI

struct PermissionGuideRootView: View {
  let bundleURL: URL
  let onOpenSettings: () -> Void
  let onRevealInFinder: () -> Void
  let onRestart: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Color.clear
        .frame(height: 10)
        .contentShape(Rectangle())
        .gesture(WindowDragGesture())
      Text("Enable Accessibility")
        .font(.system(size: 18, weight: .bold, design: .rounded))
      Text(
        "1. Keep Accessibility open.\n"
        + "2. Drag KClip into the list.\n"
        + "3. If the drop target refuses it, click + and choose KClip.app from ~/Applications.\n"
        + "4. Turn it on, then restart KClip if macOS still lags behind."
      )
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
      PermissionDragTileView(bundleURL: bundleURL)
      HStack(spacing: 10) {
        actionButton("Open Settings", action: onOpenSettings)
        actionButton("Reveal KClip.app", action: onRevealInFinder)
      }
      actionButton("Restart KClip", action: onRestart)
    }
    .padding(18)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(.ultraThinMaterial))
    .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
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
