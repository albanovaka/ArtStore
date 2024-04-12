//
//  ArtStoreApp.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-03.
//

import SwiftUI
import Firebase
import GoogleSignIn
import Stripe

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        StripeAPI.defaultPublishableKey = "pk_live_51P4BgHRskL4sBcIggbWXiDMRko3YK6buRj7MM342qS8r7MUvTPmTuhhCdDBfIJrLj93X4mB8lpOMUVDqysuzX2J700w5I2YavM"
        
        return true
    }
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("URL received: \(url)")
      return GIDSignIn.sharedInstance.handle(url)
    }
}
@main
struct ArtStoreApp: App {
    @StateObject var viewModel = AuthViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
