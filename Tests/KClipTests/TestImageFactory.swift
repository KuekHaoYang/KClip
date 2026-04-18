import AppKit
import Foundation

func samplePNGData(size: NSSize = NSSize(width: 24, height: 16)) throws -> Data {
  let image = NSImage(size: size)
  image.lockFocus()
  NSColor.systemPink.setFill()
  NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
  image.unlockFocus()
  guard
    let tiff = image.tiffRepresentation,
    let rep = NSBitmapImageRep(data: tiff),
    let data = rep.representation(using: .png, properties: [:])
  else {
    throw TestImageFactoryError.encodingFailed
  }
  return data
}

enum TestImageFactoryError: Error {
  case encodingFailed
}
