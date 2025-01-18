import Firebase
import FirebaseFirestore

class WorkoutDataManager: ObservableObject { // Conform to ObservableObject
    static let shared = WorkoutDataManager()
    private init() {}
    
    @Published var workoutData: [Workout] = [] // Use @Published to automatically update views
    
    func addWorkout(date: Date, miles: Double, title: String, timeInMinutes: Int) {
        let newWorkout = Workout(date: date, miles: miles, title: title, timeInMinutes: timeInMinutes)
        workoutData.append(newWorkout)
        // Add to Firebase here
        addWorkoutToFirebase(workout: newWorkout)
    }
    
    func getWorkoutData() -> [Workout] {
        return workoutData
    }
    
    func fetchWorkoutDataFromFirebase(completion: @escaping ([Workout]) -> Void) {
        let db = Firestore.firestore()
        db.collection("workouts").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            }
            
            var fetchedWorkouts: [Workout] = []
            for document in snapshot!.documents {
                let data = document.data()
                if let title = data["title"] as? String,
                   let miles = data["miles"] as? Double,
                   let timeInMinutes = data["timeInMinutes"] as? Int,
                   let timestamp = data["date"] as? Timestamp {
                    let workout = Workout(date: timestamp.dateValue(), miles: miles, title: title, timeInMinutes: timeInMinutes)
                    fetchedWorkouts.append(workout)
                }
            }
            completion(fetchedWorkouts)
        }
    }
    
    private func addWorkoutToFirebase(workout: Workout) {
        let db = Firestore.firestore()
        db.collection("workouts").addDocument(data: [
            "title": workout.title,
            "miles": workout.miles,
            "timeInMinutes": workout.timeInMinutes,
            "date": Timestamp(date: workout.date)
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            }
        }
    }
}

// Workout data structure
struct Workout {
    let date: Date
    let miles: Double
    let title: String
    let timeInMinutes: Int
}
