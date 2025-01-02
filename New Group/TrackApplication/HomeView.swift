import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var logDataModel: LogDataModel // Access shared log data
    @State private var assignments: [String] = ["Assignment 1", "Assignment 2", "Assignment 3"] // Placeholder for assignments
    
    var body: some View {
        NavigationView {
            HStack(spacing: 20) {
                // Assignments Section
                VStack(alignment: .leading) {
                    Text("Assignments")
                        .font(.headline)
                        .padding(.bottom, 10)
                    
                    List(assignments, id: \.self) { assignment in
                        Text(assignment)
                    }
                    .listStyle(PlainListStyle())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 3)
                
                // Stats Section
                VStack {
                    Text("Weekly Stats")
                        .font(.headline)
                        .padding(.bottom, 10)
                    
                    Text("Total Weekly Mileage")
                        .font(.subheadline)
                    Text("\(calculateWeeklyMileage(), specifier: "%.2f") miles")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    
                    Button(action: logOut) {
                        Text("Log Out")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 3)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
    
    func calculateWeeklyMileage() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return logDataModel.logs
            .filter { $0.date >= startOfWeek }
            .reduce(0) { $0 + $1.miles }
    }
    
    func logOut() {
        FirebaseAuthManager.shared.logOut()
    }
}




#Preview {
   TabbedView()
}
