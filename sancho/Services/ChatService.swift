import Foundation

struct APIChatMessage: Codable {
    let role: String
    let content: String
}

protocol ChatServiceProtocol {
    func chatStream(messages: [ChatMessage]) -> AsyncThrowingStream<String, Error>
}

struct ChatService: ChatServiceProtocol {
    let backend: BackendEnvironment
    var session: URLSession = .shared

    func chatStream(messages: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            guard let url = backend.url(for: "/chat") else {
                continuation.finish()
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let token = TokenStore.shared.accessToken
            if !token.isEmpty {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            do {
                let apiMessages = messages.map { APIChatMessage(role: $0.isCurrentUser ? "user" : "assistant", content: $0.text) }
                request.httpBody = try JSONEncoder().encode(["messages": apiMessages])
            } catch {
                continuation.finish(throwing: error)
                return
            }

            Task {
                do {
                    let (bytes, _) = try await session.bytes(for: request)
                    for try await line in bytes.lines {
                        continuation.yield(String(line))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
