//
//  JoinGroupView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 3/16/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct JoinGroupView: View {
    @State private var joinCode: String = ""
    @State private var userName: String = ""
    @State private var errorMessage: String?
    @EnvironmentObject var groupManager: GroupManager
    
    var body: some View {
        VStack {
            Text("Join a Group")
                .font(.title)
                .padding()
            
            TextField("Enter Your Name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter Group Code", text: $joinCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: {
                joinGroup()
            }) {
                Text("Join Group")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func joinGroup() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in."
            return
        }
        
        guard !userName.isEmpty else {
            errorMessage = "Please enter your name."
            return
        }
        
        let db = Firestore.firestore()
        db.collection("groups").whereField("code", isEqualTo: joinCode).getDocuments { snapshot, error in
            if let error = error {
                errorMessage = "Error finding group: \(error.localizedDescription)"
                return
            }
            
            guard let document = snapshot?.documents.first else {
                errorMessage = "Invalid group code."
                return
            }
            
            let groupId = document.documentID
            let groupRef = db.collection("groups").document(groupId)
            
            // Create the member object
            let newMember = [
                "userId": userId,
                "userName": userName
            ]
            
            // Update group with the new member and add the userId to athleteIds array
            groupRef.updateData([
                "members": FieldValue.arrayUnion([newMember]), // Add member object to array
                "athleteIds": FieldValue.arrayUnion([userId]) // Add userId to athleteIds array
            ]) { error in
                if let error = error {
                    errorMessage = "Error joining group: \(error.localizedDescription)"
                } else {
                    errorMessage = nil // Successfully joined the group
                }
            }
        }
    }

}

struct JoinGroupView_Previews: PreviewProvider {
    static var previews: some View {
        JoinGroupView().environmentObject(GroupManager())
    }
}
