import Firebase
import FirebaseAuth
import FirebaseFirestore

class WorkoutDataManager: ObservableObject {
    static let shared = WorkoutDataManager()
   

    private let db: Firestore
    @Published var workoutData: [WorkoutEntry] = [] // List of all workouts
    @Published var weekMileage: [Int] = []  // Holds the mileage per week for graph
    
    init(db: Firestore = Firestore.firestore()) {
          self.db = db
      }
    // Updates the workout data and weekly mileage
    func addWorkout(date: Date, miles: Double, title: String, timeInMinutes: Int) {
        let newWorkout = WorkoutEntry(date: date, miles: miles, title: title, timeInMinutes: timeInMinutes)
        
        // Create a Firestore reference
        let db = Firestore.firestore()
        
        // Create a dictionary from the newWorkout object
        let workoutData: [String: Any] = [
            "date": newWorkout.date,
            "miles": newWorkout.miles,
            "title": newWorkout.title,
            "timeInMinutes": newWorkout.timeInMinutes,
            "userId": Auth.auth().currentUser?.uid ?? ""
        ]
        
        
        // Send the data to Firestore (e.g., to a collection named "workouts")
        db.collection("workouts").addDocument(data: workoutData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document successfully added!")
            }
        }
        
        // Update the local workoutData and update the weekly mileage
        DispatchQueue.main.async {
            self.workoutData.append(newWorkout)
            self.updateWeekMileage()
        }
    }


    func updateWeekMileage() {
        let calendar = Calendar.current
        
        var weeklyMileage = [Int](repeating: 0, count: 7)
        
        // Group workouts by week
        for workout in workoutData {
            let weekOfYear = calendar.component(.weekOfYear, from: workout.date)
            weeklyMileage[weekOfYear % 7] += Int(workout.miles)
        }
        
        self.weekMileage = weeklyMileage
    }

    func fetchWorkoutDataFromFirebase() {
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.uid ?? "" // Get the current user's ID

        db.collection("workouts")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
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
                self.workoutData = fetchedWorkouts
                self.updateWeekMileage()
            }
        }
    }
}

struct WorkoutEntry: Identifiable, Equatable {

    let id = UUID()
    let date: Date
    let miles: Double
    let title: String
    let timeInMinutes: Int
}
