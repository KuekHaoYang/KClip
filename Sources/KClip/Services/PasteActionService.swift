import AppKit
import ApplicationServices
import Quartz

struct PasteActionService {
  var writeText: (String) -> Void
  var writeImage: (Data) -> Void
  var sendPaste: () -> Void

  init(
    writeText: @escaping (String) -> Void = PasteActionService.defaultWriteText,
    writeImage: @escaping (Data) -> Void = PasteActionService.defaultWriteImage,
    sendPaste: @escaping () -> Void = PasteActionService.defaultSendPaste
  ) {
    self.writeText = writeText
    self.writeImage = writeImage
    self.sendPaste = sendPaste
  }

  @discardableResult
  func preparePaste(text: String) -> Bool {
    guard text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
      return false
    }

    writeText(text)
    return true
  }

  @discardableResult
  func preparePaste(imageData: Data) -> Bool {
    guard imageData.isEmpty == false else { return false }
    writeImage(imageData)
    return true
  }

  @discardableResult
  func preparePaste(item: ClipboardItem) -> Bool {
    if let plainText = item.plainText { return preparePaste(text: plainText) }
    guard let imageData = item.imageData else { return false }
    return preparePaste(imageData: imageData)
  }

  func sendPreparedPaste() {
    DebugTrace.write("sendPreparedPaste trusted=\(AXIsProcessTrusted())")
    sendPaste()
  }

  @discardableResult
  func performPaste(text: String) -> Bool {
    guard preparePaste(text: text) else { return false }
    sendPreparedPaste()
    return true
  }

  @discardableResult
  func performPaste(item: ClipboardItem) -> Bool {
    guard preparePaste(item: item) else { return false }
    sendPreparedPaste()
    return true
  }

  private static func defaultWriteText(_ text: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
  }

  private static func defaultWriteImage(_ data: Data) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setData(data, forType: .png)
  }

  private static func defaultSendPaste() {
    let source = CGEventSource(stateID: .hidSystemState)
    let keyCode: CGKeyCode = 9
    let down = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
    let up = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
    down?.flags = .maskCommand
    up?.flags = .maskCommand
    down?.post(tap: .cghidEventTap)
    up?.post(tap: .cghidEventTap)
  }
}
