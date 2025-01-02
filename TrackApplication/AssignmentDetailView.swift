//
//  AssignmentDetailView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 1/1/25.
//


import SwiftUI

struct AssignmentDetailView: View {
    let assignmentName: String

    var body: some View {
        VStack {
            Text(assignmentName)
                .font(.title)
                .padding()

            Text("Athlete Responses")
                .font(.headline)

            // Mock data for responses
            List {
                Text("Student 1: 7:30 Split")
                Text("Student 2: 6:45 Split")
                Text("Student 3: 8:15 Split")
            }
        }
        .navigationTitle(assignmentName)
    }
}
