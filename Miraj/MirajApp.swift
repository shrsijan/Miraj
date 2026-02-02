//
//  MirajApp.swift
//  Miraj
//
//  Created by Sijan Shrestha on 1/31/26.
//

import SwiftUI
import ParseSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Parse SDK
        ParseSwift.initialize(
            applicationId: "8hqAX9tOK7qW3Uc5QITiitR2n6AzeNRr8A1I2bAo",
            clientKey: "WAvngU73kx1mE3iEis0kyoySAgV7C0UNbML7wtIg",
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )
        return true
    }
}

@main
struct MirajApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isLoggedIn = false
    @State private var isCheckingLogin = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isCheckingLogin {
                    // Show loading screen while checking login status
                    ZStack {
                        Color.black.ignoresSafeArea()
                        VStack(spacing: 16) {
                            Text("miraj")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                } else if isLoggedIn {
                    MainTabView(isLoggedIn: $isLoggedIn)
                } else {
                    AuthView(isLoggedIn: $isLoggedIn)
                }
            }
            .onAppear {
                // Check login status after Parse is initialized
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoggedIn = User.current != nil
                    isCheckingLogin = false
                }
            }
        }
    }
}
