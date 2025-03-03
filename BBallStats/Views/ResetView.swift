//
//  ResetView.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 10/27/22.
//

import Foundation
import SwiftUI
import Observation

struct ResetView: View {
    
    // Let's always listen to the GameViewModel for changes to make to this GameView
    @Environment(Game.self) private var game
    @Environment(\.dismiss) private var dismiss
    
    var deviceHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    var body: some View {

            
            VStack{
                VStack{
                    Text("Are you sure you want to reset the stats?")
                    Text("             ")
                }
                .font(.system(size: deviceHeight/770 * 40, weight: .bold))
                .padding()
                
                HStack{
                    
                    Button("Yes"){
                            //Then, reset all of the stats
                            game.totalPoints = 0
                            game.twoPointersMade = 0
                            game.twoPointersAttempted = 0
                            game.threePointersMade = 0
                            game.threePointersAttempted = 0
                            game.rebounds = 0
                            game.assists = 0
                            game.steals = 0
                            game.blocks = 0
                            game.turnovers = 0
                            game.freeThrowsMade = 0
                            game.freeThrowsAttempted = 0
                            game.fouls = 0
                            //Navigate
                            dismiss()
                        }
                     .font(.system(size: deviceHeight/770 * 40, weight: .bold))
                        .padding(30)

                    
                    Button("No") {
                        // Do nothing
                        dismiss()
                    }
                    .font(.system(size: deviceHeight/770 * 40, weight: .bold))
                        .padding(30)

                    
                } // end HStack
            } // end VStack
            .navigationTitle("")
        }
    }

struct ResetView_Previews: PreviewProvider {
    static var previews: some View {
        ResetView()
    }
}
