import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct CustomTextField: View {
    let iconName: String
    let placeholder: String
    let isSecure: Bool
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .foregroundColor(Color(hex: "#5B5E73"))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(Color(hex: "#5B5E73"))
                    .accentColor(Color(hex: "#5B5E73"))
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
                    }
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(placeholder == "Email" ? .emailAddress : .default)
                    .autocapitalization(.none)
                    .foregroundColor(Color(hex: "#5B5E73"))
                    .accentColor(Color(hex: "#5B5E73"))
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
                    }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#BBBFCF").opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#899ABE").opacity(0.3), lineWidth: 1)
        )
    }
}

// Helper extension for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct ModernGoogleSignInButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image("googlelogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text("Sign in with Google")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#433F4E"))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#BBBFCF").opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#899ABE").opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct ContentView: View {
    @StateObject var workoutDataManager = WorkoutDataManager.shared
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
                            
                            Text("Welcome Back!")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#433F4E"))
                            
                            Text("Sign in to continue")
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
                        
                        NavigationLink(destination: HomeView()
                            .environmentObject(WorkoutDataManager.shared)
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
    ContentView()
}
