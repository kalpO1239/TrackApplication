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
    @State private var joinCode: String = ""
    @State private var errorMessage: String = ""
    @State private var groups: [String] = []
    @State private var selectedGroup: String = ""
    @State private var members: [String: String] = [:] // userId: userName
    @State private var isLoading = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ModernBackground()
                
                VStack(spacing: 20) {
                    // Groups Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            // Create Group Tab
                            Button(action: {
                                selectedGroup = "+"
                                groupName = ""
                                errorMessage = ""
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        selectedGroup == "+" ?
                                        AnyView(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "#5B5E73"),
                                                    Color(hex: "#433F4E")
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        ) : AnyView(Color(hex: "#ECE3DF").opacity(0.5))
                                    )
                                    .foregroundColor(selectedGroup == "+" ? .white : Color(hex: "#433F4E"))
                                    .cornerRadius(12)
                            }
                            
                            // Join Group Tab
                            Button(action: {
                                selectedGroup = "join"
                                joinCode = ""
                                errorMessage = ""
                            }) {
                                Text("Join Group")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        selectedGroup == "join" ?
                                        AnyView(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "#5B5E73"),
                                                    Color(hex: "#433F4E")
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        ) : AnyView(Color(hex: "#ECE3DF").opacity(0.5))
                                    )
                                    .foregroundColor(selectedGroup == "join" ? .white : Color(hex: "#433F4E"))
                                    .cornerRadius(12)
                            }
                            
                            // Coach's Groups Tabs
                            ForEach(groups, id: \.self) { group in
                                Button(action: {
                                    selectedGroup = group
                                    fetchMembers(for: group)
                                }) {
                                    Text(group)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(
                                            selectedGroup == group ?
                                            AnyView(
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: "#5B5E73"),
                                                        Color(hex: "#433F4E")
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            ) : AnyView(Color(hex: "#ECE3DF").opacity(0.5))
                                        )
                                        .foregroundColor(selectedGroup == group ? .white : Color(hex: "#433F4E"))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Content Area
                    if selectedGroup == "+" {
                        createGroupContent
                    } else if selectedGroup == "join" {
                        joinGroupContent
                    } else if !selectedGroup.isEmpty {
                        groupMembersContent
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .onAppear {
                fetchCoachGroups()
            }
        }
    }
    
    private var createGroupContent: some View {
        VStack(spacing: 15) {
            TextField("Group Name", text: $groupName)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(hex: "#ECE3DF").opacity(0.5))
                .cornerRadius(8)
                .padding(.horizontal)
            
            HStack {
                Text("Join Code: \(joinCode)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#5B5E73"))
                
                Spacer()
                
                Button(action: {
                    joinCode = UUID().uuidString.prefix(6).uppercased()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#5B5E73"))
                        .padding(8)
                        .background(Color(hex: "#ECE3DF").opacity(0.5))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Button(action: createGroup) {
                Text("Create Group")
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
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(groupName.isEmpty)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
    }
    
    private var joinGroupContent: some View {
        VStack(spacing: 15) {
            TextField("Join Code", text: $joinCode)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(hex: "#ECE3DF").opacity(0.5))
                .cornerRadius(8)
                .padding(.horizontal)
            
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
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
    }
    
    private var groupMembersContent: some View {
        VStack(spacing: 15) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            } else if members.isEmpty {
                Text("No members in this group")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#5B5E73"))
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Array(members.keys), id: \.self) { userId in
                            HStack {
                                Text(members[userId] ?? "Unknown")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#433F4E"))
                                Spacer()
                            }
                            .padding()
                            .background(Color(hex: "#ECE3DF").opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func fetchCoachGroups() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("groups")
            .whereField("coachId", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching groups: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                
                let groupNames = snapshot?.documents.compactMap { $0.data()["name"] as? String } ?? []
                DispatchQueue.main.async {
                    self.groups = groupNames
                    self.isLoading = false
                    if !groupNames.isEmpty {
                        self.selectedGroup = groupNames[0]
                        self.fetchMembers(for: groupNames[0])
                    } else {
                        self.selectedGroup = "+"
                    }
                }
            }
    }
    
    private func fetchMembers(for groupName: String) {
        guard !groupName.isEmpty else { return }
        isLoading = true
        
        let db = Firestore.firestore()
        db.collection("groups")
            .whereField("name", isEqualTo: groupName)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching group: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                
                guard let groupDoc = snapshot?.documents.first,
                      let athleteIds = groupDoc.data()["athleteIds"] as? [String],
                      let membersData = groupDoc.data()["members"] as? [String: String] else {
                    isLoading = false
                    return
                }
                
                // Filter members to only show those in athleteIds
                let filteredMembers = membersData.filter { athleteIds.contains($0.key) }
                
                DispatchQueue.main.async {
                    self.members = filteredMembers
                    self.isLoading = false
                }
            }
    }
    
    func createGroup() {
        guard let coachId = Auth.auth().currentUser?.uid else {
            errorMessage = "No coach logged in"
            return
        }
        
        if groupName.isEmpty {
            errorMessage = "Please enter a group name"
            return
        }
        
        let db = Firestore.firestore()
        
        // First check if the code already exists
        db.collection("groups")
            .whereField("code", isEqualTo: joinCode)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = "Error checking code: \(error.localizedDescription)"
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    // Code already exists, generate a new one
                    self.joinCode = UUID().uuidString.prefix(6).uppercased()
                    self.errorMessage = "Code already exists. A new code has been generated."
                    return
                }
                
                // Code is unique, create the group
                let groupData: [String: Any] = [
                    "name": groupName,
                    "code": joinCode,
                    "coachId": [coachId],
                    "athleteIds": [],
                    "members": [:]
                ]
                
                db.collection("groups").addDocument(data: groupData) { error in
                    if let error = error {
                        self.errorMessage = "Error creating group: \(error.localizedDescription)"
                    } else {
                        // Clear the form and generate a new code
                        self.groupName = ""
                        self.joinCode = UUID().uuidString.prefix(6).uppercased()
                        self.errorMessage = ""
                        
                        // Refresh the groups list
                        self.fetchCoachGroups()
                    }
                }
            }
    }
    
    func joinGroup() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "No user logged in"
            return
        }
        
        if joinCode.isEmpty {
            errorMessage = "Please enter a join code"
            return
        }
        
        let db = Firestore.firestore()
        
        // Find the group with the matching code
        db.collection("groups")
            .whereField("code", isEqualTo: joinCode)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = "Error finding group: \(error.localizedDescription)"
                    return
                }
                
                guard let groupDoc = snapshot?.documents.first else {
                    self.errorMessage = "No group found with that code"
                    return
                }
                
                let groupId = groupDoc.documentID
                var coachIds = groupDoc.data()["coachId"] as? [String] ?? []
                
                // Check if user is already a coach
                if coachIds.contains(userId) {
                    self.errorMessage = "You are already a coach in this group"
                    return
                }
                
                // Add user to coachIds array
                coachIds.append(userId)
                
                // Update the group document
                db.collection("groups").document(groupId).updateData([
                    "coachId": coachIds
                ]) { error in
                    if let error = error {
                        self.errorMessage = "Error joining group: \(error.localizedDescription)"
                    } else {
                        self.errorMessage = ""
                        self.joinCode = ""
                        // Refresh the groups list
                        self.fetchCoachGroups()
                    }
                }
            }
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}
