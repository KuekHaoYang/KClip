import AppKit
import ApplicationServices
import Carbon.HIToolbox
import Foundation
import SwiftUI

@MainActor
final class WindowCoordinator: ObservableObject {
    static let shared = WindowCoordinator()

    private var overlayWindow: NSWindow?
    private weak var store: KClipStore?
    private var previousApplication: NSRunningApplication?

    func configure(with store: KClipStore) {
        self.store = store
        ensureOverlayWindow()
    }

    func toggleOverlay() {
        guard let overlayWindow else {
            showOverlay()
            return
        }

        if overlayWindow.isVisible {
            hideOverlay()
        } else {
            showOverlay()
        }
    }

    func showOverlay() {
        ensureOverlayWindow()
        previousApplication = NSWorkspace.shared.frontmostApplication
        store?.prepareForPresentation()

        guard let overlayWindow else {
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        overlayWindow.center()
        overlayWindow.makeKeyAndOrderFront(nil)
    }

    func hideOverlay() {
        overlayWindow?.orderOut(nil)
        reactivatePreviousApplication()
    }

    func revealSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func pasteSelection(plainText: Bool = false) {
        guard let store else {
            return
        }

        let selected = store.orderedSelectedItems
        guard !selected.isEmpty else {
            return
        }

        store.writeItemsToPasteboard(selected, plainText: plainText)
        overlayWindow?.orderOut(nil)
        reactivatePreviousApplication()

        guard store.supportsDirectPaste() else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.sendPasteShortcut()
        }
    }

    func quickPaste(index: Int, plainText: Bool = false) {
        guard let store,
              let item = store.itemForQuickPaste(index: index)
        else {
            return
        }

        store.select(item)
        pasteSelection(plainText: plainText)
    }

    func pasteNextStackItem() {
        guard let store,
              let item = store.nextStackItem()
        else {
            return
        }

        store.writeItemsToPasteboard([item], plainText: false)
        reactivatePreviousApplication()

        guard store.supportsDirectPaste() else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.sendPasteShortcut()
        }
    }

    private func ensureOverlayWindow() {
        guard overlayWindow == nil, let store else {
            return
        }

        let view = MainWindowView(store: store, coordinator: self)
        let hostingView = NSHostingView(rootView: view)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1180, height: 760),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.level = .floating
        window.isMovableByWindowBackground = true
        window.standardWindowButton(.zoomButton)?.isHidden = false
        window.contentView = hostingView
        window.setFrameAutosaveName("KClipOverlayWindow")
        overlayWindow = window
    }

    private func reactivatePreviousApplication() {
        previousApplication?.activate(options: [])
    }

    private func sendPasteShortcut() {
        guard let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
        else {
            return
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
