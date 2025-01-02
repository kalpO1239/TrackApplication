import Foundation

// Log data structure
struct Log: Identifiable {
    let id = UUID() // Unique identifier for each log
    let date: Date
    let title: String
    let miles: Double
    let timeInMinutes: Int
}

// Log data model
class LogDataModel: ObservableObject {
    @Published var logs: [Log] = []
    
    /// Adds a new log entry
    func addLog(date: Date, miles: Double, title: String, timeInMinutes: Int) {
        let newLog = Log(date: date, title: title, miles: miles, timeInMinutes: timeInMinutes)
        logs.append(newLog)
    }
}
