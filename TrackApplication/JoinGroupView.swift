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
    @State private var isSuccess = false
    @EnvironmentObject var groupManager: GroupManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ModernBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Back Button
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
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
                        
                        Text("Join a Group")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#5B5E73"))
                            .padding(.top, 20)
                        
                        // Name Input
                        VStack(alignment: .leading) {
                            Text("Your Name")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#5B5E73"))
                            
                            TextField("Enter your name", text: $userName)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(hex: "#ECE3DF").opacity(0.5))
                                .cornerRadius(8)
                                .foregroundColor(Color(hex: "#5B5E73"))
                                .accentColor(Color(hex: "#5B5E73"))
                                .placeholder(when: userName.isEmpty) {
                                    Text("Enter your name")
                                        .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
                                }
                        }
                        .padding(.horizontal)
                        
                        // Group Code Input
                        VStack(alignment: .leading) {
                            Text("Group Code")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#5B5E73"))
                            
                            TextField("Enter group code", text: $joinCode)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(hex: "#ECE3DF").opacity(0.5))
                                .cornerRadius(8)
                                .foregroundColor(Color(hex: "#5B5E73"))
                                .accentColor(Color(hex: "#5B5E73"))
                                .placeholder(when: joinCode.isEmpty) {
                                    Text("Enter group code")
                                        .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
                                }
                        }
                        .padding(.horizontal)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        Button(action: joinGroup) {
                            Text("Join Group")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
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
                                .foregroundColor(Color(hex: "#ECE3DF"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    .frame(minHeight: geometry.size.height)
                }
            }
            .navigationBarHidden(true)
        }
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
                "members.\(userId)": userName,
                "athleteIds": FieldValue.arrayUnion([userId])
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
                                isSuccess = true
                                presentationMode.wrappedValue.dismiss()
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
                                isSuccess = true
                                presentationMode.wrappedValue.dismiss()
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
