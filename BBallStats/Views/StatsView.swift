//
//  StatsView.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 11/2/22.
//

import SwiftUI

struct StatsView: View {
    @Environment(Game.self) private var game
    @State private var made2IsPressed = false
    
    var deviceHeight: CGFloat {
        UIScreen.main.bounds.height
    }


    var body: some View {
        Text("          ")
        HStack{
            Text("\(game.totalPoints) (tot pts)")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.twoPointersMade)-\(game.twoPointersAttempted) (2-pt)")
        } // end HStack
        .font(.system(size: deviceHeight/770 * 30, weight: .bold))
        .scaleEffect(made2IsPressed ? 1.2 : 1.0)
        .opacity(made2IsPressed ? 0.6 : 1.0).pressEvents {
            // On press
            withAnimation(.easeInOut(duration: 0.1)) {
                made2IsPressed = true
            }
        } onRelease: {
            withAnimation {
                made2IsPressed = false
            }
        }
        
        HStack{
            Text("\(game.threePointersMade)-\(game.threePointersAttempted) (3-pt)")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.freeThrowsMade)-\(game.freeThrowsAttempted) (FT)")
        } // end HStack
        .font(.system(size: deviceHeight/770 * 30, weight: .bold))
        
        HStack{
            Text("\(game.rebounds) Reb")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.assists) Asst")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.steals) Stls")
//            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
        }
        .font(.system(size: deviceHeight/770 * 30, weight: .bold))
        
        HStack{
            Text("\(game.turnovers) TO")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.blocks) Blks")
            Text("|").foregroundColor(Color(UIColor(red:0/255, green: 0/255, blue: 205/255, alpha: 1.0)))
            Text("\(game.fouls) Fls")
        }
        .font(.system(size: deviceHeight/770 * 30, weight: .bold))

        } // end VStack for bottom Fix and stat lines
    }


//struct StatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatsView()
//    }
//}
