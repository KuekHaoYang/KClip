import AppKit
import Foundation

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let store: KClipStore
    private let coordinator: WindowCoordinator

    init(store: KClipStore, coordinator: WindowCoordinator) {
        self.store = store
        self.coordinator = coordinator
        super.init()

        menu.delegate = self
        statusItem.button?.image = NSImage(systemSymbolName: "square.stack.3d.up.fill", accessibilityDescription: "KClip")
        statusItem.button?.contentTintColor = NSColor.white
        statusItem.menu = menu
        rebuildMenu()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        rebuildMenu()
    }

    private func rebuildMenu() {
        menu.removeAllItems()

        menu.addItem(withTitle: "Show KClip", action: #selector(showOverlay), keyEquivalent: "")
        menu.addItem(withTitle: store.settings.isMonitoringPaused ? "Resume Capture" : "Pause Capture", action: #selector(togglePause), keyEquivalent: "")
        menu.addItem(withTitle: store.isCollectingStack ? "Stop Stack Capture" : "Start Stack Capture", action: #selector(toggleStack), keyEquivalent: "")

        if !store.stackItemIDs.isEmpty {
            menu.addItem(withTitle: "Paste Next Stack Item", action: #selector(pasteNextStackItem), keyEquivalent: "")
        }

        if let latest = store.visibleItems.first {
            let title = "Copy Most Recent: \(latest.title)"
            menu.addItem(withTitle: title, action: #selector(copyMostRecent), keyEquivalent: "")
        }

        menu.addItem(.separator())
        menu.addItem(withTitle: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit KClip", action: #selector(quit), keyEquivalent: "q")
    }

    @objc private func showOverlay() {
        coordinator.showOverlay()
    }

    @objc private func togglePause() {
        store.togglePause()
        rebuildMenu()
    }

    @objc private func toggleStack() {
        store.toggleStackCollection()
        rebuildMenu()
    }

    @objc private func pasteNextStackItem() {
        coordinator.pasteNextStackItem()
    }

    @objc private func copyMostRecent() {
        guard let latest = store.visibleItems.first else {
            return
        }
        store.writeItemsToPasteboard([latest], plainText: false)
    }

    @objc private func openSettings() {
        coordinator.revealSettings()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
