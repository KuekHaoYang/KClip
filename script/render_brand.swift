import AppKit
import Foundation

let fm = FileManager.default
let output = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "dist/Brand")

try fm.createDirectory(at: output, withIntermediateDirectories: true)
let iconset = output.appending(path: "KClip.iconset", directoryHint: .isDirectory)
try? fm.removeItem(at: iconset)
try fm.createDirectory(at: iconset, withIntermediateDirectories: true)

for size in [16, 32, 128, 256, 512] {
  try writeIcon(size: size, name: "icon_\(size)x\(size).png")
  try writeIcon(size: size * 2, name: "icon_\(size)x\(size)@2x.png")
}
try writeIcon(size: 1024, name: "../logo.png")

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = ["-c", "icns", "-o", output.appending(path: "AppIcon.icns").path, iconset.path]
try iconutil.run()
iconutil.waitUntilExit()
guard iconutil.terminationStatus == 0 else { throw BrandError.iconutilFailed }

enum BrandError: Error { case pngFailed, iconutilFailed }

func writeIcon(size: Int, name: String) throws {
  let image = NSImage(size: NSSize(width: size, height: size))
  image.lockFocus()
  drawIcon(in: NSRect(origin: .zero, size: image.size))
  image.unlockFocus()
  guard
    let data = image.tiffRepresentation,
    let rep = NSBitmapImageRep(data: data),
    let png = rep.representation(using: .png, properties: [:])
  else { throw BrandError.pngFailed }
  try png.write(to: iconset.appending(path: name).standardizedFileURL)
}

func drawIcon(in rect: NSRect) {
  let inset = rect.width * 0.08
  let shell = rect.insetBy(dx: inset, dy: inset)
  let radius = rect.width * 0.22
  let bg = NSBezierPath(roundedRect: shell, xRadius: radius, yRadius: radius)
  NSGradient(colors: [hex(0x4A4F55), hex(0x15181D)])?.draw(in: bg, angle: -45)
  stroke(bg, color: NSColor.white.withAlphaComponent(0.10), width: rect.width * 0.008)
  drawCard(in: rect, x: 0.23, y: 0.28, alpha: 0.08)
  drawCard(in: rect, x: 0.41, y: 0.36, alpha: 0.05)
  drawK(in: rect)
  NSColor(calibratedRed: 0.84, green: 0.92, blue: 1, alpha: 0.94).setFill()
  NSBezierPath(ovalIn: NSRect(x: rect.width * 0.63, y: rect.height * 0.69, width: rect.width * 0.055, height: rect.width * 0.055)).fill()
}

func drawCard(in rect: NSRect, x: CGFloat, y: CGFloat, alpha: CGFloat) {
  let box = NSRect(x: rect.width * x, y: rect.height * y, width: rect.width * 0.37, height: rect.height * 0.49)
  let card = NSBezierPath(roundedRect: box, xRadius: rect.width * 0.10, yRadius: rect.width * 0.10)
  NSColor.white.withAlphaComponent(alpha).setFill()
  card.fill()
  stroke(card, color: NSColor.white.withAlphaComponent(alpha + 0.06), width: rect.width * 0.008)
}

func drawK(in rect: NSRect) {
  let color = NSColor(calibratedRed: 0.48, green: 0.71, blue: 1, alpha: 1)
  stroke(line(rect, 0.35, 0.28, 0.35, 0.72), color: color, width: rect.width * 0.066)
  stroke(line(rect, 0.38, 0.50, 0.63, 0.28), color: color, width: rect.width * 0.066)
  stroke(line(rect, 0.39, 0.50, 0.63, 0.72), color: color, width: rect.width * 0.066)
}

func line(_ rect: NSRect, _ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) -> NSBezierPath {
  let path = NSBezierPath()
  path.move(to: NSPoint(x: rect.width * x1, y: rect.height * y1))
  path.line(to: NSPoint(x: rect.width * x2, y: rect.height * y2))
  path.lineCapStyle = .round
  return path
}

func stroke(_ path: NSBezierPath, color: NSColor, width: CGFloat) {
  color.setStroke()
  path.lineWidth = width
  path.lineJoinStyle = .round
  path.stroke()
}

func hex(_ value: Int) -> NSColor {
  NSColor(
    calibratedRed: CGFloat((value >> 16) & 0xFF) / 255,
    green: CGFloat((value >> 8) & 0xFF) / 255,
    blue: CGFloat(value & 0xFF) / 255,
    alpha: 1
  )
}
