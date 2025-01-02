//
//  AssignmentCreationView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 1/1/25.
//


import SwiftUI

struct AssignmentCreationView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedStudents: [String] = [] // Mock data for selected students

    var body: some View {
        Form {
            Section(header: Text("Assignment Details")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
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
        // Logic for creating an assignment goes here
        print("Assignment Created:", title, description, dueDate, selectedStudents)
    }

    private let students: [String] = ["Student 1", "Student 2", "Student 3"] // Mock data for students
}