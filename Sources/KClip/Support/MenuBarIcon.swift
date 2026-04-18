import AppKit

enum MenuBarIcon {
  static func makeImage() -> NSImage {
    let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
      drawBackCard()
      drawK()
      return true
    }
    image.isTemplate = true
    image.accessibilityDescription = "KClip"
    return image
  }

  private static func drawBackCard() {
    NSColor.black.withAlphaComponent(0.30).setFill()
    cardPath(x: 8.0, y: 5.0, width: 6.5, height: 7.3, radius: 2.2).fill()
  }

  private static func drawK() {
    NSColor.black.setStroke()
    kStroke(fromX: 5.2, fromY: 5.0, toX: 5.2, toY: 12.6, width: 2.3).stroke()
    kStroke(fromX: 6.0, fromY: 8.8, toX: 10.6, toY: 5.2, width: 2.3).stroke()
    kStroke(fromX: 6.0, fromY: 8.8, toX: 10.8, toY: 12.6, width: 2.3).stroke()
  }

  private static func kStroke(
    fromX: CGFloat,
    fromY: CGFloat,
    toX: CGFloat,
    toY: CGFloat,
    width: CGFloat
  ) -> NSBezierPath {
    let path = NSBezierPath()
    path.move(to: NSPoint(x: fromX, y: fromY))
    path.line(to: NSPoint(x: toX, y: toY))
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    path.lineWidth = width
    return path
  }

  private static func cardPath(
    x: CGFloat,
    y: CGFloat,
    width: CGFloat,
    height: CGFloat,
    radius: CGFloat
  ) -> NSBezierPath {
    NSBezierPath(
      roundedRect: NSRect(x: x, y: y, width: width, height: height),
      xRadius: radius,
      yRadius: radius
    )
  }
}
