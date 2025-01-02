//
//  TrackApplicationApp.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 12/22/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,open url: URL,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      var handled: Bool

        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
          return true
        }

        // Handle other custom URL types.

        // If not handled by this app, return false.
        
    FirebaseApp.configure()
    return true
  }
    
}


@main
struct TrackApplicationApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
              .onOpenURL { url in
                                  // Handle the URL to complete the sign-in process
                                  GIDSignIn.sharedInstance.handle(url)
                              }
      }
    }
  }
}
