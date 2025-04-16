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
        NavigationView {
            ZStack {
                ModernBackground()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Back Button
                        HStack {
                            Button(action: navigateBack) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                    Text("Back")
                                }
                                .foregroundColor(Color(hex: "#5B5E73"))
                                .padding()
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // App Logo
                        VStack(spacing: 15) {
                            Image("Runlytics")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .padding(.bottom, 20)
                            
                            Text("Create Account")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#433F4E"))
                            
                            Text("Join us today")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#5B5E73"))
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                        
                        // Input fields
                        VStack(spacing: 20) {
                            CustomTextField(iconName: "person", placeholder: "First Name", isSecure: false, text: $firstName)
                            CustomTextField(iconName: "person", placeholder: "Last Name", isSecure: false, text: $lastName)
                            CustomTextField(iconName: "envelope", placeholder: "Email", isSecure: false, text: $email)
                            CustomTextField(iconName: "lock", placeholder: "Password", isSecure: true, text: $password)
                        }
                        .padding(.horizontal)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        // Create Account Button
                        Button(action: createAccount) {
                            Text("Create Account")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#5B5E73"),
                                            Color(hex: "#433F4E")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        NavigationLink(destination: HomeView()
                            .environmentObject(WorkoutDataManager.shared)
                            .navigationBarBackButtonHidden(true),
                                     isActive: $isUserLoggedIn) {
                            EmptyView()
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func navigateBack() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: RoleSelectionView())
            window.makeKeyAndVisible()
        }
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

#Preview {
    CreateAccountView()
}
