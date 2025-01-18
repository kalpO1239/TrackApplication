//
//  UserManager.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 1/18/25.
//


import FirebaseAuth
import FirebaseFirestore

class UserManager {
    
    static let shared = UserManager()
    
    private init() {}
    
    // Register or login user and set role
    func registerUser(email: String, password: String, role: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error registering user: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let user = result?.user else {
                completion(false)
                return
            }
            
            // Save user role and other info to Firestore
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "email": email,
                "role": role
            ]) { error in
                if let error = error {
                    print("Error saving user role: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
