//
//  StudentCatalogView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 1/1/25.
//


//  StudentCatalogView.swift
//  TrackApplication

import SwiftUI

struct StudentCatalogView: View {
    @State private var students: [String] = ["Student 1", "Student 2", "Student 3"] // Mock data for students

    var body: some View {
        List(students, id: \.self) { student in
            Text(student)
        }
        .navigationTitle("Student Catalog")
    }
}