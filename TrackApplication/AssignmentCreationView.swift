import SwiftUI
import Firebase
import FirebaseAuth

struct AssignmentCreationView: View {
    @State private var title: String = ""
    @State private var fieldsInput: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedStudents: [String] = []
    @State private var students: [String] = []
    @State private var assignmentFields: [String] = []
    
    @State private var inputGroupName: String = ""  // Coach inputs the group name
    @State private var showStudents: Bool = false   // Controls student visibility
    @State private var coachId: String? = nil       // Will store the authenticated coach's ID

    var body: some View {
        Form {
            Section(header: Text("Enter Group Name")) {
                TextField("Group Name", text: $inputGroupName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 10)
                
                Button(action: fetchStudents) {
                    Text("Fetch Students")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red:0.0,green:0.0,blue:0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }

            if showStudents {
                Section(header: Text("Assign To")) {
                    Toggle("Select All", isOn: Binding(
                        get: { selectedStudents.count == students.count },
                        set: { isOn in
                            selectedStudents = isOn ? students : []
                        }
                    ))

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
                    }
                }
            }

            Section(header: Text("Assignment Details")) {
                TextField("Title", text: $title)
                TextField("Fields (comma-separated)", text: $fieldsInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 10)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
            }

            Button(action: createAssignment) {
                Text("Submit Assignment")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Create Assignment")
        .onAppear(perform: fetchCoachId) // Fetch coach's ID on load
    }

    /// Fetch authenticated coach's ID from Firebase Auth
    private func fetchCoachId() {
        if let user = Auth.auth().currentUser {
            self.coachId = user.uid
        } else {
            print("No user logged in")
        }
    }

    @State private var studentMap: [String: String] = [:] // Maps athleteId → Name

    private func fetchStudents() {
        guard let coachId = coachId else {
            print("Coach ID not found")
            return
        }

        let db = Firestore.firestore()
        db.collection("groups")
            .whereField("coachId", isEqualTo: coachId)
            .whereField("name", isEqualTo: inputGroupName)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching group: \(error.localizedDescription)")
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("No matching group found")
                    return
                }

                if let members = document.data()["members"] as? [String: String] {
                    DispatchQueue.main.async {
                        self.studentMap = members  // Store ID → Name mapping
                        self.students = Array(members.keys)  // Store only IDs in `students`
                        self.showStudents = true
                    }
                } else {
                    print("No members found in the group")
                }
            }
    }




    /// Create an assignment
    private func createAssignment() {
        guard !inputGroupName.isEmpty else {
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

        assignmentFields = fieldsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        let db = Firestore.firestore()

        let assignmentData: [String: Any] = [
            "athleteIds": selectedStudents,  // Now contains IDs instead of names
            "groupId": inputGroupName,
            "reps": assignmentFields,
            "responses": [:],
            "coachId": coachId,
            "title": title,
            "dueDate": Timestamp(date: dueDate)
        ]

        db.collection("assignments").addDocument(data: assignmentData) { error in
            if let error = error {
                print("Error adding assignment: \(error.localizedDescription)")
            } else {
                print("Assignment successfully created with athlete IDs!")
            }
        }
    }


}

#Preview {
    AssignmentCreationView()
}
