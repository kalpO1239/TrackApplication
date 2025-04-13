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
    func addWorkout(date: Date, miles: Double, title: String, timeInMinutes: Int, description: String = "") {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }

        let workoutData: [String: Any] = [
            "date": Timestamp(date: date),
            "miles": miles,
            "title": title,
            "timeInMinutes": timeInMinutes,
            "userId": userId,
            "description": description
        ]

        db.collection("workouts").addDocument(data: workoutData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Workout successfully added!")
            }
        }
    }




    func updateWeekMileage() {
        let calendar = Calendar.current
        var weeklyMileage = [Int](repeating: 0, count: 7)
        
        for workout in workoutData {
            let weekOfYear = calendar.component(.weekOfYear, from: workout.date)
            weeklyMileage[weekOfYear % 7] += Int(workout.miles)
        }
        
        DispatchQueue.main.async {
            self.weekMileage = weeklyMileage
        }
    }


    func fetchWorkoutsForUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }

        db.collection("workouts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching workouts: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No workout data found")
                    return
                }

                DispatchQueue.main.async {
                    self.workoutData = documents.compactMap { doc in
                        try? doc.data(as: WorkoutEntry.self)  // ✅ Firestore auto-fills `id`
                    }
                }
            }
    }


    
    func fetchWorkoutDataFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }

        self.db.collection("workouts")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }

                let fetchedWorkouts: [WorkoutEntry] = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: WorkoutEntry.self)  // ✅ Firestore auto-fills `id`
                } ?? []

                DispatchQueue.main.async {
                    self.workoutData = fetchedWorkouts
                    self.updateWeekMileage()
                }
            }
    }

}

struct WorkoutEntry: Identifiable, Codable, Equatable {
    @DocumentID var id: String?  // Firestore document ID (optional)
    var date: Date
    var miles: Double
    var title: String
    var timeInMinutes: Int
    var userId: String  // Include userId so Firestore can store it
    var description: String  // New field for workout description

    static func == (lhs: WorkoutEntry, rhs: WorkoutEntry) -> Bool {
        return lhs.id == rhs.id
    }
}
