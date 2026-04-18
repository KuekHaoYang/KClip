import AppKit

enum ImageDataNormalizer {
  static func pngData(from image: NSImage) -> Data? {
    guard let tiff = image.tiffRepresentation else { return nil }
    return pngData(fromTIFF: tiff)
  }

  static func pngData(fromTIFF tiff: Data) -> Data? {
    NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:])
  }
}
