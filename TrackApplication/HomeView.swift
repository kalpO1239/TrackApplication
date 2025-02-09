import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutDataManager: WorkoutDataManager
    @State private var selectedWeek: Int? = nil
    @State private var selectedMileage: Int = 0  // Default mileage is 0
    @State private var weeks: [Date] = []  // Store the dates for the last 10 weeks
    @State private var weekMileage: [Int] = Array(repeating: 0, count: 10)  // Placeholder mileage values

    // Helper function to get the Monday of a week
    func getMondayOfWeek(offset: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: today)!
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: weekStart)!.start
        return startOfWeek
    }

    // Initialize the weeks (last 10 Mondays)
    func initializeWeeks() {
        var dates: [Date] = []
        for i in 0..<10 {
            let weekStart = getMondayOfWeek(offset: -i)
            dates.append(weekStart)
        }
        self.weeks = dates
    }

    // Format date to MM/dd
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationView {
            VStack {
                // Graph Section with Border
                VStack {
                    Text("Weekly Progress")
                        .font(.headline)
                    Spacer()
                    
                    ZStack {
                        // Graph Container with a border to look like a graph
                        VStack {
                            Spacer()
                            ZStack {
                                // Graph line and points
                                GeometryReader { geometry in
                                    Path { path in
                                        let graphWidth = geometry.size.width
                                        let graphHeight = geometry.size.height
                                        let pointSpacing = graphWidth / CGFloat(self.weeks.count - 1)
                                        
                                        // Ensure we have at least one week in the array
                                        if self.weeks.isEmpty { return }
                                        
                                        // Move to the first point
                                        let startX = pointSpacing * 0
                                        let startY = graphHeight - CGFloat(self.weekMileage[0]) // Inverse mileage (higher value at the top)
                                        path.move(to: CGPoint(x: startX, y: startY))
                                        
                                        // Draw the line between points
                                        for i in 1..<self.weeks.count {
                                            let x = pointSpacing * CGFloat(i)
                                            let y = graphHeight - CGFloat(self.weekMileage[i]) // Inverse mileage
                                            path.addLine(to: CGPoint(x: x, y: y))
                                        }
                                    }
                                    .stroke(Color.blue, lineWidth: 2)
                                    
                                    // Add circles for the points
                                    ForEach(0..<self.weeks.count, id: \.self) { i in
                                        let x = (geometry.size.width / CGFloat(self.weeks.count - 1)) * CGFloat(i)
                                        let y = geometry.size.height - CGFloat(self.weekMileage[i])
                                        
                                        Circle()
                                            .frame(width: 10, height: 10)
                                            .position(x: x, y: y)
                                            .foregroundColor(self.selectedWeek == i ? .blue : .blue.opacity(0.7))
                                            .onTapGesture {
                                                self.selectedWeek = i
                                                self.selectedMileage = self.weekMileage[i]
                                            }
                                    }
                                }
                            }
                            .frame(height: 200)
                            .border(Color.gray, width: 1)
                            .padding(.horizontal)
                            Spacer()
                        }
                    }
                    
                    // Display the selected week's mileage
                    if selectedWeek != nil {
                        Text("Mileage: \(selectedMileage) mi")
                            .font(.title2)
                            .padding()
                    }
                    
                    // Week Date Labels
                    HStack {
                        ForEach(0..<self.weeks.count, id: \.self) { i in
                            VStack {
                                Text(formatDate(self.weeks[i]))
                                    .font(.caption)
                                    .foregroundColor(self.selectedWeek == i ? .blue : .gray)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, 5)
                    .padding(.horizontal)
                }
                .padding()

                // Activity Log Button
                Button(action: {
                    // Navigate to ActivityLog.swift (to be implemented)
                }) {
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

                // Events Section
                DisclosureGroup("Events") {
                    Text("No upcoming assignments")
                        .foregroundColor(.gray)
                        .padding()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)

                Spacer()

                // Log Workout Button
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
            .navigationTitle("Home")
            .onAppear {
                initializeWeeks()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WorkoutDataManager.shared)
    }
}
