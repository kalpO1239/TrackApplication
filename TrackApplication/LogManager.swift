import Firebase

class LogManager {
    static let shared = LogManager()

    private init() {}

    // Function to submit a workout log
    func submitLog(assignmentId: String, miles: Double, title: String, timeInMinutes: Int, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        // Create a new log entry
        let logData: [String: Any] = [
            "assignmentId": assignmentId,
            "miles": miles,
            "title": title,
            "timeInMinutes": timeInMinutes,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // Add the log entry to Firestore under the "logs" collection
        db.collection("logs").addDocument(data: logData) { error in
            if let error = error {
                print("Error adding log: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Log added successfully")
                completion(true)
            }
        }
    }
    
    // Fetch logs from Firestore (if needed)
    func fetchLogs(completion: @escaping ([WorkoutLog]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("logs").getDocuments { (querySnapshot, error) in
            var logs: [WorkoutLog] = []
            if let error = error {
                print("Error fetching logs: \(error.localizedDescription)")
                completion([])
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let log = WorkoutLog(
                        date: Date.now, assignmentId: data["assignmentId"] as? String ?? "",
                        miles: data["miles"] as? Double ?? 0.0,
                        title: data["title"] as? String ?? "",
                        timeInMinutes: data["timeInMinutes"] as? Int ?? 0
                    )
                    logs.append(log)
                }
                completion(logs)
            }
        }
    }
}

// Renamed to avoid ambiguity
struct WorkoutLog {
    let date : Date
    let assignmentId: String
    let miles: Double
    let title: String
    let timeInMinutes: Int
}
