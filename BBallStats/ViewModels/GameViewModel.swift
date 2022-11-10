//
//  GameViewModel.swift
//  BBallStats
//
//  Created by Chad Wallace on 10/27/22.
//

import SwiftUI

class GameViewModel: ObservableObject {
    @Published private var game = Game()
    
    var totalPoints: String {
        "\(game.totalPoints)"
    }
    
    var twoPointersMade: String {
        "\(game.twoPointersMade)"
    }
    
    var twoPointersAttempted: String {
        "\(game.twoPointersAttempted)"
    }
    
    var threePointersMade: String {
        "\(game.threePointersMade)"
    }
    
    var threePointersAttempted: String {
        "\(game.threePointersAttempted)"
    }
    
    var rebounds: String {
        "\(game.rebounds)"
    }
    
    var assists: String {
        "\(game.assists)"
    }

    var steals: String {
        "\(game.steals)"
    }
    
    var turnovers: String {
        "\(game.turnovers)"
    }

    var freeThrowsMade: String {
        "\(game.freeThrowsMade)"
    }
    
    var freeThrowsAttempted: String {
        "\(game.freeThrowsAttempted)"
    }
    
    func makeTwo(){
        game.makeTwo()
//        game.twoPointersMade = game.twoPointersMade + 1
//        game.twoPointersAttempted = game.twoPointersAttempted + 1
//        game.totalPoints = game.totalPoints + 2
    }
    
    func missTwo(){
        game.missTwo()
//        game.twoPointersAttempted = game.twoPointersAttempted + 1
    }
    
    func removeMakeTwo(){
        game.removeMakeTwo()
//        game.twoPointersMade = game.twoPointersMade - 1
//        game.twoPointersAttempted = game.twoPointersAttempted - 1
//        game.totalPoints = game.totalPoints - 2
        
    }
    
    func removeMissTwo(){
        game.removeMissTwo()
//        game.twoPointersAttempted = game.twoPointersAttempted - 1
    }
//
    func makeThree(){
        game.makeThree()
//        game.threePointersMade = game.threePointersMade + 1
//        game.threePointersAttempted = game.threePointersAttempted + 1
//        game.totalPoints = game.totalPoints + 3
    }
//
    func missThree(){
        game.missThree()
//        game.threePointersAttempted = game.threePointersAttempted + 1
    }
//
    func removeMakeThree(){
        game.removeMakeThree()
//        game.threePointersMade = game.threePointersMade - 1
//        game.threePointersAttempted = game.threePointersAttempted - 1
//        game.totalPoints = game.totalPoints - 3
    }
//
    func removeMissThree(){
        game.removeMissThree()
//        game.threePointersAttempted = game.threePointersAttempted - 1
    }
//
    func makeFT(){
        game.makeFT()
//        game.freeThrowsMade = game.freeThrowsMade + 1
//        game.freeThrowsAttempted = game.freeThrowsAttempted + 1
//        game.totalPoints = game.totalPoints + 1
    }
//
    func missFT(){
        game.missFT()
//        game.freeThrowsAttempted = game.freeThrowsAttempted + 1
    }
//
    func removeMakeFT(){
        game.removeMakeFT()
//        game.freeThrowsMade = game.freeThrowsMade - 1
//        game.freeThrowsAttempted = game.freeThrowsAttempted - 1
//        game.totalPoints = game.totalPoints - 1
    }
//
    func removeMissFT(){
        game.removeMissFT()
//        game.freeThrowsAttempted = game.freeThrowsAttempted - 1
    }
//
    func rebound(){
        game.rebound()
//        game.rebounds = game.rebounds + 1
    }
//
    func removeRebound(){
        game.removeRebound()
//        game.rebounds = game.rebounds - 1
    }
//
    func assist(){
        game.assist()
//        game.assists = game.assists + 1
    }
//
    func steal(){
        game.steal()
//        game.steals = game.steals + 1
    }
//
    func removeAssist(){
        game.removeAssist()
//        game.assists = game.assists - 1
    }
//
    func turnover(){
        game.turnover()
//        game.turnovers = game.turnovers + 1
    }
//
    func removeTurnover(){
        game.removeTurnover()
//        game.turnovers = game.turnovers - 1
    }
//
//    func reset(){
//        game.totalPoints = 0
//        game.twoPointersMade = 0
//        game.twoPointersAttempted = 0
//        game.threePointersMade = 0
//        game.threePointersAttempted = 0
//        game.freeThrowsMade = 0
//        game.freeThrowsAttempted = 0
//        game.rebounds = 0
//        game.assists = 0
//        game.turnovers = 0
//    }
    
}

