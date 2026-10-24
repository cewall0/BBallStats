//
//  BBallStatsApp.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 10/21/22.
//

import SwiftUI
import WallaceAds

@main
struct BBallStatsApp: App {
    @State private var game = Game()
    
    init() {
        #if DEBUG
        let useTestAds = true
        #else
        let useTestAds = false
        #endif
        WallaceAds.configure(.init(
            bannerID: "ca-app-pub-5511806561009019/3713108205",
            useTestAds: useTestAds
        ))
    }
    
    var body: some Scene {
        WindowGroup {
                SplashScreenView()
                .environment(game)
        }
    }
}

