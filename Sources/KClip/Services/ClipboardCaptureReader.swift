import AppKit
import UniformTypeIdentifiers

enum ClipboardCapture {
  case text(String)
  case image(Data)
}

enum ClipboardCaptureReader {
  static func capture(from pasteboard: NSPasteboard) -> ClipboardCapture? {
    if let imageData = imageData(from: pasteboard) { return .image(imageData) }
    if let text = pasteboard.string(forType: .string) { return .text(text) }
    return nil
  }

  private static func imageData(from pasteboard: NSPasteboard) -> Data? {
    if let png = pasteboard.data(forType: .png) { return png }
    if let tiff = pasteboard.data(forType: .tiff), let png = pngData(from: tiff) { return png }
    if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
      return pngData(from: image)
    }
    let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] ?? []
    guard let url = urls.first(where: isImageFile), let image = NSImage(contentsOf: url) else { return nil }
    return pngData(from: image)
  }

  private static func isImageFile(_ url: URL) -> Bool {
    UTType(filenameExtension: url.pathExtension)?.conforms(to: .image) == true
  }

  private static func pngData(from tiff: Data) -> Data? {
    NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:])
  }

  private static func pngData(from image: NSImage) -> Data? {
    guard let tiff = image.tiffRepresentation else { return nil }
    return pngData(from: tiff)
  }
}
