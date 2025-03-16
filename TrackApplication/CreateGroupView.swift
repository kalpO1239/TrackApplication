//
//  CreateGroupView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 3/16/25.
//


import SwiftUI
import Firebase
import FirebaseAuth

struct CreateGroupView: View {
    @State private var groupName: String = ""
    @State private var joinCode: String = UUID().uuidString.prefix(6).uppercased() // Generate a 6-character code
    @EnvironmentObject var groupManager: GroupManager
    @EnvironmentObject var authManager: AuthManager // Assuming you have an AuthManager to get the coach's ID
    
    @State private var isGroupCreated = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create a New Group")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Enter Group Name", text: $groupName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text("Join Code: \(joinCode)")
                .font(.headline)
                .foregroundColor(.blue)
            
            Button(action: createGroup) {
                Text("Create Group")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(groupName.isEmpty)
            
            if isGroupCreated {
                Text("Group Created Successfully!")
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
    
    func createGroup() {
        guard let coachId = authManager.currentUserId else {
            print("No coach logged in")
            return
        }
        
        groupManager.createGroup(name: groupName, coachId: coachId, code: String(joinCode))
        isGroupCreated = true
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
            .environmentObject(GroupManager())
            .environmentObject(AuthManager())
    }
}
