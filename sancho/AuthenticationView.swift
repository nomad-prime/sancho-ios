import GoogleSignIn
import GoogleSignInSwift
import Supabase
import SwiftUI

struct AuthenticationView: View {
    @Binding var isAuthenticated: Bool
    @StateObject private var tokenStore = TokenStore.shared

    var body: some View {

        VStack {
            SanchoGoogleButton(variant: .continueWithGoogle) {
                guard
                    let rootViewController = self.rootViewController
                else {
                    print("No root view controller")
                    return
                }
                Task {
                    do {
                        let result =
                            try await GIDSignIn.sharedInstance
                            .signIn(
                                withPresenting: rootViewController
                            )

                        guard
                            let idToken = result.user.idToken?
                                .tokenString
                        else {
                            print("Missing tokens")
                            return
                        }

                        let accessToken = result.user.accessToken
                            .tokenString

                        let session = try await SupabaseClientSingle.shared
                            .auth.signInWithIdToken(
                                credentials:
                                    OpenIDConnectCredentials(
                                        provider: .google,
                                        idToken: idToken,
                                        accessToken: accessToken
                                    )
                            )
                        
                        let supabaseToken = session.accessToken
                        tokenStore.set(token: supabaseToken)

                        isAuthenticated = true

                    } catch {
                        print("Sign-in failed:", error)
                    }
                }
            }
        }
    }
}

extension AuthenticationView {
    fileprivate var rootViewController: UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap { $0 as? UIWindowScene }
            .compactMap { $0.keyWindow }
            .first?.rootViewController
    }
}

#Preview {
    StatefulPreviewWrapper(false) { isAuthenticated in
        AuthenticationView(isAuthenticated: isAuthenticated)
    }
}
