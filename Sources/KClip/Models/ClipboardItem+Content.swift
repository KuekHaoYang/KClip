import AppKit

extension ClipboardItem {
  var isImage: Bool { imageData != nil }
  var isEditable: Bool { plainText != nil }
  var colorSnippet: ColorSnippet? { plainText.flatMap(ColorSnippet.parse) }
  var codeSnippet: CodeSnippet? { plainText.flatMap(CodeSnippet.parse) }
  var isColor: Bool { colorSnippet != nil }
  var isCode: Bool { codeSnippet != nil }

  var previewImage: NSImage? {
    guard let imageData else { return nil }
    return NSImage(data: imageData)
  }
}
