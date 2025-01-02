import SwiftUI

struct LogView: View {
    @State private var title: String = ""
    @State private var miles: String = ""
    @State private var hours: String = ""
    @State private var minutes: String = ""
    @State private var date: Date = Date() // State for the date
    @State private var isDatePickerVisible: Bool = false // Track if the date picker modal is visible
    
    @EnvironmentObject var logDataModel: LogDataModel // Use @EnvironmentObject
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Log Your Workout")
                .font(.title)
                .bold()
            
            // Title input
            TextField("Enter Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Miles input
            TextField("Enter Miles", text: $miles)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Hours and Minutes input
            HStack {
                TextField("Hours", text: $hours)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Minutes", text: $minutes)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            // Date Picker Button
            Button(action: {
                isDatePickerVisible.toggle() // Show the date picker modal
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text("Select Date: \(formattedDate(date))")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // Submit button
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
        .sheet(isPresented: $isDatePickerVisible) {
            VStack {
                DatePicker(
                    "Select Workout Date",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Button("Done") {
                    isDatePickerVisible = false // Dismiss the modal
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
        }
        .padding()
    }
    
    func handleSubmit() {
        guard let miles = Double(miles) else { return }
        guard let minutes = Int(minutes), let hours = Int(hours) else { return }
        
        let totalTime = hours * 60 + minutes // Calculate total minutes
        
        // Add the new log data to the shared model
        logDataModel.addLog(date: date, miles: miles, title: title, timeInMinutes: totalTime)
    }
    
    // Helper to format date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


struct TabbedView: View {
    // Create an instance of LogDataModel
    @StateObject private var logDataModel = LogDataModel()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .environmentObject(logDataModel)
            
            LogView()
                .tabItem {
                    Image(systemName: "pencil.circle.fill")
                    Text("Log Run")
                }
                .environmentObject(logDataModel) // Inject the instance of LogDataModel into the environment
            
            GraphView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
                .environmentObject(logDataModel) // Inject the instance of LogDataModel into the environment
        }
    }
}

#Preview{
    TabbedView()
}
