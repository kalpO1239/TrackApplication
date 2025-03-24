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
            let groupData = document.data()
            
            guard let groupName = groupData["name"] as? String else {
                errorMessage = "Group name not found."
                return
            }

            let groupRef = db.collection("groups").document(groupId)

            // Add user to the group
            groupRef.updateData([
                "members.\(userId)": userName, // Store userId as key and name as value
                "athleteIds": FieldValue.arrayUnion([userId]) // Store userId in athleteIds array
            ]) { error in
                if let error = error {
                    errorMessage = "Error joining group: \(error.localizedDescription)"
                    return
                }

                let orgRef = db.collection("orgs").document(userId)

                // Check if the orgs document exists
                orgRef.getDocument { (doc, error) in
                    if let error = error {
                        errorMessage = "Error checking orgs: \(error.localizedDescription)"
                        return
                    }

                    if doc?.exists == true {
                        // If orgs document exists, update the groups array
                        orgRef.updateData([
                            "groups": FieldValue.arrayUnion([groupName])
                        ]) { error in
                            if let error = error {
                                errorMessage = "Error updating orgs: \(error.localizedDescription)"
                            } else {
                                errorMessage = nil // Successfully updated existing orgs
                            }
                        }
                    } else {
                        // If orgs document doesn't exist, create a new one with the group name as the first element
                        orgRef.setData([
                            "groups": [groupName]
                        ]) { error in
                            if let error = error {
                                errorMessage = "Error creating orgs: \(error.localizedDescription)"
                            } else {
                                errorMessage = nil // Successfully created new orgs document
                            }
                        }
                    }
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
