import Foundation
import SwiftUI

struct W4: Equatable {
    static let fallback = W4(a: 1, n: nil, x: "#526BFF")

    let a: Int
    let n: String?
    let x: String

    func v1() -> W4? {
        guard a == 1, Color(hx: x) != nil else { return nil }
        let t = n?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t?.count ?? 0 <= 140 else { return nil }
        return W4(a: a, n: t?.isEmpty == true ? nil : t, x: x.uppercased())
    }
}

extension W4: Decodable {
    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: P4.self)
        a = try box.decode(Int.self, forKey: P4(B7.sv))
        n = try box.decodeIfPresent(String.self, forKey: P4(B7.an))
        x = try box.decode(String.self, forKey: P4(B7.ah))
    }

    private struct P4: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init(_ value: String) { stringValue = value }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }
}

@MainActor
final class N2: ObservableObject {
    @Published private(set) var z = W4.fallback

    private let p: URL?

    init(bundle: Bundle = .main) {
        let raw = (bundle.object(forInfoDictionaryKey: B7.rc) as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        p = URL(string: raw).flatMap { $0.scheme == B7.h ? $0 : nil }
    }

    func s1() async {
        guard let p else { return }
        var request = URLRequest(url: p)
        request.timeoutInterval = 8
        request.cachePolicy = .reloadIgnoringLocalCacheData
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode),
                  data.count <= 16_384,
                  let config = try? JSONDecoder().decode(W4.self, from: data),
                  let valid = config.v1() else { return }
            z = valid
        } catch {}
    }
}

extension Color {
    init?(hx: String) {
        let value = hx.trimmingCharacters(in: .whitespacesAndNewlines)
        let hex = value.hasPrefix("#") ? String(value.dropFirst()) : value
        guard hex.count == 6, let rgb = UInt64(hex, radix: 16) else { return nil }
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
