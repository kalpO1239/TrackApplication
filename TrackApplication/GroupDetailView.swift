//
//  GroupDetailView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 1/1/25.
//


import SwiftUI

struct GroupDetailView: View {
    let groupName: String
    
    var body: some View {
        TabView {
            AssignmentCreationView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("Create Assignment")
                }
            
            PriorAssignmentsView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Prior Assignments")
                }
            CreateGroupView()
                .tabItem{
                    Image(systemName: "person.2.fill")
                    Text("Group")
                }
        }
    }
}

#Preview{
    GroupDetailView(groupName: "String")
}
