//
//  Game.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 10/27/22.
//

import Foundation

class Game: ObservableObject {
    // All of these properties can change. We want them available to other views.
    @Published var totalPoints = 0
    @Published var twoPointersMade = 0
    @Published var twoPointersAttempted = 0
    @Published var threePointersMade = 0
    @Published var threePointersAttempted = 0
    @Published var rebounds = 0
    @Published var assists = 0
    @Published var steals = 0
    @Published var blocks = 0
    @Published var turnovers = 0
    @Published var freeThrowsMade = 0
    @Published var freeThrowsAttempted = 0
    @Published var fouls = 0

    
    func makeTwo(){
        twoPointersMade += 1
        twoPointersAttempted += 1
        totalPoints += 2
        }

   func missTwo(){
        twoPointersAttempted = twoPointersAttempted + 1
    }

    func removeMakeTwo(){
        if twoPointersMade != 0 {
            twoPointersMade = twoPointersMade - 1
            twoPointersAttempted = twoPointersAttempted - 1
            totalPoints = totalPoints - 2
        }
    }

    func removeMissTwo(){
        if twoPointersAttempted != 0 {
            twoPointersAttempted = twoPointersAttempted - 1
        }
    }

    func makeThree(){
        threePointersMade = threePointersMade + 1
        threePointersAttempted = threePointersAttempted + 1
        totalPoints = totalPoints + 3
    }

    func missThree(){
        threePointersAttempted = threePointersAttempted + 1
    }

    func removeMakeThree(){
        if threePointersMade != 0 {
            threePointersMade = threePointersMade - 1
            threePointersAttempted = threePointersAttempted - 1
            totalPoints = totalPoints - 3
        }
    }

    func removeMissThree(){
        if threePointersAttempted != 0 {
            threePointersAttempted = threePointersAttempted - 1
        }
    }

    func makeFT(){
        freeThrowsMade = freeThrowsMade + 1
        freeThrowsAttempted = freeThrowsAttempted + 1
        totalPoints = totalPoints + 1
    }

    func missFT(){
        freeThrowsAttempted = freeThrowsAttempted + 1
    }

    func removeMakeFT(){
        if freeThrowsMade != 0 {
            freeThrowsMade = freeThrowsMade - 1
            freeThrowsAttempted = freeThrowsAttempted - 1
            totalPoints = totalPoints - 1
        }
    }

    func removeMissFT(){
        if freeThrowsAttempted != 0 {
            freeThrowsAttempted = freeThrowsAttempted - 1
        }
    }

    func rebound(){
        rebounds = rebounds + 1
    }

    func removeRebound(){
        if rebounds != 0 {
            rebounds = rebounds - 1
        }
    }

    func assist(){
        assists = assists + 1
    }

    func steal(){
        steals = steals + 1
    }
    
    func block(){
        blocks = blocks + 1
    }
    
    func foul(){
        if fouls < 5 {
            fouls = fouls + 1
        }
    }

    
    func removeAssist(){
        if assists != 0 {
            assists = assists - 1
        }
    }
    
    func removeSteal(){
        if steals != 0 {
            steals = steals - 1
        }
    }
    
    func removeFoul(){
        if fouls != 0 {
            fouls = fouls - 1
        }
    }
    
    func removeBlock(){
        if blocks != 0 {
            blocks = blocks - 1
        }
    }

    func turnover(){
        turnovers = turnovers + 1
    }

    func removeTurnover(){
        if turnovers != 0 {
            turnovers = turnovers - 1
        }
    }

   
    
} // end struct Game

