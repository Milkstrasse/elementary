//
//  UserProgress.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.10.22.
//

import Foundation

struct UserProgress: Codable {
    var lastDate: Date = Date()
    
    var fightCounter: Int = 0
    private var winCounter: Int = 0
    var winStreak: Int = 0
    
    var winAllAlive: Bool = false
    
    var weatherUses: [Bool] = [Bool](repeating: false, count: Weather.allCases.count)
    var hexUses: [Bool] = [Bool](repeating: false, count: Hexes.allCases.count)
    
    var dailyFightCounter: Int = 0
    var dailyElementCounter: Int = 0
    
    /// Advances user progress by increasing win counters.
    /// - Parameters:
    ///   - winner: Indicates the winner
    ///   - fighters: The fighters used in the fight
    mutating func addWin(winner: Int, fighters: [Fighter]) {
        if winner == 1 {
            winCounter += 1
            
            if winCounter > winStreak {
                winStreak = winCounter
            }
            
            var allAlive: Bool = true
            
            for fighter in fighters {
                if fighter.currhp > 0 {
                    if fighter.getElement().name == getDailyElement().name {
                        dailyElementCounter += 1
                    }
                } else {
                    allAlive = false
                }
            }
            
            if allAlive {
                winAllAlive = true
            }
        } else {
            winCounter = 0
        }
        
        addFight()
    }
    
    /// Advances user progress by increasing fight counters.
    mutating func addFight() {
        resetDaily()
        
        dailyFightCounter += 1
        fightCounter += 1
    }
    
    func getDailyElement() -> Element {
        var index: Int = Calendar.current.component(.month, from: lastDate) + Calendar.current.component(.weekday, from: lastDate) - 2
        index -= index/12 * 12
        
        return GlobalData.shared.elementArray[index]
    }
    
    mutating func resetDaily() {
        if !Calendar.current.isDateInToday(lastDate) {
            dailyFightCounter = 0
            dailyElementCounter = 0
            lastDate = Date()
        }
    }
    
    func getWeatherAmount() -> Int {
        var counter: Int = 0
        for weather in weatherUses {
            if weather {
                counter += 1
            }
        }
        
        return counter
    }
    
    func getHexAmount() -> Int {
        var counter: Int = 0
        for hex in hexUses {
            if hex {
                counter += 1
            }
        }
        
        return counter
    }
}
