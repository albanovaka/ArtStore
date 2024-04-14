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
        StripeAPI.defaultPublishableKey = "pk_test_51P4BgHRskL4sBcIg4WQ5clxBEGTKd34sLI4Hht5bYj35SSXTFb2jQGZZXf9IB2FJfMxZ9HVpwoIkqZmMXVc8XETt00z1HwU1i7"
        
        return true
    }
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme?.hasPrefix("com.googleusercontent.apps") == true {
                return GIDSignIn.sharedInstance.handle(url)
            }


            if url.scheme == "artstore" {
                NotificationCenter.default.post(name: NSNotification.Name("StripePaymentCompleted"), object: nil)
                return true
            }

            return false
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
