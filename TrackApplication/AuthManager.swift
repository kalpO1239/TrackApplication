import FirebaseAuth
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()  // Access the shared instance
    
    // Make the initializer accessible within the same file
    public init() {
        // Initialize the currentUserId based on the existing user (if any)
        self.currentUserId = Auth.auth().currentUser?.uid
        
        // Observe authentication state changes
        Auth.auth().addStateDidChangeListener { _, user in
            // Update currentUserId when the authentication state changes
            self.currentUserId = user?.uid
        }
    }

    @Published var currentUserId: String?
    
    func getCurrentUserId() -> String? {
        return currentUserId
    }
}
