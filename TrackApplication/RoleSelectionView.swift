import SwiftUI

struct RoleSelectionView: View {
    var body: some View {
        VStack(spacing: 20) { // Stack buttons with padding between them
            // Coach Button
            Button(action: {
                navigateToCoachLogin()
            }) {
                HStack {
                    Image(systemName: "person.fill") // Add a relevant logo
                        .foregroundColor(.white)
                    Text("Coach")
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.0, green: 0.0, blue: 0.5)) // Dark navy blue
                .cornerRadius(10)
            }

            // Student Button
            Button(action: {
                navigateToStudentView()
            }) {
                HStack {
                    Image(systemName: "graduationcap.fill") // Add a relevant logo
                        .foregroundColor(.white)
                    Text("Student")
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.6)) // Light blue
                .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center the buttons
        .background(Color.white)
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
            window.rootViewController = UIHostingController(rootView: ContentView()) // Update for Student's main view
            window.makeKeyAndVisible()
        }
    }
}

struct RoleSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RoleSelectionView()
    }
}
