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
                
                LogWorkoutButton()
                
                Spacer()
            }
            .navigationTitle("Home")
            .onAppear {
              
                initializeWeeks()
                workoutDataManager.updateWeekMileage() // Update the mileage when the view appears
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

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack {
            Text("Weekly Progress")
                .font(.title)
                .foregroundColor(.white)
                .padding(.bottom, 10)

            GeometryReader { geometry in
                let graphWidth = geometry.size.width - 50  // Leave space for the Y-axis labels
                let graphHeight = geometry.size.height - 20 // Leave space for X-axis labels
                let maxMileage = weekMileage.max() ?? 1
                let scaleFactor = maxMileage > 0 ? graphHeight / CGFloat(maxMileage) : 1
                let pointSpacing = weeks.count > 1 ? graphWidth / CGFloat(weeks.count - 1) : 0
                
                ZStack {
                    // Draw Y-Axis
                    Path { path in
                        path.move(to: CGPoint(x: 40, y: 0))
                        path.addLine(to: CGPoint(x: 40, y: graphHeight))
                    }
                    .stroke(Color.black, lineWidth: 1)

                    // Y-Axis Labels
                    ForEach(0...5, id: \.self) { i in
                        let mileage = maxMileage * i / 5
                        let y = graphHeight - CGFloat(mileage) * scaleFactor
                        
                        Text("\(mileage)")
                            .font(.caption)
                            .foregroundColor(.black)
                            .position(x: 20, y: y)
                    }

                    // Draw Graph Line
                    Path { path in
                        if weeks.isEmpty { return }

                        let startX = pointSpacing * CGFloat(weeks.count - 1) + 40
                        let startY = graphHeight - CGFloat(weekMileage[0]) * scaleFactor
                        path.move(to: CGPoint(x: startX, y: startY))

                        for i in 1..<weeks.count {
                            let x = pointSpacing * CGFloat(weeks.count - 1 - i) + 40
                            let y = graphHeight - CGFloat(weekMileage[i]) * scaleFactor
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)

                    // Data Points
                    ForEach(0..<weeks.count, id: \.self) { i in
                        let x = pointSpacing * CGFloat(weeks.count - 1 - i) + 40
                        let y = graphHeight - CGFloat(weekMileage[i]) * scaleFactor

                        Circle()
                            .frame(width: 12, height: 12)
                            .position(x: x, y: y)
                            .foregroundColor(selectedWeek == i ? .blue : .blue.opacity(0.6))
                            .onTapGesture {
                                selectedWeek = i
                                selectedMileage = weekMileage[i]
                            }
                    }

                    // X-Axis Labels
                    ForEach(0..<weeks.count, id: \.self) { i in
                        let x = pointSpacing * CGFloat(weeks.count - 1 - i) + 40
                        Text(formatDate(weeks[i]))
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                            .position(x: x, y: graphHeight + 10)
                    }
                }
            }
            .frame(height: 250)
            .border(Color.gray.opacity(0.3), width: 1)
            .padding(.horizontal, 15)
            .padding(.vertical, 25)

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
