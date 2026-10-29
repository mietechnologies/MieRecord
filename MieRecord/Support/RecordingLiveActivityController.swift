import ActivityKit
import Foundation

/// Owns the single Live Activity that mirrors the recording in progress on the
/// lock screen and in the Dynamic Island. Every call is best-effort: the user
/// may have Live Activities turned off, and a failure here must never affect
/// the recording itself.
///
/// `Activity` is not `Sendable`, so only its `id` is kept here; the async
/// update and end calls look the activity up again in a nonisolated context.
final class RecordingLiveActivityController {
    private var activityID: String?

    /// Shows the activity, or updates it if one is already showing.
    func show(elapsed: TimeInterval, isPaused: Bool) {
        let state = RecordingActivityAttributes.ContentState(
            startDate: Date.now.addingTimeInterval(-elapsed),
            pausedElapsed: isPaused ? elapsed : nil
        )
        let content = ActivityContent(state: state, staleDate: nil)
        if let id = activityID {
            Task { await Self.update(id: id, content: content) }
        } else if ActivityAuthorizationInfo().areActivitiesEnabled {
            activityID = (try? Activity.request(attributes: RecordingActivityAttributes(), content: content, pushType: nil))?.id
        }
    }

    func end() {
        guard let id = activityID else { return }
        activityID = nil
        Task { await Self.end(ids: [id]) }
    }

    /// IDs of activities left behind by a previous process that crashed or was
    /// killed mid-recording. Snapshot this at launch, before any recording can
    /// start, so ending them later cannot touch the new recording's activity.
    static func runningActivityIDs() -> [String] {
        Activity<RecordingActivityAttributes>.activities.map(\.id)
    }

    nonisolated static func end(ids: [String]) async {
        for activity in Activity<RecordingActivityAttributes>.activities where ids.contains(activity.id) {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    private nonisolated static func update(id: String, content: ActivityContent<RecordingActivityAttributes.ContentState>) async {
        for activity in Activity<RecordingActivityAttributes>.activities where activity.id == id {
            await activity.update(content)
        }
    }
}
