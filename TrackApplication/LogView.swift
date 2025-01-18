import SwiftUI

struct LogView: View {
    @EnvironmentObject var workoutDataManager: WorkoutDataManager
    @State private var title: String = ""
    @State private var miles: String = ""
    @State private var hours: String = ""
    @State private var minutes: String = ""
    @State private var date: Date = Date()

    var body: some View {
        VStack(spacing: 20) {
            Text("Log Your Workout")
                .font(.title)
                .bold()

            TextField("Enter Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Enter Miles", text: $miles)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                TextField("Hours", text: $hours)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Minutes", text: $minutes)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()

            Button(action: handleSubmit) {
                Text("Submit Log")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private func handleSubmit() {
        guard let miles = Double(miles), let minutes = Int(minutes), let hours = Int(hours) else { return }

        let totalTime = hours * 60 + minutes // Calculate total minutes

        // Save workout data to WorkoutDataManager
        workoutDataManager.addWorkout(date: date, miles: miles, title: title, timeInMinutes: totalTime)
    }
}

struct TabbedView: View {
    // Create an instance of WorkoutDataManager
    @StateObject private var workoutDataManager = WorkoutDataManager.shared
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .environmentObject(workoutDataManager)  // Inject the WorkoutDataManager into the environment
            
            LogView()  // Assuming this is now a SwiftUI view
                .tabItem {
                    Image(systemName: "pencil.circle.fill")
                    Text("Log Run")
                }
                .environmentObject(workoutDataManager)  // Inject the WorkoutDataManager into the environment
            
            GraphView()  // Assuming this view displays the data graph
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
                .environmentObject(workoutDataManager)  // Inject the WorkoutDataManager into the environment
        }
    }
}

struct TabbedView_Previews: PreviewProvider {
    static var previews: some View {
        TabbedView()
            .environmentObject(WorkoutDataManager.shared) // Ensure that the shared WorkoutDataManager is passed in previews
    }
}
