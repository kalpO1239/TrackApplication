import SwiftUI

struct StudentCatalogView: View {
    @State private var students: [String] = ["Student 1", "Student 2", "Student 3"] // You can replace this with actual Firestore data

    var body: some View {
        List(students, id: \.self) { student in
            Text(student) // Display student names
        }
        .navigationTitle("Student Catalog")
    }
}
