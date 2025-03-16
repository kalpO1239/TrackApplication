//
//  DeepLinkHandler.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 3/16/25.
//


import FirebaseDynamicLinks
import FirebaseFirestore
import FirebaseAuth

class DeepLinkHandler {
    static let shared = DeepLinkHandler()
    
    func handleDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        if let groupId = components.queryItems?.first(where: { $0.name == "groupId" })?.value {
            joinGroup(groupId: groupId) { success in
                if success {
                    print("Successfully joined group!")
                } else {
                    print("Failed to join group")
                }
            }
        }
    }
    
    private func joinGroup(groupId: String, completion: @escaping (Bool) -> Void) {
        guard let athleteId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let groupRef = db.collection("groups").document(groupId)

        groupRef.updateData([
            "athletes": FieldValue.arrayUnion([athleteId])
        ]) { error in
            if let error = error {
                print("Error joining group: \(error)")
                completion(false)
            } else {
                print("Athlete successfully joined group!")
                completion(true)
            }
        }
    }
}
