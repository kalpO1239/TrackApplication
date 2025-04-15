//
//  GroupDetailView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 1/1/25.
//


import SwiftUI
import FirebaseAuth

struct GroupDetailView: View {
    let groupName: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ModernBackground()
                
                VStack(spacing: 0) {
                    // Header with group name and logout button
                    HStack {
                        Text(groupName)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#433F4E"))
                        Spacer()
                        Button(action: {
                            do {
                                try Auth.auth().signOut()
                                // Navigate back to login page
                                if let window = UIApplication.shared.windows.first {
                                    window.rootViewController = UIHostingController(rootView: RoleSelectionView())
                                    window.makeKeyAndVisible()
                                }
                            } catch {
                                print("Error signing out: \(error.localizedDescription)")
                            }
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#5B5E73"))
                                .padding(8)
                                .background(Color(hex: "#ECE3DF").opacity(0.5))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Tab View
                    TabView {
                        AssignmentCreationView()
                            .tabItem {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Create Assignment")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                        
                        PriorAssignmentsView()
                            .tabItem {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Prior Assignments")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                        
                        CreateGroupView()
                            .tabItem {
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Group")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                    }
                    .onAppear {
                        let appearance = UITabBarAppearance()
                        appearance.configureWithOpaqueBackground()
                        appearance.backgroundColor = UIColor(Color(hex: "#ECE3DF"))
                        
                        UITabBar.appearance().standardAppearance = appearance
                        UITabBar.appearance().scrollEdgeAppearance = appearance
                    }
                }
            }
        }
    }
}

struct ModernBackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .medium))
                Text("Back")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
            .foregroundColor(Color(hex: "#5B5E73"))
            .padding(8)
            .background(Color(hex: "#ECE3DF").opacity(0.5))
            .cornerRadius(8)
        }
    }
}

#Preview {
    GroupDetailView(groupName: "Test Group")
}
