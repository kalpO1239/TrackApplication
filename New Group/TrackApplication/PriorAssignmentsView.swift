//
//  PriorAssignmentsView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 1/1/25.
//


import SwiftUI

struct PriorAssignmentsView: View {
    @State private var assignments: [String] = ["Assignment 1", "Assignment 2", "Assignment 3"] // Mock data for assignments

    var body: some View {
        List(assignments, id: \.self) { assignment in
            NavigationLink(destination: AssignmentDetailView(assignmentName: assignment)) {
                Text(assignment)
            }
        }
        .navigationTitle("Prior Assignments")
    }
}
