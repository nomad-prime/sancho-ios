import Foundation
import SwiftUI

class TokenStore: ObservableObject {
    static let shared = TokenStore()

    @AppStorage("supabaseAccessToken") var accessToken: String = ""
    
    func clear() {
        accessToken = ""
    }

    func set(token: String) {
        accessToken = token
    }
}
