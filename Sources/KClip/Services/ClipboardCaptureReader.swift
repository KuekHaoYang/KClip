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
    if let imageFile = imageDataFromImageFileURL(in: pasteboard) { return imageFile }
    if let png = pasteboard.data(forType: .png) { return png }
    if let tiff = pasteboard.data(forType: .tiff), let png = ImageDataNormalizer.pngData(fromTIFF: tiff) { return png }
    if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
      return ImageDataNormalizer.pngData(from: image)
    }
    return nil
  }

  private static func imageDataFromImageFileURL(in pasteboard: NSPasteboard) -> Data? {
    let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] ?? []
    guard let url = urls.first(where: isImageFile), let image = NSImage(contentsOf: url) else { return nil }
    return ImageDataNormalizer.pngData(from: image)
  }

  private static func isImageFile(_ url: URL) -> Bool {
    UTType(filenameExtension: url.pathExtension)?.conforms(to: .image) == true
  }
}
