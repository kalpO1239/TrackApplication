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
            StudentCatalogView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Students")
                        
                }
                

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
        }
        .navigationTitle(groupName)
    }
}

#Preview{
    GroupDetailView(groupName: "String")
}
