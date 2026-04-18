import AppKit

enum LinkPreviewImageAnalyzer {
  static func displayImage(from image: NSImage?) -> NSImage? {
    guard let image, shouldShow(image) else { return nil }
    return image
  }

  private static func shouldShow(_ image: NSImage) -> Bool {
    guard let rep = bitmapRep(for: image) else { return true }
    let points = sampledLuminance(from: rep)
    guard points.isEmpty == false else { return true }
    let mean = points.reduce(0, +) / CGFloat(points.count)
    let variance = points.reduce(0) { $0 + pow($1 - mean, 2) } / CGFloat(points.count)
    if variance < 0.004 { return false }
    return !(mean > 0.86 && variance < 0.012)
  }

  private static func sampledLuminance(from rep: NSBitmapImageRep) -> [CGFloat] {
    let stepX = max(1, rep.pixelsWide / 18)
    let stepY = max(1, rep.pixelsHigh / 18)
    var values: [CGFloat] = []
    for y in stride(from: 0, to: rep.pixelsHigh, by: stepY) {
      for x in stride(from: 0, to: rep.pixelsWide, by: stepX) {
        guard let color = rep.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else { continue }
        values.append((0.2126 * color.redComponent) + (0.7152 * color.greenComponent) + (0.0722 * color.blueComponent))
      }
    }
    return values
  }

  private static func bitmapRep(for image: NSImage) -> NSBitmapImageRep? {
    if let rep = image.representations.compactMap({ $0 as? NSBitmapImageRep }).first { return rep }
    let width = max(1, Int(image.size.width))
    let height = max(1, Int(image.size.height))
    guard
      let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
      )
    else { return nil }
    rep.size = image.size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(origin: .zero, size: image.size))
    NSGraphicsContext.restoreGraphicsState()
    return rep
  }
}
