//
//  CreateAccountView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 12/31/24.
//


import SwiftUI

struct CreateAccountView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isUserLoggedIn = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .padding(.bottom, 20)

            Text("Create Your Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            TextField("First Name", text: $firstName)
                .padding()
                .border(Color.gray, width: 1)
                .cornerRadius(8)

            TextField("Last Name", text: $lastName)
                .padding()
                .border(Color.gray, width: 1)
                .cornerRadius(8)

            TextField("Email", text: $email)
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .border(Color.gray, width: 1)
                .cornerRadius(8)

            SecureField("Password", text: $password)
                .padding()
                .border(Color.gray, width: 1)
                .cornerRadius(8)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
            }

            Button(action: createAccount) {
                Text("Create Account")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 20)

            NavigationLink(destination: HomeView(), isActive: $isUserLoggedIn) {
                EmptyView()
            }
        }
        .padding()
    }

    func createAccount() {
        guard !firstName.isEmpty, !lastName.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        FirebaseAuthManager.shared.createAccount(email: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Account creation failed: \(error.localizedDescription)"
            } else {
                isUserLoggedIn = true
            }
        }
    }
}

#Preview{
    CreateAccountView()
}
