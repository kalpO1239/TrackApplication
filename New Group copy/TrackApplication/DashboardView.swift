//
//  DashboardView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 1/1/25.
//


//  DashboardView.swift
//  TrackApplication

import SwiftUI

struct DashboardView: View {
    @State private var groups: [String] = ["Group 1", "Group 2", "Group 3"] // Mock data for groups

    var body: some View {
        NavigationView {
            List(groups, id: \.self) { group in
                NavigationLink(destination: GroupDetailView(groupName: group)) {
                    Text(group)
                }
            }
            .navigationTitle("Your Groups")
        }
    }
}