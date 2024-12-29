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
    
    private var workoutData: [(miles: Double, time: Double)] = []
    
    func addWorkout(miles: Double, time: Double) {
        workoutData.append((miles, time))
        //NotificationCenter.default.post(name: .workoutDataUpdated, object: nil)
    }
    
    func getWorkoutData() -> [(miles: Double, time: Double)] {
        return workoutData
    }
}
