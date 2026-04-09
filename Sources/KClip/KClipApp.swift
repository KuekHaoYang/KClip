import SwiftUI

@main
struct KClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView(store: .shared)
                .frame(width: 720, height: 520)
        }
    }
}
