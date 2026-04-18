import AppKit
import SwiftUI

struct PermissionDragTileView: View {
  let bundleURL: URL

  var body: some View {
    HStack(spacing: 12) {
      Image(nsImage: NSWorkspace.shared.icon(forFile: bundleURL.path))
        .resizable()
        .frame(width: 44, height: 44)
      VStack(alignment: .leading, spacing: 4) {
        Text(bundleURL.deletingPathExtension().lastPathComponent)
          .font(.system(size: 13, weight: .bold, design: .rounded))
        Text("Drag this app into Accessibility, or click + and choose it.")
          .font(.system(size: 11, weight: .medium, design: .rounded))
          .foregroundStyle(.secondary)
        Text(folderLabel)
          .font(.system(size: 10, weight: .medium, design: .monospaced))
          .foregroundStyle(Color.secondary.opacity(0.78))
          .lineLimit(1)
      }
      Spacer()
    }
    .padding(14)
    .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white.opacity(0.06)))
    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 1))
    .overlay { PermissionFileDragSourceView(bundleURL: bundleURL) }
    .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
  }

  private var folderLabel: String {
    bundleURL.deletingLastPathComponent().path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
  }
}
