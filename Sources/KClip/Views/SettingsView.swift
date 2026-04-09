import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: KClipStore
    @State private var excludedAppsText = ""

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            privacyTab
                .tabItem {
                    Label("Privacy", systemImage: "hand.raised")
                }

            shortcutsTab
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            syncTab
                .tabItem {
                    Label("Sync", systemImage: "icloud")
                }
        }
        .padding(24)
        .onAppear {
            excludedAppsText = store.settings.excludedApps.joined(separator: "\n")
        }
    }

    private var generalTab: some View {
        Form {
            Toggle("Capture clipboard changes", isOn: Binding(
                get: { !store.settings.isMonitoringPaused },
                set: { store.settings.isMonitoringPaused = !$0 }
            ))

            Toggle("Direct paste after selection", isOn: Binding(
                get: { store.settings.directPasteEnabled },
                set: { store.settings.directPasteEnabled = $0 }
            ))

            Toggle("Compact card layout", isOn: Binding(
                get: { store.settings.compactMode },
                set: { store.settings.compactMode = $0 }
            ))

            Stepper(value: Binding(
                get: { store.settings.retentionDays },
                set: { store.settings.retentionDays = $0 }
            ), in: 1...365) {
                Text("History retention: \(store.settings.retentionDays) day\(store.settings.retentionDays == 1 ? "" : "s")")
            }
        }
        .formStyle(.grouped)
    }

    private var privacyTab: some View {
        Form {
            Toggle("Dim the overlay during screen sharing", isOn: Binding(
                get: { store.settings.hideDuringScreenShare },
                set: { store.settings.hideDuringScreenShare = $0 }
            ))

            VStack(alignment: .leading, spacing: 10) {
                Text("Ignored apps")
                    .font(.system(size: 13, weight: .medium))

                Text("Add one app name or bundle identifier per line. Clipboard captures coming from these apps will be ignored.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                TextEditor(text: Binding(
                    get: { excludedAppsText },
                    set: { newValue in
                        excludedAppsText = newValue
                        store.settings.excludedApps = newValue
                            .split(whereSeparator: \.isNewline)
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                    }
                ))
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .frame(minHeight: 180)
                .scrollContentBackground(.hidden)
                .background(Color.primary.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .formStyle(.grouped)
    }

    private var shortcutsTab: some View {
        List {
            shortcutRow(title: "Show or hide KClip", value: "Shift-Command-V")
            shortcutRow(title: "Toggle stack capture", value: "Shift-Command-C")
            shortcutRow(title: "Pause capture", value: "Command-T")
            shortcutRow(title: "Paste selection", value: "Return")
            shortcutRow(title: "Paste selection as plain text", value: "Shift-Return")
            shortcutRow(title: "Quick paste visible items", value: "Command-1 to Command-9")
            shortcutRow(title: "Move between items", value: "Left / Right Arrow")
            shortcutRow(title: "Move between pinboards", value: "Command-Left / Command-Right")
        }
        .listStyle(.inset)
    }

    private var syncTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Sync is not configured in this build.")
                .font(.system(size: 20, weight: .semibold, design: .rounded))

            Text("This repository stores clipboard history locally on the Mac. Collaboration and cloud sync are intentionally not faked; they need a real backend or CloudKit implementation before they should be claimed.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func shortcutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}
