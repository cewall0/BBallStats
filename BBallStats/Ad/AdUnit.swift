//
//  AdUnit.swift
//  My BBaller Stats
//
//  Created by Chad Wallace on 2/20/25.
//

import SwiftUI
import AdSupport
import AppTrackingTransparency
import Foundation
import GoogleMobileAds

enum AdUnit {
    case homeRewarded
    case homeInterstitial
    case homeBanner
    case homeOpenAd
    // You should return your ad unit IDs here
    var unitID: String {
        switch self {
            #if DEBUG
            // Admob Test ID
        case .homeRewarded: return ""
        case .homeInterstitial: return ""
        case .homeBanner: return "ca-app-pub-3940256099942544/2934735716"
        case .homeOpenAd: return ""
            #else
        // Admob ID
        case .homeRewarded: return rewardedID
        case .homeInterstitial: return interstitialID
        case .homeBanner: return bannerID
        case .homeOpenAd: return openAdID
            #endif
        }
    }
}

//Admob Release ID
let bannerID = "ca-app-pub-5511806561009019/3713108205" //ok
let interstitialID = "" //ok
let rewardedID = "" //ok
let openAdID = "" //ok

