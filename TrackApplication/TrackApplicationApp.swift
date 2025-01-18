import SwiftUI
import Firebase
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Configure Firebase before anything else
    FirebaseApp.configure()
    return true
  }

  func application(_ application: UIApplication, open url: URL,
                   options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Handle Google Sign-In URL
    return GIDSignIn.sharedInstance.handle(url)
  }
}

@main
struct TrackApplicationApp: App {
  // Register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      NavigationView {
        RoleSelectionView()
          .onOpenURL { url in
            // Handle the URL to complete the sign-in process
            GIDSignIn.sharedInstance.handle(url)
          }
      }
    }
  }
}
