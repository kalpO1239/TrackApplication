//import Foundation
//
//// Log data structure
//struct Log: Identifiable {
//    let id = UUID() // Unique identifier for each log
//    let date: Date
//    let title: String
//    let miles: Double
//    let timeInMinutes: Int
//}
//
//// Log data model
//class LogDataModel: ObservableObject {
//    @Published var logs: [WorkoutLog] = []
//    
//    /// Adds a new log entry
//    func addLog(date: Date, miles: Double, title: String, timeInMinutes: Int) {
//        let newLog = WorkoutLog(date: date, assignmentId: id, miles: miles, title: title, timeInMinutes: timeInMinutes)
//        logs.append(newLog)
//    }
//}
