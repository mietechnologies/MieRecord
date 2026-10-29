import ActivityKit
import Foundation

/// Owns the single Live Activity that mirrors the recording in progress on the
/// lock screen and in the Dynamic Island. Every call is best-effort: the user
/// may have Live Activities turned off, and a failure here must never affect
/// the recording itself.
final class RecordingLiveActivityController {
    private var activity: Activity<RecordingActivityAttributes>?

    /// Shows the activity, or updates it if one is already showing.
    func show(elapsed: TimeInterval, isPaused: Bool) {
        let state = RecordingActivityAttributes.ContentState(
            startDate: Date.now.addingTimeInterval(-elapsed),
            pausedElapsed: isPaused ? elapsed : nil
        )
        let content = ActivityContent(state: state, staleDate: nil)
        if let activity {
            Task { await activity.update(content) }
        } else if ActivityAuthorizationInfo().areActivitiesEnabled {
            activity = try? Activity.request(attributes: RecordingActivityAttributes(), content: content, pushType: nil)
        }
    }

    func end() {
        guard let activity else { return }
        self.activity = nil
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }

    /// Activities left behind by a previous process that crashed or was killed
    /// mid-recording. Snapshot this at launch, before any recording can start,
    /// so ending them later cannot touch the new recording's activity.
    static func runningActivities() -> [Activity<RecordingActivityAttributes>] {
        Activity<RecordingActivityAttributes>.activities
    }

    static func end(_ activities: [Activity<RecordingActivityAttributes>]) async {
        for activity in activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
