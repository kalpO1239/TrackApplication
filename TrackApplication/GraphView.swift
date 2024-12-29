//
//  GraphView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 12/28/24.
//


import SwiftUI
import Charts

struct GraphView: View {
    @EnvironmentObject var logDataModel: LogDataModel // Use @EnvironmentObject instead of @ObservedObject
    
    var body: some View {
        VStack {
            if !logDataModel.logs.isEmpty {
                Chart {
                    ForEach(logDataModel.logs, id: \.date) { log in
                        BarMark(x: .value("Date", log.date),
                                y: .value("Miles", log.miles))
                    }
                }
                .frame(height: 300)
            } else {
                Text("No logs available")
            }
        }
    }
}

