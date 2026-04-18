import AppKit

enum LinkPreviewImageAnalyzer {
  static func displayImage(from image: NSImage?) -> NSImage? {
    guard let image else { return nil }
    return shouldShow(image) ? image : nil
  }

  private static func shouldShow(_ image: NSImage) -> Bool {
    guard let rep = bitmapRep(for: image) else { return true }
    let grid = sampledLuminanceGrid(from: rep)
    let points = grid.flatMap(\.self)
    guard points.isEmpty == false else { return true }
    let mean = points.reduce(0, +) / CGFloat(points.count)
    let variance = points.reduce(0) { $0 + pow($1 - mean, 2) } / CGFloat(points.count)
    let range = (points.max() ?? mean) - (points.min() ?? mean)
    let edges = edgeFraction(in: grid)
    if variance < 0.001 && range < 0.05 { return false }
    if mean > 0.95 && range < 0.12 && edges < 0.04 { return false }
    return edges > 0.03 || range > 0.14 || variance > 0.003
  }

  private static func sampledLuminanceGrid(from rep: NSBitmapImageRep) -> [[CGFloat]] {
    let stepX = max(1, rep.pixelsWide / 28)
    let stepY = max(1, rep.pixelsHigh / 20)
    var rows: [[CGFloat]] = []
    for y in stride(from: 0, to: rep.pixelsHigh, by: stepY) {
      var row: [CGFloat] = []
      for x in stride(from: 0, to: rep.pixelsWide, by: stepX) {
        guard let color = rep.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else { continue }
        row.append((0.2126 * color.redComponent) + (0.7152 * color.greenComponent) + (0.0722 * color.blueComponent))
      }
      if row.isEmpty == false { rows.append(row) }
    }
    return rows
  }

  private static func edgeFraction(in grid: [[CGFloat]]) -> CGFloat {
    var edges = 0
    var comparisons = 0
    for y in grid.indices {
      for x in grid[y].indices {
        let value = grid[y][x]
        if x + 1 < grid[y].count {
          comparisons += 1
          if abs(value - grid[y][x + 1]) > 0.12 { edges += 1 }
        }
        if y + 1 < grid.count, x < grid[y + 1].count {
          comparisons += 1
          if abs(value - grid[y + 1][x]) > 0.12 { edges += 1 }
        }
      }
    }
    guard comparisons > 0 else { return 0 }
    return CGFloat(edges) / CGFloat(comparisons)
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
