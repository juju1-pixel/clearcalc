import CryptoKit
@preconcurrency import Foundation

// 接口信息待服务端确定后填写。密钥请勿写入公开仓库。
enum X4 {
    static let b = "" // base URL，例如：https://api.example.com
    static let p = "" // 接口路径，例如：/api/v1/basic/config
    static let i = "" // appId
    static let k = "" // appKey
    static let s = "" // source
    static let v = "1.0.0"
    static let d = "" // reqDomain
}

enum V5: Error {
    case invalidURL
    case emptyData
    case httpStatus(Int)
    case underlying(Error)
}

private final class C3: @unchecked Sendable {
    let value: (Result<[String: Any], V5>) -> Void

    init(_ value: @escaping (Result<[String: Any], V5>) -> Void) {
        self.value = value
    }
}

private final class D2: @unchecked Sendable {
    let value: Result<[String: Any], V5>

    init(_ value: Result<[String: Any], V5>) {
        self.value = value
    }
}

/// 通用签名 POST 请求。暂未接入任何业务接口。
final class N4: @unchecked Sendable {
    static let shared = N4()

    private init() {}

    func requestWebViewURL(completion: @escaping @MainActor @Sendable (URL?) -> Void) {
        post(X4.p) { result in
            let url = Self.webViewURL(from: result)
            Task { @MainActor in completion(url) }
        }
    }

    static func webViewURL(from result: Result<[String: Any], V5>) -> URL? {
        guard case .success(let payload) = result,
              payload["result"] as? Bool == true,
              let rawURL = payload["url"] as? String,
              let url = URL(string: rawURL.trimmingCharacters(in: .whitespacesAndNewlines)),
              url.scheme?.lowercased() == "https",
              let host = url.host, !host.isEmpty else { return nil }
        return url
    }

    static func shouldRecover(httpStatus: Int) -> Bool {
        (400...599).contains(httpStatus)
    }

    func post(
        _ path: String,
        params: [String: Any] = [:],
        completion: @escaping (Result<[String: Any], V5>) -> Void
    ) {
        let receiver = C3(completion)
        guard let url = endpoint(path) else {
            complete(D2(.failure(.invalidURL)), receiver)
            return
        }

        var body = merged(params)
        body["sign"] = sign(body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            complete(D2(.failure(.underlying(error))), receiver)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                self.complete(D2(.failure(.underlying(error))), receiver)
                return
            }
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                self.complete(D2(.failure(.httpStatus(response.statusCode))), receiver)
                return
            }
            guard let data else {
                self.complete(D2(.failure(.emptyData)), receiver)
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                self.complete(D2(.failure(.emptyData)), receiver)
                return
            }
            self.complete(D2(.success(json)), receiver)
        }.resume()
    }

    private func endpoint(_ path: String) -> URL? {
        let base = X4.b.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !base.isEmpty else { return nil }
        return URL(string: base + path)
    }

    private func merged(_ input: [String: Any]) -> [String: Any] {
        var output: [String: Any] = [
            "appId": X4.i,
            "deviceInfo": "",
            "udid": random(),
            "source": X4.s,
            "reqDomain": X4.d,
            "requestId": random(),
            "version": X4.v,
        ]
        for (key, value) in input where output[key] == nil {
            output[key] = value
        }
        return output
    }

    private func sign(_ values: [String: Any]) -> String {
        let joined = values.keys.sorted().compactMap { key -> String? in
            let value = text(values[key]!)
            return value.isEmpty ? nil : "\(key)=\(value)"
        }.joined(separator: "&")
        guard !joined.isEmpty else { return "" }
        return md5(joined + "&appKey=" + X4.k)
    }

    private func text(_ value: Any) -> String {
        switch value {
        case let value as String: return value
        case let value as Bool: return value ? "true" : "false"
        case let value as Int: return String(value)
        case let value as Double: return value == value.rounded() ? String(Int(value)) : String(value)
        default: return "\(value)"
        }
    }

    private func random() -> String {
        let alphabet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        return String((0..<32).compactMap { _ in alphabet.randomElement() })
    }

    private func md5(_ value: String) -> String {
        Insecure.MD5.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    private func complete(_ result: D2, _ receiver: C3) {
        DispatchQueue.main.async {
            receiver.value(result.value)
        }
    }
}

/// One automatic URL refresh per uninterrupted run of navigation failures.
@MainActor
final class U8 {
    typealias Fetch = (@escaping @MainActor @Sendable (URL?) -> Void) -> Void

    private let fetch: Fetch
    private var generation = 0
    private var attempted = false
    private var pendingRequest: UUID?

    init(fetch: @escaping Fetch = N4.shared.requestWebViewURL) {
        self.fetch = fetch
    }

    func navigationStarted(byUser: Bool = false) {
        generation += 1
        pendingRequest = nil
        if byUser { attempted = false }
    }

    func navigationFinished() {
        navigationStarted()
        attempted = false
    }

    func recover(apply: @escaping @MainActor @Sendable (URL) -> Void) {
        guard !attempted else { return }
        attempted = true
        let request = UUID()
        let revision = generation
        pendingRequest = request
        fetch { [weak self] url in
            guard let self,
                  self.pendingRequest == request,
                  self.generation == revision else { return }
            self.pendingRequest = nil
            guard let url else { return }
            apply(url)
        }
    }
}
