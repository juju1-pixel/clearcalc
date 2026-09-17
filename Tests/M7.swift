import Foundation

@MainActor
private final class H9 {
    var callbacks: [@MainActor @Sendable (URL?) -> Void] = []
    var opened: [URL] = []
    lazy var recovery = L4 { [unowned self] completion in
        callbacks.append(completion)
    }

    func fail() {
        recovery.k3 { [weak self] url in self?.opened.append(url) }
    }
}

@main
private struct M7 {
    @MainActor
    static func main() {
        precondition(B7.r == "result" && B7.u == "url" && B7.h == "https")
        precondition(B7.sg == "sign" && B7.ai == "appId" && B7.ak == "appKey=")
        precondition(B7.po == "POST" && B7.ls == "LaunchScreen" && B7.rc == "RemoteConfigURL")
        precondition(B7.er == "Error" && B7.lc == "en_US_POSIX" && B7.vr == "1.0.0")
        precondition(B7.cj == "application/json;charset=UTF-8")

        let replacement = URL(string: "https://example.com/new")!
        let accepted = J6.m8(.success([
            B7.r: true, B7.u: "  https://example.com/new\n"
        ]))
        precondition(accepted == replacement)

        let ignored: [[String: Any]] = [
            [B7.r: false, B7.u: replacement.absoluteString],
            [B7.r: "true", B7.u: replacement.absoluteString],
            [B7.u: replacement.absoluteString],
            [B7.r: true],
            [B7.r: true, B7.u: "http://example.com"],
            [B7.r: true, B7.u: "https:///"],
            [B7.r: true, B7.u: ""]
        ]
        for payload in ignored {
            precondition(J6.m8(.success(payload)) == nil)
        }
        precondition(J6.m8(.failure(.c(503))) == nil)
        precondition(J6.m2(404))
        precondition(J6.m2(500))
        precondition(!J6.m2(200))
        precondition(!J6.m2(301))

        let success = H9()
        success.recovery.k1()
        success.fail()
        success.fail()
        precondition(success.callbacks.count == 1)
        success.callbacks[0](accepted)
        success.callbacks[0](accepted)
        precondition(success.opened == [replacement])
        success.recovery.k1()
        success.fail()
        precondition(success.callbacks.count == 1)
        success.recovery.k2()
        success.recovery.k1()
        success.fail()
        precondition(success.callbacks.count == 2)

        let declined = H9()
        declined.fail()
        declined.callbacks[0](J6.m8(.success([
            B7.r: false, B7.u: replacement.absoluteString
        ])))
        declined.fail()
        precondition(declined.opened.isEmpty)
        precondition(declined.callbacks.count == 1)

        declined.recovery.k1(true)
        declined.recovery.k1()
        declined.fail()
        precondition(declined.callbacks.count == 2)
        declined.callbacks[0](replacement)
        precondition(declined.opened.isEmpty)
        declined.callbacks[1](replacement)
        precondition(declined.opened == [replacement])

        let stale = H9()
        stale.fail()
        stale.recovery.k1()
        stale.callbacks[0](replacement)
        precondition(stale.opened.isEmpty)

        let completed = H9()
        completed.fail()
        completed.recovery.k2()
        completed.fail()
        completed.callbacks[0](replacement)
        precondition(completed.opened.isEmpty)
        completed.callbacks[1](replacement)
        precondition(completed.opened == [replacement])
        print("PASS")
    }
}
