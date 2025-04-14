import SwiftUI
import Firebase
import FirebaseAuth

struct AssignmentCreationView: View {
    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedStudents: [String] = []
    @State private var students: [String] = []
    @State private var assignmentFields: [String] = []
    @State private var editingFieldIndex: Int? = nil
    
    @State private var groups: [String] = []
    @State private var selectedGroup: String = ""
    @State private var coachId: String? = nil
    @State private var studentMap: [String: String] = [:]
    @State private var isLoading = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ModernBackground()
                
                VStack(spacing: 20) {
                    // Groups Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(groups, id: \.self) { group in
                                Button(action: {
                                    selectedGroup = group
                                    fetchStudents()
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
                    
                    if isLoading {
                        loadingView
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Assignment Details
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Assignment Details")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "#433F4E"))
                                    
                                    TextField("Title", text: $title)
                                        .padding()
                                        .background(Color(hex: "#ECE3DF").opacity(0.5))
                                        .cornerRadius(8)
                                    
                                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .padding()
                                        .background(Color(hex: "#ECE3DF").opacity(0.5))
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal)
                                
                                // Rep Fields
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Rep Fields")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color(hex: "#433F4E"))
                                        
                                        Spacer()
                                        
                                        Button(action: addNewField) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Color(hex: "#433F4E"))
                                                .padding(8)
                                                .background(Color(hex: "#ECE3DF").opacity(0.5))
                                                .cornerRadius(8)
                                        }
                                    }
                                    
                                    ForEach(Array(assignmentFields.enumerated()), id: \.offset) { index, field in
                                        HStack {
                                            if editingFieldIndex == index {
                                                TextField("Enter rep", text: $assignmentFields[index])
                                                    .padding()
                                                    .background(Color(hex: "#ECE3DF").opacity(0.5))
                                                    .cornerRadius(8)
                                            } else {
                                                Text(field)
                                                    .font(.system(size: 16, design: .rounded))
                                                    .foregroundColor(Color(hex: "#5B5E73"))
                                                    .padding()
                                                    .background(Color(hex: "#ECE3DF").opacity(0.5))
                                                    .cornerRadius(8)
                                            }
                                            
                                            Button(action: {
                                                withAnimation {
                                                    editingFieldIndex = editingFieldIndex == index ? nil : index
                                                }
                                            }) {
                                                Image(systemName: "pencil")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(Color(hex: "#433F4E"))
                                                    .padding(8)
                                                    .background(Color(hex: "#ECE3DF").opacity(0.5))
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Students Selection
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Assign To")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "#433F4E"))
                                    
                                    Toggle("Select All", isOn: Binding(
                                        get: { selectedStudents.count == students.count },
                                        set: { isOn in
                                            selectedStudents = isOn ? students : []
                                        }
                                    ))
                                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#5B5E73")))
                                    
                                    ForEach(students, id: \.self) { studentId in
                                        Toggle(studentMap[studentId] ?? "Unknown", isOn: Binding(
                                            get: { selectedStudents.contains(studentId) },
                                            set: { isSelected in
                                                if isSelected {
                                                    selectedStudents.append(studentId)
                                                } else {
                                                    selectedStudents.removeAll { $0 == studentId }
                                                }
                                            }
                                        ))
                                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#5B5E73")))
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Submit Button
                                Button(action: createAssignment) {
                                    Text("Create Assignment")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
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
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchCoachId()
            fetchCoachGroups()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .tint(Color(hex: "#5B5E73"))
            
            Text("Loading...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#5B5E73"))
        }
    }
    
    private func addNewField() {
        assignmentFields.append("")
        editingFieldIndex = assignmentFields.count - 1
    }
    
    private func fetchCoachId() {
        if let user = Auth.auth().currentUser {
            self.coachId = user.uid
        }
    }
    
    private func fetchCoachGroups() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ User not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("groups")
            .whereField("coachId", arrayContains: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("❌ Error fetching groups: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No groups found.")
                    return
                }
                
                let groupNames = documents.compactMap { $0.data()["name"] as? String }
                DispatchQueue.main.async {
                    self.groups = groupNames
                    if !groupNames.isEmpty {
                        self.selectedGroup = groupNames[0]
                        self.fetchStudents()
                    }
                }
            }
    }
    
    private func fetchStudents() {
        guard let coachId = coachId, !selectedGroup.isEmpty else { return }
        
        isLoading = true
        let db = Firestore.firestore()
        
        db.collection("groups")
            .whereField("name", isEqualTo: selectedGroup)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching group: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("No matching group found")
                    isLoading = false
                    return
                }
                
                if let members = document.data()["members"] as? [String: String] {
                    DispatchQueue.main.async {
                        self.studentMap = members
                        self.students = Array(members.keys)
                        self.isLoading = false
                    }
                } else {
                    print("No members found in the group")
                    isLoading = false
                }
            }
    }
    
    private func createAssignment() {
        guard !selectedGroup.isEmpty else {
            print("Group name is required")
            return
        }
        
        guard !selectedStudents.isEmpty else {
            print("No students selected")
            return
        }
        
        guard let coachId = coachId else {
            print("Coach ID not found")
            return
        }
        
        let db = Firestore.firestore()
        
        // First, fetch the group to get all coach IDs
        db.collection("groups")
            .whereField("name", isEqualTo: selectedGroup)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching group: \(error.localizedDescription)")
                    return
                }
                
                guard let document = snapshot?.documents.first,
                      let groupCoachIds = document.data()["coachId"] as? [String] else {
                    print("No matching group found or coachId field is not an array")
                    return
                }
                
                // Create the assignment with all coach IDs from the group
                let assignmentData: [String: Any] = [
                    "athleteIds": selectedStudents,
                    "groupId": selectedGroup,
                    "reps": assignmentFields,
                    "responses": [:],
                    "coachId": groupCoachIds, // Use all coach IDs from the group
                    "title": title,
                    "dueDate": Timestamp(date: dueDate)
                ]
                
                db.collection("assignments").addDocument(data: assignmentData) { error in
                    if let error = error {
                        print("Error adding assignment: \(error.localizedDescription)")
                    } else {
                        print("Assignment successfully created!")
                        // Reset form
                        title = ""
                        assignmentFields = []
                        selectedStudents = []
                    }
                }
            }
    }
}

#Preview {
    AssignmentCreationView()
}
