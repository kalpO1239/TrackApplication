import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct CoachLogin: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isUserLoggedIn = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.badge.key.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.5))
                    .padding(.bottom, 20)

                Text("Coach Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.5))
                    .padding(.bottom, 20)

                TextField("Email", text: $email)
                    .padding()
                    .border(Color.gray, width: 1)
                    .background(Color.white)
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .padding()
                    .border(Color.gray, width: 1)
                    .background(Color.white)
                    .cornerRadius(8)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 20)
                }

                Button(action: signInWithEmail) {
                    Text("Sign In")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.0, green: 0.0, blue: 0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: createAccount) {
                    Text("Create Account")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.0, green: 0.0, blue: 0.5))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                GoogleSignInButton {
                    signInWithGoogle()
                }
                .background(Color.gray)
                .cornerRadius(8)

                NavigationLink(destination: TabbedView(), isActive: $isUserLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
            .background(Color("DarkNavyBlue"))
            .ignoresSafeArea()
        }
    }

    func signInWithEmail() {
        FirebaseAuthManager.shared.signIn(email: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Sign-in failed: \(error.localizedDescription)"
            } else {
                isUserLoggedIn = true
            }
        }
    }

    func createAccount() {
        FirebaseAuthManager.shared.createAccount(email: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Account creation failed: \(error.localizedDescription)"
            } else {
                isUserLoggedIn = true
            }
        }
    }

    func signInWithGoogle() {
        FirebaseAuthManager.shared.signInWithGoogle { success, error in
            if success {
                isUserLoggedIn = true
            } else if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview{
    CoachLogin()
}
