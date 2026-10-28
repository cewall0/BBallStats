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
    @State private var game = Game.loadSaved()
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        #if DEBUG
        let useTestAds = true
        #else
        let useTestAds = false
        #endif
        WallaceAds.configure(.init(
            bannerID: "ca-app-pub-5511806561009019/3713108205",
            interstitialID: "ca-app-pub-5511806561009019/7043277180",
            useTestAds: useTestAds
        ))
    }
    
    var body: some Scene {
        WindowGroup {
                SplashScreenView()
                .environment(game)
                .onChange(of: scenePhase) { _, phase in
                    if phase != .active { game.save() } // keep the stats if iOS closes the app
                }
                .onAppear { UIApplication.shared.isIdleTimerDisabled = true } // keep the screen awake during play
        }
    }
}

