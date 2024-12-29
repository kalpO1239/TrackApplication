import SwiftUI



struct LogView: View {
    @State private var miles: String = ""
    @State private var hours: String = ""
    @State private var minutes: String = ""
    @State private var seconds: String = ""
    
    @EnvironmentObject var logDataModel: LogDataModel // Use @EnvironmentObject instead of @ObservedObject
    
    var body: some View {
        VStack {
            TextField("Enter Miles", text: $miles)
            // Your other log inputs here...
            
            Button(action: handleSubmit) {
                Text("Submit Log")
            }
        }
    }
    
    func handleSubmit() {
        guard let miles = Double(miles) else { return }
        
        // You can add other information like time or description if necessary
        let currentDate = Date()
        
        // Add the new log data to the shared model
        logDataModel.addLog(date: currentDate, miles: miles)
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
            
            // Pass the instance of logDataModel to LogView using environmentObject
            LogView()
                .tabItem {
                    Image(systemName: "pencil.circle.fill")
                    Text("Log Run")
                }
                .environmentObject(logDataModel) // Inject the instance of LogDataModel into the environment
            
            // Pass the instance of logDataModel to GraphView using environmentObject
            GraphView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
                .environmentObject(logDataModel) // Inject the instance of LogDataModel into the environment
        }
    }
}

#Preview {
    TabbedView()
}


#Preview {
    TabbedView()
}
