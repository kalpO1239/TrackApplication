import SwiftUI
import Firebase

struct GraphView: View {
    // Use the shared WorkoutDataManager to get the workout logs
    @EnvironmentObject var workoutDataManager: WorkoutDataManager
    @State private var workoutLogs: [Workout] = []
    
    // Optionally, you can add loading state here for Firebase fetch
    @State private var isLoading: Bool = true
    
    var body: some View {
        VStack {
            if isLoading {
                Text("Loading...")
                    .padding()
            } else {
                List(workoutLogs, id: \.date) { workout in
                    HStack {
                        Text(workout.title)
                        Spacer()
                        Text("\(workout.miles, specifier: "%.2f") miles")
                        Spacer()
                        Text("\(workout.timeInMinutes) min")
                    }
                }
                .navigationTitle("Workout Logs")
            }
        }
        .onAppear {
            // Fetch workout data from Firebase when the view appears
            loadWorkoutLogs()
        }
    }
    
    private func loadWorkoutLogs() {
        // Fetch the workout data from the WorkoutDataManager or directly from Firebase
        workoutDataManager.fetchWorkoutDataFromFirebase { fetchedLogs in
            self.workoutLogs = fetchedLogs
            self.isLoading = false
        }
    }
}
