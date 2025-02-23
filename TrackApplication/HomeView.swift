import SwiftUI

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
                
                Spacer()

                LogWorkoutButton()
            }
            .navigationTitle("Home")
            .onAppear {
                initializeWeeks()
                updateWeekMileage() // Update the mileage when the view appears
            }
            .onChange(of: workoutDataManager.workoutData) { _ in
                updateWeekMileage() // Update when the workout data changes
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

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
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

    var body: some View {
        VStack {
            Text("Weekly Progress")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 10)

            ZStack {
                GeometryReader { geometry in
                    Path { path in
                        let graphWidth = geometry.size.width
                        let graphHeight = geometry.size.height
                        let pointSpacing = graphWidth / CGFloat(weeks.count - 1)

                        if weeks.isEmpty { return }

                        let maxMileage = weekMileage.max() ?? 1
                        let scaleFactor = graphHeight / CGFloat(maxMileage)

                        let startX = pointSpacing * CGFloat(weeks.count - 1)  // Start at the farthest right
                        let startY = graphHeight - CGFloat(weekMileage[0]) * scaleFactor
                        path.move(to: CGPoint(x: startX, y: startY))

                        for i in 1..<weeks.count {
                            let x = pointSpacing * CGFloat(weeks.count - 1 - i) // Reverse the x-axis order
                            let y = graphHeight - CGFloat(weekMileage[i]) * scaleFactor
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)

                    ForEach(0..<weeks.count, id: \.self) { i in
                        let x = (geometry.size.width / CGFloat(weeks.count - 1)) * CGFloat(weeks.count - 1 - i)  // Reverse the x-axis order
                        let y = geometry.size.height - CGFloat(weekMileage[i]) * (geometry.size.height / CGFloat(weekMileage.max() ?? 0))

                        Circle()
                            .frame(width: 12, height: 12)
                            .position(x: x, y: y)
                            .foregroundColor(selectedWeek == i ? .blue : .blue.opacity(0.7))
                            .onTapGesture {
                                selectedWeek = i
                                selectedMileage = weekMileage[i]
                            }
                    }
                }
            }
            .frame(height: 250)
            .border(Color.gray.opacity(0.3), width: 1)
            .padding(.horizontal, 15)

            if let selectedWeek = selectedWeek {
                Text("Mileage: \(weekMileage[selectedWeek]) mi")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding(.top, 10)
            }
        }
    }
}


struct ActivityLogButton: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "list.bullet")
                Text("Activity Log")
                    .font(.title2)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
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
                .background(Color.green)
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
