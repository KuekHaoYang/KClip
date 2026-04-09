import Foundation
import Testing
@testable import KClip

@MainActor
struct KClipTests {
    @Test
    func textTitlesUseTheFirstReadableLine() async throws {
        let payload = ClipboardPayload.text("   Hello from KClip\nSecondary line")
        let title = ClipboardItem.makeTitle(kind: .text, payload: payload)

        #expect(title == "Hello from KClip")
    }

    @Test
    func boardSelectionFiltersVisibleItems() async throws {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let persistence = PersistenceController(stateURL: tempURL)
        let board = Pinboard(title: "Links", accent: .blue)

        try persistence.save(
            PersistedState(
                items: [
                    ClipboardItem(
                        title: "Pinned",
                        kind: .text,
                        sourceAppName: "Notes",
                        sourceBundleID: nil,
                        fingerprint: "1",
                        boardID: board.id,
                        payload: .text("Pinned value")
                    ),
                    ClipboardItem(
                        title: "Loose",
                        kind: .text,
                        sourceAppName: "Notes",
                        sourceBundleID: nil,
                        fingerprint: "2",
                        boardID: nil,
                        payload: .text("Loose value")
                    ),
                ],
                boards: [board],
                settings: KClipSettings()
            )
        )

        let store = KClipStore(persistence: persistence, monitor: ClipboardMonitor())
        store.selectedBoardID = board.id

        #expect(store.visibleItems.count == 1)
        #expect(store.visibleItems.first?.title == "Pinned")
    }

    @Test
    func searchAndSourceFiltersCompose() async throws {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        let persistence = PersistenceController(stateURL: tempURL)

        try persistence.save(
            PersistedState(
                items: [
                    ClipboardItem(
                        title: "Release checklist",
                        kind: .text,
                        sourceAppName: "Notes",
                        sourceBundleID: nil,
                        fingerprint: "a",
                        payload: .text("Ship KClip release")
                    ),
                    ClipboardItem(
                        title: "Reference URL",
                        kind: .link,
                        sourceAppName: "Safari",
                        sourceBundleID: nil,
                        fingerprint: "b",
                        payload: .link("https://example.com")
                    ),
                ],
                boards: [],
                settings: KClipSettings()
            )
        )

        let store = KClipStore(persistence: persistence, monitor: ClipboardMonitor())
        store.searchText = "release"
        store.activeSourceFilter = "Notes"

        #expect(store.visibleItems.count == 1)
        #expect(store.visibleItems.first?.title == "Release checklist")
    }
}
