import Firebase
import FirebaseFirestore

class WorkoutDataManager: ObservableObject {
    static let shared = WorkoutDataManager()
    private init() {}

    @Published var workoutData: [WorkoutEntry] = [] // ✅ Ensures SwiftUI updates when changed

    func addWorkout(date: Date, miles: Double, title: String, timeInMinutes: Int) {
        let newWorkout = WorkoutEntry(date: date, miles: miles, title: title, timeInMinutes: timeInMinutes)
        
        DispatchQueue.main.async {
            self.workoutData.append(newWorkout) // ✅ Ensures UI updates immediately
        }
        
        //addWorkoutToFirebase(workout: newWorkout)
    }

    func fetchWorkoutDataFromFirebase() {
        let db = Firestore.firestore()
        db.collection("workouts").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }

            var fetchedWorkouts: [WorkoutEntry] = []
            for document in snapshot!.documents {
                let data = document.data()
                if let title = data["title"] as? String,
                   let miles = data["miles"] as? Double,
                   let timeInMinutes = data["timeInMinutes"] as? Int,
                   let timestamp = data["date"] as? Timestamp {
                    let workout = WorkoutEntry(date: timestamp.dateValue(), miles: miles, title: title, timeInMinutes: timeInMinutes)
                    fetchedWorkouts.append(workout)
                }
            }

            DispatchQueue.main.async {
                self.workoutData = fetchedWorkouts // ✅ Updates UI when data is fetched
            }
        }
    }
}


// ✅ FIX: Renamed 'Workout' to 'WorkoutEntry' to ensure consistency with LogView.swift
struct WorkoutEntry: Identifiable, Equatable { // ✅ Added Equatable
    let id = UUID()
    let date: Date
    let miles: Double
    let title: String
    let timeInMinutes: Int

    // ✅ Implement Equatable conformance
    static func == (lhs: WorkoutEntry, rhs: WorkoutEntry) -> Bool {
        return lhs.id == rhs.id &&
               lhs.date == rhs.date &&
               lhs.miles == rhs.miles &&
               lhs.title == rhs.title &&
               lhs.timeInMinutes == rhs.timeInMinutes
    }
}
