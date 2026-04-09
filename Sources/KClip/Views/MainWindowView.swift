import AppKit
import SwiftUI

struct MainWindowView: View {
    @ObservedObject var store: KClipStore
    @ObservedObject var coordinator: WindowCoordinator

    @FocusState private var searchFocused: Bool
    @State private var eventMonitor = LocalEventMonitor()

    private var visibleItems: [ClipboardItem] {
        store.visibleItems
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 18) {
                header
                SearchBarView(
                    searchText: $store.searchText,
                    activeKindFilter: $store.activeKindFilter,
                    activeSourceFilter: $store.activeSourceFilter,
                    searchFocused: $searchFocused,
                    availableSources: store.sourceFilters
                )

                boardStrip
                cardScroller
                footer
            }
            .padding(26)
        }
        .frame(minWidth: 980, minHeight: 640)
        .sheet(isPresented: Binding(
            get: { store.previewItem != nil },
            set: { newValue in
                if !newValue {
                    store.hidePreview()
                }
            }
        )) {
            if let previewItem = store.previewItem {
                PreviewSheetView(store: store, itemID: previewItem.id)
                    .frame(minWidth: 860, minHeight: 620)
            }
        }
        .sheet(isPresented: $store.isCreatingBoard) {
            BoardEditorSheet(store: store)
                .frame(width: 420, height: 320)
        }
        .sheet(isPresented: $store.isCreatingNote) {
            NoteComposerSheet(store: store)
                .frame(width: 620, height: 460)
        }
        .sheet(isPresented: Binding(
            get: { store.renameItem != nil },
            set: { newValue in
                if !newValue {
                    store.renamingItemID = nil
                }
            }
        )) {
            RenameItemSheet(store: store)
                .frame(width: 420, height: 220)
        }
        .onAppear {
            store.prepareForPresentation()
            searchFocused = false
            eventMonitor.start(handler: handleKeyEvent(_:))
        }
        .onDisappear {
            eventMonitor.stop()
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "11131A"),
                    Color(hex: "1B2030"),
                    Color(hex: "F5B24D"),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 520, height: 520)
                .blur(radius: 110)
                .offset(x: 360, y: -220)

            Circle()
                .fill(Color(hex: "FF9B50", alpha: 0.45))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -320, y: 160)

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 28, x: 0, y: 16)
                .padding(18)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("KClip")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Clipboard memory, organized for fast recall.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.72))
            }

            Spacer()

            Label(
                store.settings.isMonitoringPaused ? "Capture paused" : "Capture live",
                systemImage: store.settings.isMonitoringPaused ? "pause.fill" : "circle.fill"
            )
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.14))
            )
            .foregroundStyle(.white)

            Menu {
                Button(store.settings.isMonitoringPaused ? "Resume Capture" : "Pause Capture") {
                    store.togglePause()
                }

                Button(store.isCollectingStack ? "Stop Stack Capture" : "Start Stack Capture") {
                    store.toggleStackCollection()
                }

                Button("New Note") {
                    store.isCreatingNote = true
                }

                Button("New Pinboard") {
                    store.isCreatingBoard = true
                }

                Divider()

                Button("Settings") {
                    coordinator.revealSettings()
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .menuStyle(.borderlessButton)
        }
    }

    private var boardStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                BoardChip(
                    title: "Clipboard",
                    accent: .white.opacity(0.9),
                    isSelected: store.selectedBoardID == nil,
                    isShared: false
                ) {
                    store.selectedBoardID = nil
                }

                ForEach(store.boards) { board in
                    BoardChip(
                        title: board.title,
                        accent: board.accent.color,
                        isSelected: store.selectedBoardID == board.id,
                        isShared: board.isShared
                    ) {
                        store.selectedBoardID = board.id
                    }
                }

                Button {
                    store.isCreatingBoard = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("Pinboard")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        }
    }

    private var cardScroller: some View {
        Group {
            if visibleItems.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 18) {
                        ForEach(Array(visibleItems.enumerated()), id: \.element.id) { index, item in
                            ClipboardCardView(
                                item: item,
                                index: index,
                                isSelected: store.selectedIDs.contains(item.id),
                                isCompact: store.settings.compactMode,
                                pinboards: store.boards,
                                onSelect: {
                                    store.select(item)
                                },
                                onPreview: {
                                    store.select(item)
                                    store.showPreviewForSelection()
                                },
                                onPaste: { plainText in
                                    store.select(item)
                                    coordinator.pasteSelection(plainText: plainText)
                                },
                                onCopy: {
                                    store.writeItemsToPasteboard([item], plainText: false)
                                },
                                onRename: {
                                    store.select(item)
                                    store.beginRenameSelection()
                                },
                                onDelete: {
                                    store.select(item)
                                    store.deleteSelection()
                                },
                                onPin: { boardID in
                                    store.select(item)
                                    store.assignSelectedItems(to: boardID)
                                },
                                onOpenOriginal: {
                                    store.select(item)
                                    store.openSelected()
                                }
                            )
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            footerPill(
                title: "\(visibleItems.count) items",
                icon: "square.stack.3d.up"
            )

            if !store.filterSummary.isEmpty {
                footerPill(title: store.filterSummary, icon: "line.3.horizontal.decrease.circle")
            }

            if store.isCollectingStack {
                footerPill(title: "Stack capture: \(store.stackItemIDs.count)", icon: "tray.full")
            }

            Spacer()

            footerPill(title: "Show/Hide ⇧⌘V", icon: "keyboard")
            footerPill(title: "Paste ⏎", icon: "arrow.turn.down.right")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                )
                .overlay {
                    VStack(spacing: 14) {
                        Image(systemName: "square.on.square.badge.person.crop")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.92))

                        Text("Clipboard history will appear here.")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Copy text, links, images, files, PDFs, or colors in any app. KClip captures them here and keeps them ready for search, pinning, and reuse.")
                            .font(.system(size: 14, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.white.opacity(0.72))
                            .frame(maxWidth: 480)

                        HStack(spacing: 12) {
                            Button("Create Note") {
                                store.isCreatingNote = true
                            }
                            .buttonStyle(KClipPrimaryButtonStyle())

                            Button("Open Settings") {
                                coordinator.revealSettings()
                            }
                            .buttonStyle(KClipSecondaryButtonStyle())
                        }
                    }
                    .padding(38)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func footerPill(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(Color.white.opacity(0.82))
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
        )
    }

    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let isTypingIntoTextView = NSApp.keyWindow?.firstResponder is NSTextView
        let hasModalSheet = store.previewItem != nil || store.isCreatingBoard || store.isCreatingNote || store.renameItem != nil

        if hasModalSheet {
            return false
        }

        if flags.contains(.command),
           let digits = event.charactersIgnoringModifiers,
           let number = Int(digits),
           (1...9).contains(number) {
            coordinator.quickPaste(index: number - 1, plainText: flags.contains(.shift))
            return true
        }

        if flags.contains(.command),
           let characters = event.charactersIgnoringModifiers?.lowercased() {
            switch characters {
            case "f":
                searchFocused = true
                return true
            case "n":
                if flags.contains(.shift) {
                    store.isCreatingBoard = true
                } else {
                    store.isCreatingNote = true
                }
                return true
            case "r":
                store.beginRenameSelection()
                return true
            case "o":
                store.openSelected()
                return true
            case "a":
                store.selectAllVisible()
                return true
            case ",":
                coordinator.revealSettings()
                return true
            default:
                break
            }
        }

        switch event.keyCode {
        case 53:
            coordinator.hideOverlay()
            return true
        case 123:
            if flags.contains(.command) {
                store.switchBoard(offset: -1)
            } else if !isTypingIntoTextView {
                store.moveSelection(offset: -1, extend: flags.contains(.shift))
            }
            return true
        case 124:
            if flags.contains(.command) {
                store.switchBoard(offset: 1)
            } else if !isTypingIntoTextView {
                store.moveSelection(offset: 1, extend: flags.contains(.shift))
            }
            return true
        case 36:
            coordinator.pasteSelection(plainText: flags.contains(.shift))
            return true
        case 49:
            store.showPreviewForSelection()
            return true
        case 51:
            if !isTypingIntoTextView {
                store.deleteSelection()
                return true
            }
        case 48:
            searchFocused.toggle()
            return true
        default:
            break
        }

        if isTypingIntoTextView {
            return false
        }

        let disallowedModifiers: NSEvent.ModifierFlags = [.command, .option, .control, .function]
        if flags.isDisjoint(with: disallowedModifiers),
           let characters = event.characters,
           characters.unicodeScalars.allSatisfy({ $0.value >= 32 && $0.value != 127 }) {
            searchFocused = true
            store.searchText.append(characters)
            return true
        }

        return false
    }
}

private struct BoardChip: View {
    var title: String
    var accent: Color
    var isSelected: Bool
    var isShared: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(accent)
                    .frame(width: 8, height: 8)

                if isShared {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(accent)
                }

                Text(title)
                    .lineLimit(1)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.08))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color.white.opacity(0.22) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct KClipPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color(hex: "11131A"))
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(hex: "F5B24D"))
                    .opacity(configuration.isPressed ? 0.8 : 1)
            )
    }
}

private struct KClipSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.1 : 0.14))
            )
    }
}
