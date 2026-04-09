import AppKit
import ApplicationServices
import Foundation

@MainActor
final class KClipStore: ObservableObject {
    static let shared = KClipStore()

    @Published private(set) var items: [ClipboardItem]
    @Published var boards: [Pinboard]
    @Published var settings: KClipSettings {
        didSet { save() }
    }
    @Published var selectedBoardID: UUID? {
        didSet {
            ensureSelection()
        }
    }
    @Published var selectedIDs: Set<UUID> = []
    @Published var searchText = ""
    @Published var activeKindFilter: ClipboardKind?
    @Published var activeSourceFilter: String?
    @Published var previewItemID: UUID?
    @Published var renamingItemID: UUID?
    @Published var renameDraft = ""
    @Published var isCreatingBoard = false
    @Published var newBoardTitle = ""
    @Published var newBoardAccent: Pinboard.Accent = .amber
    @Published var isCreatingNote = false
    @Published var newNoteTitle = ""
    @Published var newNoteBody = ""
    @Published var isCollectingStack = false
    @Published private(set) var stackItemIDs: [UUID] = []

    let persistence: PersistenceController
    private let monitor: ClipboardMonitor
    private let ownProcessName = "KClip"

    init(
        persistence: PersistenceController = PersistenceController(),
        monitor: ClipboardMonitor = ClipboardMonitor()
    ) {
        let state = persistence.load()
        self.persistence = persistence
        self.monitor = monitor
        items = state.items.sorted { $0.capturedAt > $1.capturedAt }
        boards = state.boards
        settings = state.settings
    }

    func start() {
        pruneExpiredItems()
        monitor.start { [weak self] capture in
            self?.handleCapture(capture)
        }
        ensureSelection()
    }

    func stop() {
        monitor.stop()
        save()
    }

    var visibleItems: [ClipboardItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return items.filter { item in
            let boardMatch = selectedBoardID == nil || item.boardID == selectedBoardID
            let kindMatch = activeKindFilter == nil || item.kind == activeKindFilter
            let sourceMatch = activeSourceFilter == nil || item.sourceAppName == activeSourceFilter
            let queryMatch = query.isEmpty || item.searchableText.contains(query)
            return boardMatch && kindMatch && sourceMatch && queryMatch
        }
    }

    var selectedItem: ClipboardItem? {
        orderedSelectedItems.first
    }

    var orderedSelectedItems: [ClipboardItem] {
        visibleItems.filter { selectedIDs.contains($0.id) }
    }

    var previewItem: ClipboardItem? {
        guard let previewItemID else {
            return nil
        }
        return items.first(where: { $0.id == previewItemID })
    }

    var renameItem: ClipboardItem? {
        guard let renamingItemID else {
            return nil
        }
        return items.first(where: { $0.id == renamingItemID })
    }

    var sourceFilters: [String] {
        Array(Set(items.map(\.sourceAppName))).sorted()
    }

    var filterSummary: String {
        var parts: [String] = []
        if let activeKindFilter {
            parts.append(activeKindFilter.label)
        }
        if let activeSourceFilter {
            parts.append(activeSourceFilter)
        }
        if !searchText.isEmpty {
            parts.append("“\(searchText)”")
        }
        return parts.joined(separator: " · ")
    }

    func prepareForPresentation() {
        pruneExpiredItems()
        ensureSelection()
    }

    func select(_ item: ClipboardItem) {
        selectedIDs = [item.id]
    }

    func moveSelection(offset: Int, extend: Bool = false) {
        let items = visibleItems
        guard !items.isEmpty else {
            return
        }

        let selectedIndex = selectedItem.flatMap { item in
            items.firstIndex(where: { $0.id == item.id })
        } ?? 0
        let nextIndex = max(0, min(items.count - 1, selectedIndex + offset))
        let target = items[nextIndex]

        if extend {
            selectedIDs.insert(target.id)
        } else {
            selectedIDs = [target.id]
        }
    }

    func switchBoard(offset: Int) {
        let allBoards = [UUID?.none] + boards.map(\.id)
        let currentIndex = allBoards.firstIndex(where: { $0 == selectedBoardID }) ?? 0
        let nextIndex = max(0, min(allBoards.count - 1, currentIndex + offset))
        selectedBoardID = allBoards[nextIndex]
    }

    func clearFilters() {
        activeKindFilter = nil
        activeSourceFilter = nil
    }

    func selectAllVisible() {
        selectedIDs = Set(visibleItems.map(\.id))
    }

    func createBoard() {
        let trimmed = newBoardTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        boards.append(Pinboard(title: trimmed, accent: newBoardAccent))
        newBoardTitle = ""
        newBoardAccent = .amber
        isCreatingBoard = false
        save()
    }

    func createNote() {
        let body = newNoteBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else {
            return
        }

        let explicitTitle = newNoteTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = explicitTitle.isEmpty ? ClipboardItem.makeTitle(kind: .text, payload: .text(body)) : explicitTitle

        let note = ClipboardItem(
            title: title,
            kind: .text,
            sourceAppName: ownProcessName,
            sourceBundleID: Bundle.main.bundleIdentifier,
            fingerprint: Fingerprint.make("note-\(UUID().uuidString)-\(body)"),
            boardID: selectedBoardID,
            payload: .text(body)
        )

        items.insert(note, at: 0)
        isCreatingNote = false
        newNoteTitle = ""
        newNoteBody = ""
        select(note)
        save()
    }

    func beginRenameSelection() {
        guard let item = selectedItem else {
            return
        }

        renamingItemID = item.id
        renameDraft = item.title
    }

    func applyRename() {
        guard let renamingItemID else {
            return
        }

        let trimmed = renameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.renamingItemID = nil
            return
        }

        guard let index = items.firstIndex(where: { $0.id == renamingItemID }) else {
            self.renamingItemID = nil
            return
        }

        items[index].title = trimmed
        self.renamingItemID = nil
        save()
    }

    func updateTextItem(id: UUID, title: String, body: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return
        }

        items[index].title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].payload = .text(body)
        items[index].fingerprint = Fingerprint.make(body)
        save()
    }

    func updateLinkItem(id: UUID, title: String, urlString: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return
        }

        items[index].title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].payload = .link(urlString)
        items[index].fingerprint = Fingerprint.make(urlString)
        save()
    }

    func assignSelectedItems(to boardID: UUID?) {
        for id in selectedIDs {
            guard let index = items.firstIndex(where: { $0.id == id }) else {
                continue
            }
            items[index].boardID = boardID
        }

        save()
    }

    func deleteSelection() {
        let deleted = selectedIDs
        items.removeAll { deleted.contains($0.id) }
        stackItemIDs.removeAll { deleted.contains($0) }
        selectedIDs.removeAll()
        ensureSelection()
        save()
    }

    func togglePause() {
        settings.isMonitoringPaused.toggle()
    }

    func toggleStackCollection() {
        isCollectingStack.toggle()
        if !isCollectingStack {
            stackItemIDs.removeAll()
        }
    }

    func itemForQuickPaste(index: Int) -> ClipboardItem? {
        let items = visibleItems
        guard items.indices.contains(index) else {
            return nil
        }
        return items[index]
    }

    func nextStackItem() -> ClipboardItem? {
        guard let id = stackItemIDs.first,
              let item = items.first(where: { $0.id == id })
        else {
            return nil
        }

        stackItemIDs.removeFirst()
        return item
    }

    func consumeStackItem(_ itemID: UUID) {
        stackItemIDs.removeAll { $0 == itemID }
    }

    func writeSelectionToPasteboard(itemIDs: [UUID], plainText: Bool) {
        let selected = items.filter { itemIDs.contains($0.id) }
        writeItemsToPasteboard(selected, plainText: plainText)
    }

    func writeItemsToPasteboard(_ items: [ClipboardItem], plainText: Bool) {
        guard !items.isEmpty else {
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        if items.count > 1 || plainText {
            let combined = items
                .map(\.plainTextRepresentation)
                .joined(separator: "\n")
            pasteboard.setString(combined, forType: .string)
            return
        }

        let item = items[0]

        switch item.payload {
        case let .text(value):
            pasteboard.setString(value, forType: .string)
        case let .link(value):
            pasteboard.setString(value, forType: .string)
            if let url = URL(string: value) {
                pasteboard.writeObjects([url as NSURL])
            }
        case let .image(snapshot):
            pasteboard.setData(snapshot.pngData, forType: .png)
        case let .file(snapshot):
            let urls = snapshot.paths.map(URL.init(fileURLWithPath:))
            pasteboard.writeObjects(urls as [NSURL])
        case let .color(snapshot):
            pasteboard.setString(snapshot.hex, forType: .string)
        case let .pdf(snapshot):
            pasteboard.setData(snapshot.data, forType: .pdf)
        }
    }

    func openSelected() {
        guard let item = selectedItem else {
            return
        }

        switch item.payload {
        case let .link(value):
            guard let url = URL(string: value) else {
                return
            }
            NSWorkspace.shared.open(url)
        case let .file(snapshot):
            let urls = snapshot.paths.map(URL.init(fileURLWithPath:))
            NSWorkspace.shared.activateFileViewerSelecting(urls)
        default:
            break
        }
    }

    func showPreviewForSelection() {
        previewItemID = selectedItem?.id
    }

    func hidePreview() {
        previewItemID = nil
    }

    func supportsDirectPaste() -> Bool {
        settings.directPasteEnabled && AXIsProcessTrusted()
    }

    private func handleCapture(_ capture: ClipboardCapture) {
        guard !settings.isMonitoringPaused else {
            return
        }

        if shouldExcludeCapture(named: capture.sourceAppName, bundleID: capture.sourceBundleID) {
            return
        }

        if items.first?.fingerprint == capture.fingerprint {
            return
        }

        let item = ClipboardItem(
            title: capture.title,
            kind: capture.kind,
            sourceAppName: capture.sourceAppName,
            sourceBundleID: capture.sourceBundleID,
            fingerprint: capture.fingerprint,
            payload: capture.payload
        )

        items.removeAll { $0.fingerprint == capture.fingerprint && $0.boardID == nil }
        items.insert(item, at: 0)

        if isCollectingStack {
            stackItemIDs.append(item.id)
        }

        pruneExpiredItems()
        ensureSelection()
        save()
    }

    private func shouldExcludeCapture(named name: String, bundleID: String?) -> Bool {
        let normalizedName = name.lowercased()
        let normalizedBundleID = bundleID?.lowercased()

        return settings.excludedApps.contains { rule in
            let normalizedRule = rule.lowercased()
            return normalizedRule == normalizedName || normalizedRule == normalizedBundleID
        }
    }

    private func pruneExpiredItems() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -settings.retentionDays, to: .now) ?? .distantPast
        items.removeAll { item in
            item.boardID == nil && item.capturedAt < cutoffDate
        }
    }

    private func ensureSelection() {
        let visibleIDSet = Set(visibleItems.map(\.id))
        selectedIDs = selectedIDs.intersection(visibleIDSet)

        if selectedIDs.isEmpty, let firstItem = visibleItems.first {
            selectedIDs = [firstItem.id]
        }
    }

    private func save() {
        do {
            try persistence.save(
                PersistedState(
                    items: items,
                    boards: boards,
                    settings: settings
                )
            )
        } catch {
            NSLog("KClip failed to save state: \(error.localizedDescription)")
        }
    }
}
