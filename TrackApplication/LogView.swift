import SwiftUI

struct LogView: View {
    @EnvironmentObject var workoutDataManager: WorkoutDataManager
    @State private var selectedWorkoutType: String = "Workouts"
    let workoutTypes = ["Workouts", "Personal"]
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var leftMiles: Int = 0
    @State private var rightMiles: Int = 0
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 0
    @State private var date: Date = Date()
    @State private var isDatePickerExpanded: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Workout Type Selector
                    Picker("Workout Type", selection: $selectedWorkoutType) {
                        ForEach(workoutTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Distance Input (Full Width)
                    VStack {
                        Text("Distance")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Picker("", selection: $leftMiles) {
                                ForEach(0..<31, id: \.self) { Text("\($0)") }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 70, height: 100)
                            
                            Text(".")
                                .font(.largeTitle)
                            
                            Picker("", selection: $rightMiles) {
                                ForEach(0..<100, id: \.self) { Text(String(format: "%02d", $0)) }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 70, height: 100)
                            
                            Text("miles")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Time Input (Full Width)
                    VStack {
                        Text("Time")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Picker("", selection: $selectedHours) {
                                ForEach(0..<25, id: \.self) { Text(String(format: "%02d", $0)) }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 70, height: 100)
                            
                            Text(":")
                                .font(.largeTitle)
                            
                            Picker("", selection: $selectedMinutes) {
                                ForEach(0..<60, id: \.self) { Text(String(format: "%02d", $0)) }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 70, height: 100)
                            
                            Text(":")
                                .font(.largeTitle)
                            
                            Picker("", selection: $selectedSeconds) {
                                ForEach(0..<60, id: \.self) { Text(String(format: "%02d", $0)) }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 70, height: 100)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Date Selection (Full Width)
                    VStack(alignment: .leading) {
                        Text("Date")
                            .font(.headline)
                        
                        Text(formattedDate)
                            .foregroundColor(.gray)
                            .padding(.bottom, 5)
                        
                        DisclosureGroup("Select Date", isExpanded: $isDatePickerExpanded) {
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding(.vertical, 5)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Title & Notes
                    VStack(alignment: .leading) {
                        Text("Title")
                            .font(.headline)
                        TextField("Enter title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("Description")
                            .font(.headline)
                            .padding(.top, 5)
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .border(Color.gray, width: 1)
                            .cornerRadius(5)
                    }
                    .padding(.horizontal)
                    
                    // Submit Button
                    Button(action: handleSubmit) {
                        Text("Save")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer() // Ensures smooth scrolling
                }
                .padding(.vertical)
                .frame(minHeight: geometry.size.height) // Ensures full scrollability
            }
        }
    }
    
    private func handleSubmit() {
        let miles = Double(leftMiles) + Double(rightMiles) / 100.0
        let totalTime = (selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds

        // Add workout to manager
        workoutDataManager.addWorkout(date: date, miles: miles, title: title, timeInMinutes: totalTime)
        
        // Navigate back to home view
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    LogView()
        .environmentObject(WorkoutDataManager.shared)
}
