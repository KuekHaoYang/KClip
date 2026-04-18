import CoreGraphics

enum PermissionGuideLayout {
  static let size = CGSize(width: 388, height: 292)
  static let margin: CGFloat = 18
  static let gap: CGFloat = 14

  static func frame(trayFrame: CGRect, visibleFrame: CGRect) -> CGRect {
    let width = min(size.width, visibleFrame.width - (margin * 2))
    let x = min(max(trayFrame.minX, visibleFrame.minX + margin), visibleFrame.maxX - width - margin)
    let preferredY = trayFrame.maxY + gap
    let maxY = visibleFrame.maxY - size.height - margin
    let y = min(max(preferredY, visibleFrame.minY + margin), maxY)
    return CGRect(x: x, y: y, width: width, height: size.height)
  }
}
