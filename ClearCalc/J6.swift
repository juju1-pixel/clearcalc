import CryptoKit
@preconcurrency import Foundation

enum B7 {
    private static let x: UInt8 = 0x6E

    static let r = d([28, 11, 29, 27, 2, 26])
    static let u = d([27, 28, 2])
    static let h = d([6, 26, 26, 30, 29])
    static let sg = d([29, 7, 9, 0])
    static let ai = d([15, 30, 30, 39, 10])
    static let di = d([10, 11, 24, 7, 13, 11, 39, 0, 8, 1])
    static let ud = d([27, 10, 7, 10])
    static let so = d([29, 1, 27, 28, 13, 11])
    static let rd = d([28, 11, 31, 42, 1, 3, 15, 7, 0])
    static let ri = d([28, 11, 31, 27, 11, 29, 26, 39, 10])
    static let ve = d([24, 11, 28, 29, 7, 1, 0])
    static let ak = d([15, 30, 30, 37, 11, 23, 83])
    static let po = d([62, 33, 61, 58])
    static let ct = d([45, 1, 0, 26, 11, 0, 26, 67, 58, 23, 30, 11])
    static let cj = d([15, 30, 30, 2, 7, 13, 15, 26, 7, 1, 0, 65, 4, 29, 1, 0, 85, 13, 6, 15, 28, 29, 11, 26, 83, 59, 58, 40, 67, 86])
    static let tr = d([26, 28, 27, 11])
    static let fa = d([8, 15, 2, 29, 11])
    static let rc = d([60, 11, 3, 1, 26, 11, 45, 1, 0, 8, 7, 9, 59, 60, 34])
    static let ls = d([34, 15, 27, 0, 13, 6, 61, 13, 28, 11, 11, 0])
    static let sv = d([29, 13, 6, 11, 3, 15, 56, 11, 28, 29, 7, 1, 0])
    static let an = d([15, 0, 0, 1, 27, 0, 13, 11, 3, 11, 0, 26])
    static let ah = d([15, 13, 13, 11, 0, 26, 38, 11, 22])
    static let hw = d([6, 1, 27, 28, 2, 23, 57, 15, 9, 11])
    static let sp = d([29, 30, 2, 7, 26, 62, 11, 1, 30, 2, 11])
    static let er = d([43, 28, 28, 1, 28])
    static let lc = d([11, 0, 49, 59, 61, 49, 62, 33, 61, 39, 54])
    static let vr = d([95, 64, 94, 64, 94])
    static let hx = d([75, 94, 92, 22])
    static let az = d([94, 95, 92, 93, 90, 91, 88, 89, 86, 87, 47, 44, 45, 42, 43, 40, 41, 38, 39, 36, 37, 34, 35, 32, 33, 62, 63, 60, 61, 58, 59, 56, 57, 54, 55, 52, 15, 12, 13, 10, 11, 8, 9, 6, 7, 4, 5, 2, 3, 0, 1, 30, 31, 28, 29, 26, 27, 24, 25, 22, 23, 20])

    private static func d(_ v: [UInt8]) -> String {
        String(decoding: v.map { $0 ^ x }, as: UTF8.self)
    }
}

enum A5 {
    static let b = ""
    static let p = ""
    static let i = ""
    static let k = ""
    static let s = ""
    static let v = B7.vr
    static let d = ""
}

enum E7: Error {
    case a
    case b
    case c(Int)
    case d(Error)
}

private final class G2: @unchecked Sendable {
    let value: (Result<[String: Any], E7>) -> Void

    init(_ value: @escaping (Result<[String: Any], E7>) -> Void) {
        self.value = value
    }
}

private final class F8: @unchecked Sendable {
    let value: Result<[String: Any], E7>

    init(_ value: Result<[String: Any], E7>) {
        self.value = value
    }
}

final class J6: @unchecked Sendable {
    static let shared = J6()

    private init() {}

    func m4(completion: @escaping @MainActor @Sendable (URL?) -> Void) {
        m1(A5.p) { result in
            let url = Self.m8(result)
            Task { @MainActor in completion(url) }
        }
    }

    static func m8(_ result: Result<[String: Any], E7>) -> URL? {
        guard case .success(let payload) = result,
              payload[B7.r] as? Bool == true,
              let raw = payload[B7.u] as? String,
              let url = URL(string: raw.trimmingCharacters(in: .whitespacesAndNewlines)),
              url.scheme?.lowercased() == B7.h,
              let host = url.host, !host.isEmpty else { return nil }
        return url
    }

    static func m2(_ status: Int) -> Bool {
        (400...599).contains(status)
    }

    func m1(
        _ path: String,
        params: [String: Any] = [:],
        completion: @escaping (Result<[String: Any], E7>) -> Void
    ) {
        let receiver = G2(completion)
        guard let url = n4(path) else {
            n3(F8(.failure(.a)), receiver)
            return
        }

        var body = n5(params)
        body[B7.sg] = n6(body)

        var request = URLRequest(url: url)
        request.httpMethod = B7.po
        request.timeoutInterval = 15
        request.setValue(B7.cj, forHTTPHeaderField: B7.ct)

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            n3(F8(.failure(.d(error))), receiver)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                self.n3(F8(.failure(.d(error))), receiver)
                return
            }
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                self.n3(F8(.failure(.c(response.statusCode))), receiver)
                return
            }
            guard let data else {
                self.n3(F8(.failure(.b)), receiver)
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                self.n3(F8(.failure(.b)), receiver)
                return
            }
            self.n3(F8(.success(json)), receiver)
        }.resume()
    }

    private func n4(_ path: String) -> URL? {
        let base = A5.b.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !base.isEmpty else { return nil }
        return URL(string: base + path)
    }

    private func n5(_ input: [String: Any]) -> [String: Any] {
        var output: [String: Any] = [
            B7.ai: A5.i,
            B7.di: "",
            B7.ud: n8(),
            B7.so: A5.s,
            B7.rd: A5.d,
            B7.ri: n8(),
            B7.ve: A5.v,
        ]
        for (key, value) in input where output[key] == nil {
            output[key] = value
        }
        return output
    }

    private func n6(_ values: [String: Any]) -> String {
        let joined = values.keys.sorted().compactMap { key -> String? in
            let value = n7(values[key]!)
            return value.isEmpty ? nil : "\(key)=\(value)"
        }.joined(separator: "&")
        guard !joined.isEmpty else { return "" }
        return n9(joined + "&" + B7.ak + A5.k)
    }

    private func n7(_ value: Any) -> String {
        switch value {
        case let value as String: return value
        case let value as Bool: return value ? B7.tr : B7.fa
        case let value as Int: return String(value)
        case let value as Double: return value == value.rounded() ? String(Int(value)) : String(value)
        default: return "\(value)"
        }
    }

    private func n8() -> String {
        let alphabet = Array(B7.az)
        return String((0..<32).compactMap { _ in alphabet.randomElement() })
    }

    private func n9(_ value: String) -> String {
        Insecure.MD5.hash(data: Data(value.utf8)).map { String(format: B7.hx, $0) }.joined()
    }

    private func n3(_ result: F8, _ receiver: G2) {
        DispatchQueue.main.async {
            receiver.value(result.value)
        }
    }
}

@MainActor
final class L4 {
    typealias T = (@escaping @MainActor @Sendable (URL?) -> Void) -> Void

    private let t: T
    private var r = 0
    private var b = false
    private var i: UUID?

    init(fetch: @escaping T = J6.shared.m4) {
        self.t = fetch
    }

    func k1(_ user: Bool = false) {
        r += 1
        i = nil
        if user { b = false }
    }

    func k2() {
        k1()
        b = false
    }

    func k3(apply: @escaping @MainActor @Sendable (URL) -> Void) {
        guard !b else { return }
        b = true
        let request = UUID()
        let revision = r
        i = request
        t { [weak self] url in
            guard let self,
                  self.i == request,
                  self.r == revision else { return }
            self.i = nil
            guard let url else { return }
            apply(url)
        }
    }
}
