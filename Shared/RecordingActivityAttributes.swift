import ActivityKit
import AppIntents
import Foundation

// Compiled into both the app and the Live Activity extension. The project
// defaults to MainActor isolation; these types are read from nonisolated
// contexts (ActivityKit encoding, App Intents metadata), so they opt out.

/// Data shown by the recording Live Activity on the lock screen and in the
/// Dynamic Island.
nonisolated struct RecordingActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        /// When the running clock started, already adjusted for time recorded
        /// before the last resume, so the system can render a live timer
        /// without the app waking up every second.
        var startDate: Date
        /// Set while capture is paused by an interruption (call, Siri); the
        /// clock is frozen at this value.
        var pausedElapsed: TimeInterval?
    }
}

extension Notification.Name {
    /// Posted in the app process when the Live Activity's Stop button is tapped.
    nonisolated static let stopRecordingRequested = Notification.Name("com.mietech.MieRecord.stopRecordingRequested")
}

/// The Stop button on the Live Activity. A `LiveActivityIntent` runs in the
/// app's process even when tapped from the lock screen, where the recording
/// screen picks up the notification and stops the session.
nonisolated struct StopRecordingIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Stop Recording"
    static let description = IntentDescription("Stops the recording in progress.")
    static let isDiscoverable = false

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .stopRecordingRequested, object: nil)
        return .result()
    }
}
