//
//  ResetView.swift
//  BBallStats
//
//  Created by Chad Wallace on 10/27/22.
//

import SwiftUI

struct ResetView: View {
    
    // Let's always listen to the GameViewModel for changes to make to this GameView
    @EnvironmentObject var game: Game
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {

            
            VStack{
                VStack{
                    Text("Are you sure you want to reset the stats?")
                    Text("             ")
                }
                .font(.system(size: 40, weight: .bold))
                
                HStack{
                    
                    Button("Yes"){
                            //Do somethings here
                            game.totalPoints = 0
                            game.twoPointersMade = 0
                            game.twoPointersAttempted = 0
                            game.threePointersMade = 0
                            game.threePointersAttempted = 0
                            game.rebounds = 0
                            game.assists = 0
                            game.steals = 0
                            game.turnovers = 0
                            game.freeThrowsMade = 0
                            game.freeThrowsAttempted = 0
                            //Navigate
                            dismiss()
                        }
                     .font(.system(size: 24, weight: .bold))
                        .padding()

                    
                    Button("No") {
                        dismiss()
                    }
                    .font(.system(size: 24, weight: .bold))
                        .padding()

                    
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
