//
//  LogDataModel.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 12/28/24.
//


import Foundation

// Log data model
class LogDataModel: ObservableObject {
    @Published var logs: [(date: Date, miles: Double)] = []
    
    func addLog(date: Date, miles: Double) {
        logs.append((date: date, miles: miles))
    }
}
