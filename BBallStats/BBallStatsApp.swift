//
//  BBallStatsApp.swift
//  BBallStats
//
//  Created by Chad Wallace on 10/21/22.
//

import SwiftUI

@main
struct BBallStatsApp: App {
    @StateObject private var game = Game()
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(game)
        }
    }
}
