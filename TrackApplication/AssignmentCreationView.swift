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
                        .background(Color.blue)
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

                    ForEach(students, id: \.self) { student in
                        Toggle(student, isOn: Binding(
                            get: { selectedStudents.contains(student) },
                            set: { isSelected in
                                if isSelected {
                                    selectedStudents.append(student)
                                } else {
                                    selectedStudents.removeAll { $0 == student }
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
                    .background(Color.green)
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

    /// Fetch students from Firebase based on coach ID and group name
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

                // Fetch the members map from the group document
                if let members = document.data()["members"] as? [String: String] {
                    // Initialize an empty array to store student names
                    var studentNames: [String] = []

                    // Loop through the members map and fetch the names (values) using athleteId (keys)
                    for (_, studentName) in members {
                        studentNames.append(studentName)
                    }

                    // Update the students list with the names and show students
                    DispatchQueue.main.async {
                        self.students = studentNames
                        self.showStudents = true  // Display students after fetching
                    }
                } else {
                    print("No members found in the group")
                }
            }
    }



    /// Create an assignment
    private func createAssignment() {
        assignmentFields = fieldsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        print("Assignment Created:", title, assignmentFields, dueDate, selectedStudents)
    }
}

#Preview {
    AssignmentCreationView()
}
