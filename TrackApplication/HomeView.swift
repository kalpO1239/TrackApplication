import SwiftUI
import FirebaseAuth

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Welcome to the Home Screen!")
                .font(.largeTitle)
                .padding()

            Button(action: logOut) {
                Text("Log Out")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Home")
    }

    func logOut() {
        FirebaseAuthManager.shared.logOut()
    }
}




#Preview {
   TabbedView()
}
