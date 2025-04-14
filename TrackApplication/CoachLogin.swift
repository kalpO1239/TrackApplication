import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct CoachLogin: View {
    @StateObject var authManager = AuthManager.shared
    @StateObject var groupManager = GroupManager()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isUserLoggedIn = false
    @State private var isNavigatingToCreateAccount = false
    
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
                            
                            Text("Coach Login")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#433F4E"))
                            
                            Text("Sign in to manage your teams")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#5B5E73"))
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                        
                        // Input fields
                        VStack(spacing: 20) {
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
                        
                        // Sign In Button
                        Button(action: signInWithEmail) {
                            Text("Sign In")
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
                        
                        // Create Account Button
                        NavigationLink(destination: CreateAccountView(), isActive: $isNavigatingToCreateAccount) {
                            Button(action: { isNavigatingToCreateAccount = true }) {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#899ABE"),
                                                Color(hex: "#5B5E73")
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Divider
                        HStack {
                            VStack { Divider().background(Color(hex: "#BBBFCF").opacity(0.3)) }
                            Text("OR")
                                .font(.footnote)
                                .foregroundColor(Color(hex: "#5B5E73"))
                            VStack { Divider().background(Color(hex: "#BBBFCF").opacity(0.3)) }
                        }
                        .padding(.horizontal)
                        
                        // Google Sign In
                        ModernGoogleSignInButton(action: signInWithGoogle)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: GroupDetailView(groupName: "base")
                            .environmentObject(authManager)
                            .environmentObject(groupManager)
                            .navigationBarBackButtonHidden(true),
                                     isActive: $isUserLoggedIn) {
                            EmptyView()
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    func navigateBack() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: RoleSelectionView())
            window.makeKeyAndVisible()
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

#Preview {
    CoachLogin()
}
