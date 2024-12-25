import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isUserLoggedIn = false // State to track if the user is logged in

    var body: some View {
        NavigationView {
            VStack {
                // Running icon at the top
                Image(systemName: "figure.run")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)

                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                TextField("Email", text: $email)
                    .padding()
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .border(Color.gray, width: 1)
                    .cornerRadius(8)
                    .padding(.bottom, 20)

                SecureField("Password", text: $password)
                    .padding()
                    .border(Color.gray, width: 1)
                    .cornerRadius(8)
                    .padding(.bottom, 20)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 20)
                }

                // Sign In with Email button
                Button(action: signInWithEmail) {
                    Text("Sign In")
                        .padding()
                        .frame(maxWidth: .infinity) // Make it the same width as the create account button
                        .background(Color.blue) // Change to navy blue
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom, 20)

                // Create Account button
                Button(action: createAccount) {
                    Text("Create Account")
                        .padding()
                        .frame(maxWidth: .infinity) // Ensure same width as the sign-in button
                        .background(Color.blue) // Change to navy blue
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom, 20)

                // Google Sign-In button
                GoogleSignInButton {
                    signInWithGoogle()
                }
                .padding(.bottom, 20)

                // Navigation Link: Will be triggered when user is logged in
                NavigationLink(destination: HomeView(), isActive: $isUserLoggedIn) {
                    EmptyView() // Invisible view for programmatic navigation
                }
            }
            .padding()
        }
    }

    // Function to handle sign-in with email/password
    func signInWithEmail() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }

        // Sign in with Firebase
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Sign-in failed: \(error.localizedDescription)"
            } else {
                errorMessage = nil
                print("User signed in: \(result?.user.email ?? "Unknown")")
                isUserLoggedIn = true // Update state to trigger navigation
            }
        }
    }

    // Function to handle account creation
    func createAccount() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }

        // Create account with Firebase
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Account creation failed: \(error.localizedDescription)"
            } else {
                errorMessage = nil
                print("User account created: \(result?.user.email ?? "Unknown")")
                isUserLoggedIn = true // Update state to trigger navigation
            }
        }
    }

    // Function to handle Google Sign-In
    func signInWithGoogle() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to access root view controller."
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Google sign-in error: \(error.localizedDescription)")
                errorMessage = "Google sign-in failed: \(error.localizedDescription)"
                return
            }

            guard let result = result else {
                errorMessage = "Google sign-in failed: No result found."
                return
            }

            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Google sign-in failed: Missing ID token."
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)

            // Authenticate with Firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Google sign-in error: \(error.localizedDescription)")
                    errorMessage = "Firebase sign-in failed: \(error.localizedDescription)"
                } else {
                    errorMessage = nil
                    print("User signed in with Google: \(authResult?.user.email ?? "Unknown")")
                    isUserLoggedIn = true
                }
            }
        }
    }
}

// Google Sign-In Button
struct GoogleSignInButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "g.circle") // Replace with Google's logo (if you have it)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("Sign in with Google")
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(maxWidth: .infinity, minHeight: 44) // Standard button size
            .background(Color(UIColor.systemGray5))
            .foregroundColor(.black)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
    }
}

#Preview {
    ContentView()
}
