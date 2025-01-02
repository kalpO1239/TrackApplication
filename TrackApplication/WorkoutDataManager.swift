//
//  WorkoutDataManager.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 12/28/24.
//


import Foundation

class WorkoutDataManager {
    
    static let shared = WorkoutDataManager()
    
    private init() {}
    
    // Updated workout data structure
    private var workoutData: [Workout] = []
    
    /// Adds a new workout
    func addWorkout(date: Date, miles: Double, title: String, timeInMinutes: Int) {
        let newWorkout = Workout(date: date, miles: miles, title: title, timeInMinutes: timeInMinutes)
        workoutData.append(newWorkout)
        //NotificationCenter.default.post(name: .workoutDataUpdated, object: nil)
    }
    
    /// Retrieves all workout data
    func getWorkoutData() -> [Workout] {
        return workoutData
    }
}

/// Workout data structure
struct Workout {
    let date: Date
    let miles: Double
    let title: String
    let timeInMinutes: Int
}
