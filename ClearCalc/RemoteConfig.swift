import Foundation
import SwiftUI

/// The only remotely configurable content in ClearCalc is a short public notice
/// and the calculator's accent color. The schema intentionally has no URLs,
/// feature switches, executable content, or navigation directives.
struct R7: Decodable, Equatable {
    static let fallback = R7(schemaVersion: 1, announcement: nil, accentHex: "#526BFF")

    let schemaVersion: Int
    let announcement: String?
    let accentHex: String

    func validated() -> R7? {
        guard schemaVersion == 1,
              Color(remoteHex: accentHex) != nil else { return nil }

        let trimmedAnnouncement = announcement?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedAnnouncement?.count ?? 0 <= 140 else { return nil }

        return R7(
            schemaVersion: schemaVersion,
            announcement: trimmedAnnouncement?.isEmpty == true ? nil : trimmedAnnouncement,
            accentHex: accentHex.uppercased()
        )
    }
}

@MainActor
final class S6: ObservableObject {
    @Published private(set) var configuration = R7.fallback

    private let endpoint: URL?

    init(bundle: Bundle = .main) {
        let rawURL = (bundle.object(forInfoDictionaryKey: "RemoteConfigURL") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        endpoint = URL(string: rawURL).flatMap { $0.scheme == "https" ? $0 : nil }
    }

    func refresh() async {
        guard let endpoint else { return }

        var request = URLRequest(url: endpoint)
        request.timeoutInterval = 8
        request.cachePolicy = .reloadIgnoringLocalCacheData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  data.count <= 16_384,
                  let config = try? JSONDecoder().decode(R7.self, from: data),
                  let validConfig = config.validated() else { return }
            configuration = validConfig
        } catch {
            // The offline fallback is intentional: remote configuration is optional.
        }
    }
}

extension Color {
    init?(remoteHex: String) {
        let value = remoteHex.trimmingCharacters(in: .whitespacesAndNewlines)
        let hex = value.hasPrefix("#") ? String(value.dropFirst()) : value
        guard hex.count == 6, let rgb = UInt64(hex, radix: 16) else { return nil }

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
