import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct ContentView: View {
    @StateObject var workoutDataManager = WorkoutDataManager.shared 
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isUserLoggedIn = false
    @State private var isNavigatingToCreateAccount = false // Navigation to the CreateAccountView

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "figure.run")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.blue.opacity(0.6))
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

                Button(action: signInWithEmail) {
                    Text("Sign In")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom, 20)

                NavigationLink(destination: CreateAccountView(), isActive: $isNavigatingToCreateAccount) {
                    Button(action: {
                        isNavigatingToCreateAccount = true
                    }) {
                        Text("Create Account")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 20)

                GoogleSignInButton {
                    signInWithGoogle()
                }
                .padding(.bottom, 20)

                NavigationLink(destination: HomeView().environmentObject(workoutDataManager), isActive: $isUserLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
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
    ContentView()
}
