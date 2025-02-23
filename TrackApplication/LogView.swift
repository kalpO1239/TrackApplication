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
    @State private var selectedHundredths: Int = 0
    @State private var date: Date = Date()
    @State private var isDatePickerExpanded: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 15) {
            Picker("Select Workout Type", selection: $selectedWorkoutType) {
                ForEach(workoutTypes, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            
            TextField("Enter Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextEditor(text: $description)
                .frame(height: 80)
                .border(Color.gray, width: 1)
                .padding(.horizontal)
            
            HStack {
                Picker("", selection: $leftMiles) {
                    ForEach(0..<31, id: \.self) { Text("\($0)") }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 80)
                
                Text(".")
                
                Picker("", selection: $rightMiles) {
                    ForEach(0..<100, id: \.self) { Text(String(format: "%02d", $0)) }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 80)
            }
            
            HStack {
                Picker("", selection: $selectedHours) {
                    ForEach(0..<25, id: \.self) { Text("\($0)") }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 80)
                
                Text(":")
                
                Picker("", selection: $selectedMinutes) {
                    ForEach(0..<60, id: \.self) { Text("\($0)") }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 80)
                
                Text(":")
                
                Picker("", selection: $selectedSeconds) {
                    ForEach(0..<60, id: \.self) { Text("\($0)") }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 80)
                
                Text(".")
                
                Picker("", selection: $selectedHundredths) {
                    ForEach(0..<100, id: \.self) { Text("\($0)") }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 80)
            }
            
            DisclosureGroup("Select Date", isExpanded: $isDatePickerExpanded) {
                DatePicker("Workout Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding(.vertical, 5)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            
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
        .padding(.vertical, 10)
    }
    
    private func handleSubmit() {
        let miles = Double(leftMiles) + Double(rightMiles) / 100.0
        let totalTime = (selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds + (selectedHundredths / 100)

        // Add workout to manager
        workoutDataManager.addWorkout(date: date, miles: miles, title: title, timeInMinutes: totalTime)
        
        // Navigate back to home view
        presentationMode.wrappedValue.dismiss()
    }
}
