import Foundation

struct PersistenceController {
    let stateURL: URL

    init(stateURL: URL = PersistenceController.defaultStateURL()) {
        self.stateURL = stateURL
    }

    func load() -> PersistedState {
        do {
            let data = try Data(contentsOf: stateURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(PersistedState.self, from: data)
        } catch {
            return PersistedState(
                items: [],
                boards: [
                    Pinboard(title: "Quick Notes", accent: .amber),
                    Pinboard(title: "Links", accent: .blue),
                    Pinboard(title: "Assets", accent: .lime),
                    Pinboard(title: "Sprint Board", accent: .rose, isShared: true),
                ],
                settings: KClipSettings()
            )
        }
    }

    func save(_ state: PersistedState) throws {
        try FileManager.default.createDirectory(
            at: stateURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(state)
        try data.write(to: stateURL, options: [.atomic])
    }

    static func defaultStateURL() -> URL {
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return supportURL
            .appendingPathComponent("KClip", isDirectory: true)
            .appendingPathComponent("state.json")
    }
}
