import SwiftUI

struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""

    // This binding will be passed from sanchoApp to update the authentication state
    @Binding var isAuthenticated: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Sancho!")
                .font(.largeTitle)
                .padding(.bottom, 40)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Login") {
                // Action for login (placeholder)
                print("Login button tapped")
            }
            .padding()
            .buttonStyle(.borderedProminent)

            Button("Sign Up") {
                // Action for sign up (placeholder)
                print("Sign Up button tapped")
            }
            .buttonStyle(.bordered)

            // Temporary button to simulate successful login
            Button("Simulate Login") {
                isAuthenticated = true
            }
            .padding(.top, 30)
            .foregroundColor(.gray)
        }
        .padding()
    }
}

// For previewing, we need to provide a constant binding
#Preview {
    AuthenticationView(isAuthenticated: .constant(false))
}
