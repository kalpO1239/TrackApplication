//
//  GoogleSignInButton.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 12/28/24.
//


import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image("googleLogo") // Add a Google logo to your Assets folder
                    .resizable()
                    .frame(width: 20, height: 20)

                Text("Sign in with Google")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray)
            .cornerRadius(8)
        }
    }
}
