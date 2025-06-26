import Foundation

enum BackendEnvironment {
    case mock
    case live(URL)

    static var current: BackendEnvironment = {
        if ProcessInfo.processInfo.environment["SANCHO_USE_MOCKS"] == "true" {
            return .mock
        }
        if let urlString = ProcessInfo.processInfo.environment["SANCHO_BASE_URL"],
           let url = URL(string: urlString) {
            return .live(url)
        }
        return .live(URL(string: "http://localhost:3000")!)
    }()

    var baseURL: URL? {
        switch self {
        case .mock:
            return nil
        case let .live(url):
            return url
        }
    }

    func url(for path: String) -> URL? {
        guard let baseURL else { return nil }
        var trimmed = path
        if trimmed.hasPrefix("/") { trimmed.removeFirst() }
        return baseURL.appendingPathComponent(trimmed)
    }
}
