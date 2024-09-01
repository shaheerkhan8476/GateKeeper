//
//  GatekeeperApp.swift
//  Gatekeeper
//
//  Created by Shaheer Khan on 7/8/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
          
    return true
  }
    func application(_ app: UIApplication,
                       open url: URL,
                       options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

}

@main
struct GatekeeperApp: App {
  // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var accountViewModel = AccountViewModel()
    @StateObject private var friendsViewModel = FriendsViewModel()
  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
              .environmentObject(userViewModel)
              .environmentObject(accountViewModel)
              .environmentObject(friendsViewModel)
      }
    }
  }
}
