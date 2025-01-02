import SwiftUI
import Charts

struct GraphView: View {
    @EnvironmentObject var logDataModel: LogDataModel
    
    var body: some View {
        VStack {
            if !logDataModel.logs.isEmpty {
                let weeklyLogs = aggregateLogsByWeek(logs: logDataModel.logs)
                
                Chart {
                    ForEach(weeklyLogs, id: \.weekStart) { weekLog in
                        LineMark(
                            x: .value("Week Starting", weekLog.weekStart),
                            y: .value("Total Miles", weekLog.totalMiles)
                        )
                        .symbol(Circle())
                        .foregroundStyle(.blue)
                    }
                }
                .frame(height: 300)
                .padding()
            } else {
                Text("No logs available")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    func aggregateLogsByWeek(logs: [Log]) -> [WeeklyLog] {
        var weeklyData: [Date: Double] = [:]
        
        let calendar = Calendar.current
        for log in logs {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: log.date)?.start ?? log.date
            weeklyData[weekStart, default: 0] += log.miles
        }
        
        return weeklyData.map { WeeklyLog(weekStart: $0.key, totalMiles: $0.value) }
    }
}

struct WeeklyLog {
    let weekStart: Date
    let totalMiles: Double
}
