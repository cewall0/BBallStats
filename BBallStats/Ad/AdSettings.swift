//
//  AdSettings.swift
//  My BBaller Stats
//
//  Created by Chad Wallace on 2/20/25.
//

import SwiftUI
import AppTrackingTransparency
import Foundation
import AdSupport



// NEWLY ADDED PERMISSIONS FOR IOS 14
func requestPermission() {
    @AppStorage("isPurchased") var isPurchased = false
    @AppStorage("requestAds") var requestAds = false
    if !isPurchased {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    requestAds = true
                    // Now that we are authorized we an get the IDFA
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                    // Tracking authorization dialog
                    // was shown and permission is denied
                    print("Denied")
                    requestAds = true
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                    requestAds = true
                case .restricted:
                    print("Restricted")
                    requestAds = true
                @unknown default:
                    print("Unknown")
                }
            }
        }
    }
}
