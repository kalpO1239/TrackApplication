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
                
                Spacer()

                LogWorkoutButton()
            }
            .navigationTitle("Home")
            .onAppear {
                initializeWeeks()
                workoutDataManager.fetchWorkoutDataFromFirebase()
                updateWeekMileage()
            }
            .onChange(of: workoutDataManager.workoutData) { _ in
                updateWeekMileage()
            }
        }
    }
    
    // ✅ Function to initialize weekly data
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
            let weekStart = getMondayOfWeek(offset: -i)
            dates.append(weekStart)
        }
        self.weeks = dates
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }

    // ✅ Updates the weekly mileage based on logged workouts
    func updateWeekMileage() {
        var mileageDict: [Date: Double] = [:]

        for workout in workoutDataManager.workoutData {
            let workoutWeek = getMondayOfWeek(offset: Calendar.current.component(.weekOfYear, from: workout.date) - Calendar.current.component(.weekOfYear, from: Date()))
            mileageDict[workoutWeek, default: 0] += workout.miles
        }

        for (i, week) in weeks.enumerated() {
            weekMileage[i] = Int(mileageDict[week] ?? 0)
        }
    }
}

// ✅ Weekly Progress Graph View (Embedded in HomeView.swift)
struct WeeklyProgressView: View {
    let weeks: [Date]
    let weekMileage: [Int]
    @Binding var selectedWeek: Int?
    @Binding var selectedMileage: Int

    var body: some View {
        VStack {
            Text("Weekly Progress")
                .font(.headline)
            Spacer()

            ZStack {
                GeometryReader { geometry in
                    Path { path in
                        let graphWidth = geometry.size.width
                        let graphHeight = geometry.size.height
                        let pointSpacing = graphWidth / CGFloat(weeks.count - 1)
                        
                        if weeks.isEmpty { return }
                        
                        let startX = pointSpacing * 0
                        let startY = graphHeight - CGFloat(weekMileage[0])
                        path.move(to: CGPoint(x: startX, y: startY))
                        
                        for i in 1..<weeks.count {
                            let x = pointSpacing * CGFloat(i)
                            let y = graphHeight - CGFloat(weekMileage[i])
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)

                    ForEach(0..<weeks.count, id: \.self) { i in
                        let x = (geometry.size.width / CGFloat(weeks.count - 1)) * CGFloat(i)
                        let y = geometry.size.height - CGFloat(weekMileage[i])

                        Circle()
                            .frame(width: 10, height: 10)
                            .position(x: x, y: y)
                            .foregroundColor(selectedWeek == i ? .blue : .blue.opacity(0.7))
                            .onTapGesture {
                                selectedWeek = i
                                selectedMileage = weekMileage[i]
                            }
                    }
                }
            }
            .frame(height: 200)
            .border(Color.gray, width: 1)
            .padding(.horizontal)
            
            if selectedWeek != nil {
                Text("Mileage: \(selectedMileage) mi")
                    .font(.title2)
                    .padding()
            }
        }
    }
}

// ✅ Activity Log Button (Embedded in HomeView.swift)
struct ActivityLogButton: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "list.bullet")
                Text("Activity Log")
            }
            .font(.title2)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

// ✅ Log Workout Button (Embedded in HomeView.swift)
struct LogWorkoutButton: View {
    var body: some View {
        NavigationLink(destination: LogView()) {
            Text("Log Workout")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
        .environmentObject(WorkoutDataManager.shared)
}
