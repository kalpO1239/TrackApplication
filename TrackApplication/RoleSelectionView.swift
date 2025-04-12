import SwiftUI

struct GradientButtonStyle: ButtonStyle {
    let startColor: Color
    let endColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [startColor, endColor]),
                             startPoint: .leading,
                             endPoint: .trailing)
            )
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ModernBackground: View {
    var body: some View {
        ZStack {
            // Base color
            Color(hex: "#ECE3DF")
                .ignoresSafeArea()
            
            // Grid pattern
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let spacing: CGFloat = 30 // Increased spacing for more noticeable grid
                    
                    // Horizontal lines
                    for y in stride(from: 0, through: height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    
                    // Vertical lines
                    for x in stride(from: 0, through: width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))
                    }
                }
                .stroke(Color(hex: "#BBBFCF").opacity(0.4), lineWidth: 1) // Increased opacity and line width
            }
            
            // Gradient overlay
            LinearGradient(
                colors: [
                    Color(hex: "#ECE3DF").opacity(0.8),
                    Color(hex: "#BBBFCF").opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct RoleSelectionView: View {
    @State private var showAlert = false
    @State private var selectedRole: String?
    
    var body: some View {
        ZStack {
            ModernBackground()
            
            VStack(spacing: 30) {
                // App Logo and Title
                VStack(spacing: 10) {
                    Image("Runlytics")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    Text("Split/Decision")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#5B5E73"))
                }
                .padding(.bottom, 40)
                
                // Role Selection Buttons
                VStack(spacing: 20) {
                    // Coach Button
                    Button(action: {
                        selectedRole = "Coach"
                        showAlert = true
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                            Text("Coach")
                                .foregroundColor(.white)
                                .font(.title2)
                                .bold()
                        }
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
                    
                    // Student Button
                    Button(action: {
                        selectedRole = "Student"
                        showAlert = true
                    }) {
                        HStack {
                            Image(systemName: "graduationcap.fill")
                                .foregroundColor(.white)
                            Text("Student")
                                .foregroundColor(.white)
                                .font(.title2)
                                .bold()
                        }
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
                .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirm Role Selection"),
                message: Text("You selected \(selectedRole ?? ""). Is this correct?"),
                primaryButton: .default(Text("Yes")) {
                    if selectedRole == "Coach" {
                        navigateToCoachLogin()
                    } else {
                        navigateToStudentView()
                    }
                },
                secondaryButton: .cancel(Text("No"))
            )
        }
    }
    
    // Navigation to CoachLogin
    func navigateToCoachLogin() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: CoachLogin())
            window.makeKeyAndVisible()
        }
    }
    
    // Navigation to ContentView
    func navigateToStudentView() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UIHostingController(rootView: ContentView())
            window.makeKeyAndVisible()
        }
    }
}

#Preview {
    RoleSelectionView()
}
