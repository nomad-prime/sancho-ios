import Foundation

struct AppConfig {
    let useMocks: Bool
    let baseURL: URL

    static let `default`: AppConfig = {
        #if DEBUG
        let useMocks = false
        let baseURL = URL(string: "http://localhost:4000")!
        #elseif STAGING
        let useMocks = false
        let baseURL = URL(string: "https://staging.api.example.com")!
        #else
        let useMocks = false
        let baseURL = URL(string: "https://api.example.com")!
        #endif

        return AppConfig(useMocks: useMocks, baseURL: baseURL)
    }()
}
