import Foundation

final class BackendEnvironment {
    enum Mode {
        case mock
        case live(URL)
    }

    let mode: Mode

    init(config: AppConfig) {
        if config.useMocks {
            self.mode = .mock
        } else {
            self.mode = .live(config.baseURL)
        }
    }

    func url(for path: String) -> URL? {
        guard case let .live(baseURL) = mode else { return nil }
        var trimmed = path
        if trimmed.hasPrefix("/") { trimmed.removeFirst() }
        return baseURL.appendingPathComponent(trimmed)
    }
}
