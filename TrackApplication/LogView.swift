import SwiftUI
import FirebaseAuth

struct LogView: View {
    @EnvironmentObject var workoutDataManager: WorkoutDataManager
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
            ZStack {
                ModernBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Back button
                        HStack {
                            ModernBackButton(action: {
                                presentationMode.wrappedValue.dismiss()
                            })
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Title Input
                        VStack(alignment: .leading) {
                            Text("Title")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#5B5E73"))
                            
                            TextField("Enter workout title", text: $title)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(hex: "#ECE3DF").opacity(0.5))
                                .cornerRadius(8)
                                .foregroundColor(Color(hex: "#5B5E73"))
                                .accentColor(Color(hex: "#5B5E73"))
                                .placeholder(when: title.isEmpty) {
                                    Text("Enter workout title")
                                        .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
                                }
                        }
                        .padding(.horizontal)
                        
                        // Description Input
                        VStack(alignment: .leading) {
                            Text("Description")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#5B5E73"))
                            
                            TextField("Enter Workout Description",text: $description)
                                .frame(height: 100)
                                .padding(4)
                                .background(Color(hex: "#ECE3DF").opacity(0.5))
                                .cornerRadius(8)
                                .foregroundColor(Color(hex: "#5B5E73"))
                                .accentColor(Color(hex: "#5B5E73"))
                                .placeholder(when: description.isEmpty) {
                                    Text("Enter Workout Description")
                                        .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
                                }
                        }
                        .padding(.horizontal)
                        
                        // Distance Input
                        VStack(alignment: .leading) {
                            Text("Distance")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#5B5E73"))
                            
                            HStack {
                                Picker("", selection: $leftMiles) {
                                    ForEach(0..<31, id: \.self) { Text("\($0)") }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 70, height: 100)
                                .accentColor(Color(hex: "#5B5E73"))
                                .foregroundColor(Color(hex: "#5B5E73"))
                                
                                Text(".")
                                    .font(.largeTitle)
                                    .foregroundColor(Color(hex: "#5B5E73"))
                                
                                Picker("", selection: $rightMiles) {
                                    ForEach(0..<100, id: \.self) { Text(String(format: "%02d", $0)) }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 70, height: 100)
                                .accentColor(Color(hex: "#5B5E73"))
                                .foregroundColor(Color(hex: "#5B5E73"))
                                
                                Text("miles")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#5B5E73"))
                            }
                        }
                        .padding()
                        .background(Color(hex: "#ECE3DF").opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Time Input
                        VStack(alignment: .leading) {
                            Text("Time")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#5B5E73"))
                            
                            HStack {
                                Picker("", selection: $selectedHours) {
                                    ForEach(0..<25, id: \.self) { Text(String(format: "%02d", $0)) }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 70, height: 100)
                                .accentColor(Color(hex: "#5B5E73"))
                                .foregroundColor(Color(hex: "#5B5E73"))
                                
                                Text(":")
                                    .font(.largeTitle)
                                    .foregroundColor(Color(hex: "#5B5E73"))
                                
                                Picker("", selection: $selectedMinutes) {
                                    ForEach(0..<60, id: \.self) { Text(String(format: "%02d", $0)) }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 70, height: 100)
                                .accentColor(Color(hex: "#5B5E73"))
                                .foregroundColor(Color(hex: "#5B5E73"))
                                
                                Text(":")
                                    .font(.largeTitle)
                                    .foregroundColor(Color(hex: "#5B5E73"))
                                
                                Picker("", selection: $selectedSeconds) {
                                    ForEach(0..<60, id: \.self) { Text(String(format: "%02d", $0)) }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 70, height: 100)
                                .accentColor(Color(hex: "#5B5E73"))
                                .foregroundColor(Color(hex: "#5B5E73"))
                            }
                        }
                        .padding()
                        .background(Color(hex: "#ECE3DF").opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Date Selection
                        VStack(alignment: .leading) {
                            Text("Date")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#5B5E73"))
                            
                            Text(formattedDate)
                                .foregroundColor(Color(hex: "#5B5E73"))
                                .padding(.bottom, 5)
                            
                            DisclosureGroup("Select Date", isExpanded: $isDatePickerExpanded) {
                                datePicker
                            }
                            .foregroundStyle(Color(hex: "#5B5E73"))
                            .padding()
                            .background(Color(hex: "#ECE3DF").opacity(0.5))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Submit Button
                        Button(action: handleSubmit) {
                            Text("Save")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#5B5E73"),
                                            Color(hex: "#433F4E")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(Color(hex: "#ECE3DF"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
    
    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Date")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#5B5E73"))
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .accentColor(Color(hex: "#5B5E73"))
                .foregroundColor(Color(hex: "#5B5E73"))
                .background(Color(hex: "#ECE3DF").opacity(0.5))
                .cornerRadius(12)
                .padding()
                .background(Color(hex: "#ECE3DF").opacity(0.5))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    func handleSubmit() {
        let totalMiles = Double(leftMiles) + Double(rightMiles) / 100.0
        let totalTimeInMinutes = selectedHours * 60 + selectedMinutes + selectedSeconds / 60
        
        workoutDataManager.addWorkout(
            date: date,
            miles: totalMiles,
            title: title,
            timeInMinutes: totalTimeInMinutes,
            description: description
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    LogView()
        .environmentObject(WorkoutDataManager.shared)
}
