import Observation

/// Hands a "start recording" request from outside the view hierarchy (the App
/// Intent behind the Action Button and Shortcuts) to the UI. The intent can run
/// before the first scene appears, so the request is held here until a view
/// consumes it.
@Observable
final class RecordingLaunchRequest {
    static let shared = RecordingLaunchRequest()

    private(set) var isPending = false

    func request() {
        isPending = true
    }

    /// Returns whether a request was waiting, and clears it.
    @discardableResult
    func consume() -> Bool {
        defer { isPending = false }
        return isPending
    }
}
