import GoogleSignIn
import SwiftData
import SwiftUI

@main
struct SanchoApp: App {
    @State private var isAuthenticated = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    PracticeView().environment(\.font, .custom("Spectral-Regular", size: 16))
                } else {
                    StartScreenView(isAuthenticated: $isAuthenticated).environment(\.font, .custom("Spectral-Medium", size: 16))
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
//            .onAppear {
//                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//                    if let user = user {
//                        print(
//                            "Restored session for: \(user.profile?.email ?? "unknown")"
//                        )
//                        isAuthenticated = true
//                    } else if let error = error {
//                        print(
//                            "No existing Google session: \(error.localizedDescription)"
//                        )
//                    }
//                }
//            }
        }
    }

}
