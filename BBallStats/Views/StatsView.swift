//
//  StatsView.swift
//  BBallStats
//
//  Created by Chad Wallace on 11/2/22.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var game: Game

    var body: some View {
//        Text("          ")
        HStack{
            Text("\(game.totalPoints) (tot pts)")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.twoPointersMade)-\(game.twoPointersAttempted) (2-pt)")
        } // end HStack
        .font(.system(size: 23, weight: .bold))
        
        HStack{
            Text("\(game.threePointersMade)-\(game.threePointersAttempted) (3-pt)")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.freeThrowsMade)-\(game.freeThrowsAttempted) (FT)")
        } // end HStack
        .font(.system(size: 23, weight: .bold))
        
        HStack{
            Text("\(game.rebounds) Reb")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.assists) Asst")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.steals) Stls")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.blocks) Blks")
//            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
        }
        .font(.system(size: 23, weight: .bold))
        
        HStack{
            Text("\(game.turnovers) TO")
        }
        .font(.system(size: 24, weight: .bold))

        } // end VStack for bottom Fix and stat lines
    }


//struct StatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatsView()
//    }
//}
