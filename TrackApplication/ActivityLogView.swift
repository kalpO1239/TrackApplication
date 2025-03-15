//
//  ActivityLogView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 3/15/25.
//


import SwiftUI

struct ActivityLogView: View {
    @EnvironmentObject var workoutDataManager: WorkoutDataManager

    var body: some View {
        NavigationView {
            List(workoutDataManager.workoutData) { workout in
                VStack(alignment: .leading) {
                    Text(workout.title)
                        .font(.headline)
                    Text("Distance: \(workout.miles, specifier: "%.2f") mi")
                        .font(.subheadline)
                    Text("Date: \(formatDate(workout.date))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("Activity Log")
            .onAppear {
                workoutDataManager.fetchWorkoutsForUser()
            }
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
