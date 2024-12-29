import UIKit
import SwiftUI
import Charts

class GraphViewController: UIViewController {
    
    // Example: A simple list of log entries for the graph
    var logEntries: [LogEntry] = [
        LogEntry(date: "2024-12-28", value: 15),
        LogEntry(date: "2024-12-29", value: 20),
        LogEntry(date: "2024-12-30", value: 25)
    ]
    
    // Chart view
    private var chartView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the chart view
        setupChart()
    }
    
    private func setupChart() {
        // Create a SwiftUI view for the chart
        let chart = Chart {
            ForEach(logEntries, id: \.date) { entry in
                BarMark(
                    x: .value("Date", entry.date),
                    y: .value("Value", entry.value)
                )
                .foregroundStyle(.blue) // Customize the bar color
            }
        }
        .frame(height: 300)
        
        // Create a hosting controller for the SwiftUI view
        let hostingController = UIHostingController(rootView: chart)
        
        // Add the hosting controller to the view hierarchy
        hostingController.view.frame = CGRect(x: 20, y: 100, width: self.view.bounds.width - 40, height: 300)
        self.view.addSubview(hostingController.view)
    }
}

// Log Entry struct to represent each log's date and value
struct LogEntry {
    var date: String
    var value: Double
}
