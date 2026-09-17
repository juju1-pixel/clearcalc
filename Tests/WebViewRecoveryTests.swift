import Foundation

// Run outside the app target:
// swiftc -swift-version 6 ClearCalc/APIClient.swift Tests/WebViewRecoveryTests.swift -o /tmp/ClearCalcWebViewRecoveryTests
@MainActor
private final class RecoveryHarness {
    var callbacks: [@MainActor @Sendable (URL?) -> Void] = []
    var opened: [URL] = []
    lazy var recovery = U8 { [unowned self] completion in
        callbacks.append(completion)
    }

    func fail() {
        recovery.recover { [weak self] url in self?.opened.append(url) }
    }
}

@main
private struct WebViewRecoveryTests {
    @MainActor
    static func main() {
        let replacement = URL(string: "https://example.com/new")!
        let accepted = N4.webViewURL(from: .success([
            "result": true, "url": "  https://example.com/new\n"
        ]))
        precondition(accepted == replacement, "Accept and trim a true HTTPS response")

        let ignored: [[String: Any]] = [
            ["result": false, "url": replacement.absoluteString],
            ["result": "true", "url": replacement.absoluteString],
            ["url": replacement.absoluteString],
            ["result": true],
            ["result": true, "url": "http://example.com"],
            ["result": true, "url": "https:///"],
            ["result": true, "url": ""]
        ]
        for payload in ignored {
            precondition(N4.webViewURL(from: .success(payload)) == nil,
                         "Ignore false or invalid responses")
        }
        precondition(N4.webViewURL(from: .failure(.httpStatus(503))) == nil)
        precondition(N4.shouldRecover(httpStatus: 404))
        precondition(N4.shouldRecover(httpStatus: 500))
        precondition(!N4.shouldRecover(httpStatus: 200))
        precondition(!N4.shouldRecover(httpStatus: 301))

        let success = RecoveryHarness()
        success.recovery.navigationStarted()
        success.fail()
        success.fail()
        precondition(success.callbacks.count == 1, "Coalesce duplicate failures")
        success.callbacks[0](accepted)
        success.callbacks[0](accepted)
        precondition(success.opened == [replacement], "Open a returned URL only once")
        success.recovery.navigationStarted()
        success.fail()
        precondition(success.callbacks.count == 1, "A failing replacement must not loop")
        success.recovery.navigationFinished()
        success.recovery.navigationStarted()
        success.fail()
        precondition(success.callbacks.count == 2, "A later failure after success may refresh")

        let declined = RecoveryHarness()
        declined.fail()
        declined.callbacks[0](N4.webViewURL(from: .success([
            "result": false, "url": replacement.absoluteString
        ])))
        declined.fail()
        precondition(declined.opened.isEmpty, "False must not navigate or save a URL")
        precondition(declined.callbacks.count == 1, "False must not cause a request loop")

        declined.recovery.navigationStarted(byUser: true)
        declined.recovery.navigationStarted()
        declined.fail()
        precondition(declined.callbacks.count == 2, "A manual refresh allows a new recovery attempt")
        declined.callbacks[0](replacement)
        precondition(declined.opened.isEmpty, "A manual refresh invalidates older replies")
        declined.callbacks[1](replacement)
        precondition(declined.opened == [replacement])

        let stale = RecoveryHarness()
        stale.fail()
        stale.recovery.navigationStarted()
        stale.callbacks[0](replacement)
        precondition(stale.opened.isEmpty, "Ignore replies after navigation has moved on")

        let completed = RecoveryHarness()
        completed.fail()
        completed.recovery.navigationFinished()
        completed.fail()
        completed.callbacks[0](replacement)
        precondition(completed.opened.isEmpty, "An old reply cannot override a new request")
        completed.callbacks[1](replacement)
        precondition(completed.opened == [replacement])
        print("PASS: response validation, HTTP status recovery, true/false recovery, duplicate failures, loop prevention, stale replies")
    }
}
