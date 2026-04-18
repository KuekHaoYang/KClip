import Foundation

extension ClipboardStore {
  func record(text: String, sourceAppName: String? = nil, sourceBundleID: String? = nil) {
    let normalizedText = normalized(text)
    guard normalizedText.isEmpty == false, firstRegularItem?.plainText != normalizedText else { return }
    record(ClipboardItem(text: normalizedText, sourceAppName: sourceAppName, sourceBundleID: sourceBundleID))
  }

  func record(imageData: Data, sourceAppName: String? = nil, sourceBundleID: String? = nil) {
    guard imageData.isEmpty == false, firstRegularItem?.imageData != imageData else { return }
    record(ClipboardItem(imageData: imageData, sourceAppName: sourceAppName, sourceBundleID: sourceBundleID))
  }

  func record(_ item: ClipboardItem) {
    items.insert(item, at: regularStartIndex)
    trimIfNeeded()
    persist()
  }

  func normalized(_ text: String) -> String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
  var regularStartIndex: Int { items.firstIndex(where: { $0.isPinned == false }) ?? items.count }
  var firstRegularItem: ClipboardItem? { items.indices.contains(regularStartIndex) ? items[regularStartIndex] : nil }
  func trimIfNeeded() { if items.count > limit { items = Array(items.prefix(limit)) } }

  func persist() {
    let snapshot = items
    let fileURL = fileURL
    persistenceQueue.async {
      do {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: fileURL, options: .atomic)
      } catch {}
    }
  }
}
