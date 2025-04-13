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
            ZStack {
                ModernBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(workoutDataManager.workoutData) { workout in
                            workoutCard(workout: workout)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            
            .onAppear {
                workoutDataManager.fetchWorkoutsForUser()
            }
        }
    }
    
    private func workoutCard(workout: WorkoutEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(workout.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#433F4E"))
                Spacer()
                Text(formatDate(workout.date))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#5B5E73"))
            }
            
            Divider()
                .background(Color(hex: "#BBBFCF").opacity(0.3))
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Distance")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#5B5E73"))
                    Text("Time")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#5B5E73"))
                    if !workout.description.isEmpty {
                        Text("Description")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#5B5E73"))
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(workout.miles, specifier: "%.2f") miles")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "#433F4E"))
                    Text(formatTime(workout.timeInMinutes))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "#433F4E"))
                    if !workout.description.isEmpty {
                        Text(workout.description)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(hex: "#433F4E"))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#ECE3DF").opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#BBBFCF").opacity(0.3), lineWidth: 1)
        )
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return String(format: "%d:%02d", hours, remainingMinutes)
        } else {
            return "\(remainingMinutes) minutes"
        }
    }
}
