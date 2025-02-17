//
//  WorkoutEntry.swift
//  TrackApplication
//
//  Created by Veejhay Roy on 2/17/25.
//

import Foundation

struct WorkoutEntry: Identifiable {
    let id = UUID()
    let date: Date
    let miles: Double
    let title: String
    let timeInMinutes: Int
}
