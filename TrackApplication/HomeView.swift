//
//  HomeView.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 12/22/24.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Welcome to the Home Screen!")
                .font(.largeTitle)
                .padding()

            Button(action: logOut) {
                Text("Log Out")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut() // Firebase sign-out
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview{
    HomeView()
}
