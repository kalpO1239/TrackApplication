import SwiftUI

struct AssignmentCreationView: View {
    @State private var title: String = ""
    @State private var fieldsInput: String = "" // Field for comma-separated values
    @State private var dueDate: Date = Date()
    @State private var selectedStudents: [String] = [] // Mock data for selected students
    
    // Array to store the fields from the input
    @State private var assignmentFields: [String] = []

    var body: some View {
        Form {
            Section(header: Text("Assignment Details")) {
                TextField("Title", text: $title)
                
                // New field to enter comma-separated values
                TextField("Fields (comma-separated)", text: $fieldsInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 10)
                
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
            }

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

            Button(action: createAssignment) {
                Text("Submit Assignment")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Create Assignment")
    }

    private func createAssignment() {
        // Splitting the input string into an array based on commas and trimming whitespace
        assignmentFields = fieldsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        // Logic for creating an assignment goes here
        print("Assignment Created:", title, assignmentFields, dueDate, selectedStudents)
    }

    private let students: [String] = ["Student 1", "Student 2", "Student 3"] // Mock data for students
}

#Preview{
    AssignmentCreationView()
}
