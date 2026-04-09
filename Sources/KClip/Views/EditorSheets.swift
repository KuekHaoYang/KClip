import SwiftUI

struct BoardEditorSheet: View {
    @ObservedObject var store: KClipStore

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("New Pinboard")
                .font(.system(size: 24, weight: .semibold, design: .rounded))

            TextField("Pinboard title", text: $store.newBoardTitle)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 10) {
                Text("Accent")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    ForEach(Pinboard.Accent.allCases) { accent in
                        Button {
                            store.newBoardAccent = accent
                        } label: {
                            Circle()
                                .fill(accent.color)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(store.newBoardAccent == accent ? Color.primary : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Spacer()

            HStack {
                Spacer()

                Button("Cancel") {
                    store.isCreatingBoard = false
                }

                Button("Create") {
                    store.createBoard()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
    }
}

struct NoteComposerSheet: View {
    @ObservedObject var store: KClipStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("New Note")
                .font(.system(size: 24, weight: .semibold, design: .rounded))

            TextField("Title", text: $store.newNoteTitle)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $store.newNoteBody)
                .font(.system(size: 14, weight: .regular))
                .scrollContentBackground(.hidden)
                .background(Color.primary.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            HStack {
                Spacer()

                Button("Cancel") {
                    store.isCreatingNote = false
                }

                Button("Save") {
                    store.createNote()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
    }
}

struct RenameItemSheet: View {
    @ObservedObject var store: KClipStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Rename Item")
                .font(.system(size: 24, weight: .semibold, design: .rounded))

            TextField("Item title", text: $store.renameDraft)
                .textFieldStyle(.roundedBorder)

            Spacer()

            HStack {
                Spacer()

                Button("Cancel") {
                    store.renamingItemID = nil
                }

                Button("Apply") {
                    store.applyRename()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
    }
}
