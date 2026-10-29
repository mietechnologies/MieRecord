import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

/// Lock screen and Dynamic Island presentation of a recording in progress.
struct RecordingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RecordingActivityAttributes.self) { context in
            LockScreenView(state: context.state)
                .padding()
                .activityBackgroundTint(nil)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    StatusLabel(state: context.state)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ElapsedText(state: context.state)
                        .font(.title2.weight(.semibold))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    StopButton()
                }
            } compactLeading: {
                StatusIcon(state: context.state)
            } compactTrailing: {
                ElapsedText(state: context.state)
                    .frame(maxWidth: 56)
            } minimal: {
                StatusIcon(state: context.state)
            }
            .keylineTint(.red)
        }
    }
}

private struct LockScreenView: View {
    let state: RecordingActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                StatusLabel(state: state)
                ElapsedText(state: state)
                    .font(.system(size: 34, weight: .light, design: .rounded))
            }
            Spacer()
            StopButton()
        }
    }
}

private struct StatusIcon: View {
    let state: RecordingActivityAttributes.ContentState

    var body: some View {
        Image(systemName: state.pausedElapsed == nil ? "record.circle.fill" : "pause.circle.fill")
            .foregroundStyle(state.pausedElapsed == nil ? .red : .orange)
    }
}

private struct StatusLabel: View {
    let state: RecordingActivityAttributes.ContentState

    var body: some View {
        Label {
            Text(state.pausedElapsed == nil ? "Recording" : "Paused")
                .font(.headline)
        } icon: {
            StatusIcon(state: state)
        }
    }
}

/// A live `m:ss` clock while recording, frozen while paused. The system
/// advances the timer itself, so the app does not update the activity each
/// second.
private struct ElapsedText: View {
    let state: RecordingActivityAttributes.ContentState

    var body: some View {
        Group {
            if let paused = state.pausedElapsed {
                Text(Self.format(paused))
            } else {
                Text(state.startDate, style: .timer)
            }
        }
        .monospacedDigit()
        .contentTransition(.numericText())
    }

    private static func format(_ seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded(.down))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }
}

private struct StopButton: View {
    var body: some View {
        Button(intent: StopRecordingIntent()) {
            Label("Stop", systemImage: "stop.fill")
                .font(.subheadline.weight(.semibold))
        }
        .tint(.red)
    }
}
