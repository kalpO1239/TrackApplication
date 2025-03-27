import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var workoutDataManager: WorkoutDataManager
    @State private var selectedWeek: Int? = nil
    @State private var selectedMileage: Int = 0
    @State private var weeks: [Date] = []
    @State private var weekMileage: [Int] = Array(repeating: 0, count: 10)

    var body: some View {
        NavigationView {
            VStack {
                WeeklyProgressView(weeks: weeks, weekMileage: weekMileage, selectedWeek: $selectedWeek, selectedMileage: $selectedMileage)
                
                ActivityLogButton()
                
                LogWorkoutButton()
                
                JoinGroupViewButton()
                
                SplitButton()
                
                Spacer()
            }
            .navigationTitle("Home")
            .onAppear {
                workoutDataManager.fetchWorkoutsForUser()
                initializeWeeks()
                //workoutDataManager.updateWeekMileage() // Update the mileage when the view appears
            }
            .onChange(of: workoutDataManager.workoutData) { _ in
                updateWeekMileage() // Updatex when the workout data changes
            }
        }
    }
    
    func getMondayOfWeek(offset: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: today)!
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: weekStart)!.start
        return startOfWeek
    }

    func initializeWeeks() {
        var dates: [Date] = []
        for i in 0..<10 {
            let weekStart = getMondayOfWeek(offset: -i) // Initialize weeks from oldest to latest
            dates.append(weekStart)
        }
        self.weeks = dates
    }

    func updateWeekMileage() {
        var mileageDict: [Date: Double] = [:]

        // Aggregate miles per week based on the workoutData
        for workout in workoutDataManager.workoutData {
            let workoutWeek = getMondayOfWeek(offset: Calendar.current.component(.weekOfYear, from: workout.date) - Calendar.current.component(.weekOfYear, from: Date()))
            mileageDict[workoutWeek, default: 0] += workout.miles
        }

        // Update the weekMileage array to reflect the total miles per week
        for (i, week) in weeks.enumerated() {
            weekMileage[i] = Int(mileageDict[week] ?? 0) // Set to 0 if no data for the week
        }
    }
}


struct WeeklyProgressView: View {
    let weeks: [Date]
    let weekMileage: [Int]
    @Binding var selectedWeek: Int?
    @Binding var selectedMileage: Int

    // Create a data model for chart
    var data: [(date: Date, mileage: Int)] {
        zip(weeks, weekMileage).map { ($0, $1) }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Weekly Progress")
                .font(.headline)
                .padding(.leading)

            // Create the chart
            Chart(data, id: \.date) { entry in
                // Calculate the y-value, ensuring it's never below 0
                let clampedMileage = max(Double(entry.mileage), 0)

                // Line Mark
                LineMark(
                    x: .value("Week Start", entry.date),
                    y: .value("Miles", clampedMileage)
                )
                .interpolationMethod(.catmullRom) // Ensure smooth lines without dips below 0
                .foregroundStyle(Gradient(colors: [.blue.opacity(0.6), Color(red: 0.0, green: 0.0, blue: 0.5)]))
                .lineStyle(StrokeStyle(lineWidth: 3))

                // Area Mark (gradient under the line)
                AreaMark(
                    x: .value("Week Start", entry.date),
                    y: .value("Miles", clampedMileage)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.2), Color(red: 0.0, green: 0.0, blue: 0.5).opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))

                // Point Mark
                PointMark(
                    x: .value("Week Start", entry.date),
                    y: .value("Miles", clampedMileage)
                )
                .foregroundStyle(.blue)
                .symbolSize(50)
            }
            .frame(height: 250)
            .padding()
        }
    }
}


struct ActivityLogButton: View {
    var body: some View {
        NavigationLink(destination: ActivityLogView()) {
            Text("Activity Log")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 20)
    }
}

struct SplitButton: View {
    var body: some View {
        NavigationLink(destination: SplitRecorder()) {
            Text("Splits")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 20)
    }
}

struct JoinGroupViewButton: View {
    var body: some View {
        NavigationLink(destination: JoinGroupView()) {
            Text("Join Group")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 20)
    }
}

struct LogWorkoutButton: View {
    var body: some View {
        NavigationLink(destination: LogView()) {
            Text("Log Workout")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red:0.0,green:0.0,blue:0.5))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeView()
        .environmentObject(WorkoutDataManager.shared)
}
