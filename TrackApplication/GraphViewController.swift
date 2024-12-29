//
//  GraphViewController.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 12/28/24.
//

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
    }
    
    private func setupChart() {
        // Create a SwiftUI view for the chart
        let chart = Chart {
            ForEach(logEntries, id: \.date) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Value", entry.value)
                )
                .symbol(Circle()) // Add data point markers
                .foregroundStyle(.blue) // Customize line color
            }
        }
        .frame(height: 300)
        
        // Create a hosting controller for the SwiftUI view
        let hostingController = UIHostingController(rootView: chart)
        
        // Add the hosting controller to the view hierarchy
        hostingController.view.frame = CGRect(x: 20, y: 100, width: self.view.bounds.width - 40, height: 300)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}

// Log Entry struct to represent each log's date and value
struct LogEntry {
    var date: String
    var value: Double
}
