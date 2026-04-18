import CoreGraphics

enum TrayInteractionBounds {
  static func contains(
    _ point: CGPoint,
    trayFrame: CGRect,
    guideFrame: CGRect?
  ) -> Bool {
    trayFrame.contains(point) || guideFrame?.contains(point) == true
  }
}
