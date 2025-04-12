import SwiftUI
import Charts

// MARK: - Main View
struct HomeView: View {
    @EnvironmentObject var workoutDataManager: WorkoutDataManager
    @State private var selectedWeek: Int? = nil
    @State private var selectedMileage: Double = 0.0
    @State private var weeks: [Date] = []
    @State private var weekMileage: [Double] = Array(repeating: 0.0, count: 10)
    @State private var showPopup = false
    @State private var popupData: (date: Date, mileage: Double)? = nil

    var body: some View {
        NavigationView {
            ZStack {
                ModernBackground()
                mainContent
            }
            .navigationTitle("Home")
            .onAppear {
                workoutDataManager.fetchWorkoutsForUser()
                initializeWeeks()
            }
            .onChange(of: workoutDataManager.workoutData) { _ in
                updateWeekMileage()
            }
            .overlay {
                if showPopup, let data = popupData {
                    PopupView(date: data.date, mileage: data.mileage, isPresented: $showPopup)
                }
            }
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 25) {
                WeeklyProgressView(
                    weeks: weeks,
                    weekMileage: weekMileage,
                    selectedWeek: $selectedWeek,
                    selectedMileage: $selectedMileage,
                    showPopup: $showPopup,
                    popupData: $popupData
                )
                
                buttonStack
            }
            .padding(.top, 20)
        }
    }
    
    private var buttonStack: some View {
        VStack(spacing: 20) {
            ActivityLogButton()
            LogWorkoutButton()
            JoinGroupViewButton()
            SplitButton()
        }
        .padding(.horizontal, 20)
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
            mileageDict[workoutWeek, default: 0.0] += workout.miles
        }

        // Update the weekMileage array to reflect the total miles per week
        for (i, week) in weeks.enumerated() {
            weekMileage[i] = mileageDict[week] ?? 0.0 // Set to 0 if no data for the week
        }
    }
}

// MARK: - Weekly Progress View
struct WeeklyProgressView: View {
    let weeks: [Date]
    let weekMileage: [Double]
    @Binding var selectedWeek: Int?
    @Binding var selectedMileage: Double
    @Binding var showPopup: Bool
    @Binding var popupData: (date: Date, mileage: Double)?
    
    var data: [(date: Date, mileage: Double)] {
        zip(weeks, weekMileage).map { ($0, $1) }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            titleView
            chartView
        }
    }
    
    private var titleView: some View {
        Text("Weekly Progress")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(Color(hex: "#433F4E"))
            .padding(.leading)
    }
    
    private var chartView: some View {
        Chart(data, id: \.date) { entry in
            let clampedMileage = max(Double(entry.mileage), 0)
            
            lineMark(entry: entry, mileage: clampedMileage)
            areaMark(entry: entry, mileage: clampedMileage)
            pointMark(entry: entry, mileage: clampedMileage)
        }
        .chartXAxis { xAxis }
        .chartYAxis { yAxis }
        .frame(height: 300)
        .padding()
        .background(chartBackground)
        .overlay(chartOverlay)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        let x = location.x
                        let y = location.y
                        
                        // Find the closest point
                        if let closestPoint = data.min(by: { point1, point2 in
                            let point1X = proxy.position(forX: point1.date) ?? 0
                            let point2X = proxy.position(forX: point2.date) ?? 0
                            return abs(point1X - x) < abs(point2X - x)
                        }) {
                            popupData = (closestPoint.date, closestPoint.mileage)
                            showPopup = true
                        }
                    }
            }
        }
    }
    
    private func lineMark(entry: (date: Date, mileage: Double), mileage: Double) -> some ChartContent {
        LineMark(
            x: .value("Week Start", entry.date),
            y: .value("Miles", mileage)
        )
        .interpolationMethod(.catmullRom)
        .foregroundStyle(lineGradient)
        .lineStyle(StrokeStyle(lineWidth: 3))
    }
    
    private func areaMark(entry: (date: Date, mileage: Double), mileage: Double) -> some ChartContent {
        AreaMark(
            x: .value("Week Start", entry.date),
            y: .value("Miles", mileage)
        )
        .interpolationMethod(.catmullRom)
        .foregroundStyle(areaGradient)
    }
    
    private func pointMark(entry: (date: Date, mileage: Double), mileage: Double) -> some ChartContent {
        PointMark(
            x: .value("Week Start", entry.date),
            y: .value("Miles", mileage)
        )
        .foregroundStyle(Color(hex: "#5B5E73"))
        .symbolSize(50)
        .annotation(position: .top) {
            Text(String(format: "%.2f", entry.mileage))
                .font(.caption)
                .foregroundColor(Color(hex: "#5B5E73"))
        }
    }
    
    private var lineGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#5B5E73"),
                Color(hex: "#433F4E")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#5B5E73").opacity(0.2),
                Color(hex: "#433F4E").opacity(0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var xAxis: some AxisContent {
        AxisMarks(values: .stride(by: .day, count: 7)) { value in
            AxisGridLine()
            AxisValueLabel {
                if let date = value.as(Date.self) {
                    let calendar = Calendar.current
                    if calendar.component(.weekday, from: date) == 2 { // 2 is Monday
                        Text(formatDate(date))
                            .foregroundColor(Color(hex: "#5B5E73"))
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    private var yAxis: some AxisContent {
        AxisMarks(values: .stride(by: 5.0)) { value in
            AxisGridLine()
            AxisValueLabel {
                if let miles = value.as(Double.self) {
                    Text(String(format: "%.2f", miles))
                        .foregroundColor(Color(hex: "#5B5E73"))
                }
            }
        }
    }
    
    private var chartBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: "#ECE3DF").opacity(0.5))
    }
    
    private var chartOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color(hex: "#BBBFCF").opacity(0.3), lineWidth: 1)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - Popup View
struct PopupView: View {
    let date: Date
    let mileage: Double
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Week Details")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#433F4E"))
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "#5B5E73"))
                        .font(.system(size: 20))
                }
            }
            
            Divider()
                .background(Color(hex: "#BBBFCF"))
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#5B5E73"))
                    Text("Mileage")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#5B5E73"))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(formatDate(date))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "#433F4E"))
                    Text(String(format: "%.2f miles", mileage))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "#433F4E"))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#ECE3DF"))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#BBBFCF").opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(), value: isPresented)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Button Views
struct ActivityLogButton: View {
    var body: some View {
        NavigationLink(destination: ActivityLogView()) {
            Text("Activity Log")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonGradient)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#5B5E73"),
                Color(hex: "#433F4E")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct SplitButton: View {
    var body: some View {
        NavigationLink(destination: SplitRecorder()) {
            Text("Splits")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonGradient)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#899ABE"),
                Color(hex: "#5B5E73")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct JoinGroupViewButton: View {
    var body: some View {
        NavigationLink(destination: JoinGroupView()) {
            Text("Join Group")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonGradient)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#5B5E73"),
                Color(hex: "#433F4E")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct LogWorkoutButton: View {
    var body: some View {
        NavigationLink(destination: LogView()) {
            Text("Log Workout")
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonGradient)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#899ABE"),
                Color(hex: "#5B5E73")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(WorkoutDataManager.shared)
}
