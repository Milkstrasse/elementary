//
//  UserProgress.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.10.22.
//

import Foundation

/// Tracks progress of user with different stats.
struct UserProgress: Codable {
    var lastDate: Date = Date()
    
    var fightCounter: Int = 0
    private var winCounter: Int = 0
    var winStreak: Int = 0
    
    var winAllAlive: Bool = false
    
    var weatherUses: [Bool] = [Bool](repeating: false, count: Weather.allCases.count)
    var hexUses: [Bool] = [Bool](repeating: false, count: Hexes.allCases.count)
    
    var fightOneElement: Bool = false
    
    var dailyFightCounter: Int = 0
    var dailyWinCounter: Int = 0
    var dailyElementCounter: Int = 0
    
    var unlockedSkins: [String:Int] = [:]
    var missionCollected: [Bool] = [Bool](repeating: false, count: 11)
    var dailyCollected: [Bool] = [Bool](repeating: false, count: 4)
    
    var points: Int = 0
    
    /// Advances user progress by increasing win counters.
    /// - Parameters:
    ///   - winner: Indicates the winner
    ///   - fighters: The fighters used in the fight
    mutating func addWin(winner: Int, fighters: [Fighter]) {
        if winner == 1 {
            winCounter += 1
            dailyWinCounter += 1
            
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
    
    /// Checks if atleast one of the teams only consists of one element.
    /// - Parameters:
    ///   - teamA: Team of fighters
    ///   - teamB: Team of fighters
    mutating func checkTeams(teamA: [Fighter], teamB: [Fighter]) {
        var element: String = teamA[0].element.name
        var counter: Int = 1
        
        for index in 1 ..< teamA.count {
            if teamA[index].element.name != element {
                break
            } else {
                counter += 1
            }
        }
        
        if counter == teamA.count {
            fightOneElement = true
        } else {
            element = teamB[0].element.name
            counter = 1
            
            for index in 1 ..< teamB.count {
                if teamB[index].element.name != element {
                    break
                } else {
                    counter += 1
                }
            }
            
            if counter == teamB.count {
                fightOneElement = true
            }
        }
    }
    
    /// Returns element depending on day.
    /// - Returns: Returns daily element
    func getDailyElement() -> Element {
        var index: Int = Calendar.current.component(.month, from: lastDate) + Calendar.current.component(.weekday, from: lastDate) - 2
        index -= index/12 * 12
        
        return GlobalData.shared.elementArray[index]
    }
    
    /// Resets daily missions
    mutating func resetDaily() {
        if !Calendar.current.isDateInToday(lastDate) {
            dailyFightCounter = 0
            dailyWinCounter = 0
            dailyElementCounter = 0
            dailyCollected = [Bool](repeating: false, count: 3)
            
            lastDate = Date()
        }
    }
    
    /// Add up all weather effects that have been used once.
    /// - Returns: Returns number of used weather effects
    func getWeatherAmount() -> Int {
        var counter: Int = 0
        for weather in weatherUses {
            if weather {
                counter += 1
            }
        }
        
        return counter
    }
    
    /// Add up all hexes that have been used once.
    /// - Returns: Returns number of used hexes
    func getHexAmount() -> Int {
        var counter: Int = 0
        for hex in hexUses {
            if hex {
                counter += 1
            }
        }
        
        return counter
    }
    
    /// Unlocks a skin for a fighter.
    /// - Parameters:
    ///   - fighter: The owner of the skin
    ///   - index: The number of the skin
    mutating func unlockSkin(points: Int, fighter: String, index: Int) {
        self.points -= points
        unlockedSkins.updateValue(index, forKey: fighter)
    }
    
    mutating func completeAllMissions() {
        winStreak = 500
        fightCounter = 500
        winAllAlive = true
        weatherUses = [Bool](repeating: true, count: Weather.allCases.count)
        hexUses = [Bool](repeating: true, count: Hexes.allCases.count)
        fightOneElement = true
    }
    
    /// Collect reward in form of points from a daily quest.
    /// - Parameters:
    ///   - points: Reward in points
    ///   - index: Index of daily quest to mark as collected
    mutating func dailyCollect(points: Int, index: Int) {
        dailyCollected[index] = true
        
        self.points += 9000
        self.points = min(self.points, 9999999)
    }
    
    /// Collect reward  in form of points from a mission.
    /// - Parameters:
    ///   - points: Reward in points
    ///   - index: Index of daily quest to mark as collected
    mutating func missionCollect(points: Int, index: Int) {
        missionCollected[index] = true
        
        self.points += points
        self.points = min(self.points, 9999999)
    }
    
    /// Formats the number of points.
    /// - Returns: Returns formatted number of points
    func getFormattedPoints() -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal

        let number = NSNumber(value: points)
        let formattedValue = formatter.string(from: number)!
        return "\(formattedValue)"
    }
}
