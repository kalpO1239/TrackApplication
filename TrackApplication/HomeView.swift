import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutDataManager: WorkoutDataManager // Access the WorkoutDataManager instead
    
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                // Example button for logging workout
                Button(action: {
                    logWorkout()
                }) {
                    Text("Log Workout")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Example button for viewing progress
                Button(action: {
                    showProgress()
                }) {
                    Text("View Progress")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .navigationTitle("Home")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func logWorkout() {
        // You would call the relevant method from WorkoutDataManager to log a workout
        if let workout = workoutDataManager.getWorkoutData().first {
            workoutDataManager.addWorkout(date: workout.date, miles: workout.miles, title: workout.title, timeInMinutes: workout.timeInMinutes)
            alertMessage = "Workout logged!"
            showingAlert = true
        } else {
            alertMessage = "No workout to log."
            showingAlert = true
        }
    }

    func showProgress() {
        // Navigate to the GraphView or show the progress data
        alertMessage = "Showing progress..."
        showingAlert = true
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WorkoutDataManager.shared)  // Use WorkoutDataManager here for the preview
    }
}
