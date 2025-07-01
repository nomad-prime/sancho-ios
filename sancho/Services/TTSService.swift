import Foundation
import AVFoundation

protocol TTSServiceProtocol {
    func synthesizeSpeech(text: String, voiceId: String?) async throws -> Data
}

struct TTSService: TTSServiceProtocol {
    let backend: BackendEnvironment
    var session: URLSession = .shared

    func synthesizeSpeech(text: String, voiceId: String? = nil) async throws -> Data {
        guard let url = backend.url(for: "/tts") else {
            return Data()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: String] = ["text": text]
        if let voiceId { body["voiceId"] = voiceId }
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
