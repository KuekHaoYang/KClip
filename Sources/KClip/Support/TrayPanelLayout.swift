import CoreGraphics

enum TrayPanelLayout {
  static let preferredSize = CGSize(width: 900, height: 292)
  static let horizontalMargin: CGFloat = 18
  static let bottomMargin: CGFloat = 24
  static let entryScale: CGFloat = 0.94
  static let entryYOffset: CGFloat = 17.5
  static let overlayHeadroom: CGFloat = 296
  static let overlayOverlap: CGFloat = 40
  static let expandedHeight: CGFloat = preferredSize.height + overlayHeadroom
  static let trayContentHeight: CGFloat = preferredSize.height - 24
  static let overlayBottomInset: CGFloat = trayContentHeight - overlayOverlap

  static func frame(in visibleFrame: CGRect, panelSize: CGSize = preferredSize) -> CGRect {
    let width = min(panelSize.width, visibleFrame.width - (horizontalMargin * 2))
    let originX = visibleFrame.minX + ((visibleFrame.width - width) / 2)
    let originY = visibleFrame.minY + bottomMargin
    return CGRect(x: originX, y: originY, width: width, height: panelSize.height)
  }

  static func entryFrame(for finalFrame: CGRect) -> CGRect {
    let width = finalFrame.width * entryScale
    let height = finalFrame.height * entryScale
    let originX = finalFrame.midX - (width / 2)
    let originY = finalFrame.minY - entryYOffset
    return CGRect(x: originX, y: originY, width: width, height: height)
  }
}
