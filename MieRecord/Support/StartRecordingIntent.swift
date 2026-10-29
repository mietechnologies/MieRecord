import AppIntents

// The project defaults to MainActor isolation; App Intents metadata is read
// from nonisolated static members, so these types opt out. Only `perform()`
// touches UI state and is MainActor.

/// Opens MieRecord and starts a recording. Exposed to Shortcuts, Siri, and the
/// Action Button (Settings > Action Button > Shortcut > MieRecord).
nonisolated struct StartRecordingIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Recording"
    static let description = IntentDescription("Opens MieRecord and starts recording a conversation.")
    /// Recording needs the microphone and a visible stop control, so the app
    /// always comes to the foreground.
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        RecordingLaunchRequest.shared.request()
        return .result()
    }
}

nonisolated struct MieRecordShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartRecordingIntent(),
            phrases: [
                "Start recording in \(.applicationName)",
                "Start a recording in \(.applicationName)",
                "Record a conversation in \(.applicationName)",
            ],
            shortTitle: "Start Recording",
            systemImageName: "record.circle"
        )
    }
}
