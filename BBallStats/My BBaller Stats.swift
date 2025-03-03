//
//  BBallStatsApp.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 10/21/22.
//

import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds

@main
struct BBallStatsApp: App {
    @State private var game = Game()
    
    init() {
        // Step 1: Print the AdMob App ID from Info.plist
        if let appID = Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String {
            print("Google Mobile Ads App ID found: \(appID)")
        } else {
            print("⚠️ Google Mobile Ads App ID NOT FOUND in Info.plist!")
        }

        // Step 2: Request tracking authorization
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            // User hasn't made a choice yet, could show a prompt
        } else {
            // Initialize AdMob
            ATTrackingManager.requestTrackingAuthorization { status in
                // Step 3: Initialize Google Mobile Ads SDK
                DispatchQueue.main.async {
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                    print("✅ Google Mobile Ads SDK initialized")
                }
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
                SplashScreenView()
                .environment(game)
        }
    }
}

