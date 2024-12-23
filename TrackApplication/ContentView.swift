//
//  ContentView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 12/22/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isUserLoggedIn = false // State to track if the user is logged in

    var body: some View {
        NavigationView {
            VStack {
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
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom, 20)

                Button(action: createAccount) {
                    Text("Create Account")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
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
}




#Preview {
    ContentView()
}
