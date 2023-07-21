//
//  UserProgress.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.10.22.
//

import Foundation

/// Tracks progress of user with different stats.
class UserProgress: NSObject, Codable {
    var lastDate: Date = Date()
    
    @objc var fightCounter: Int = 0
    private var winCounter: Int = 0
    @objc var winStreak: Int = 0
    
    @objc var winAllAlive: Bool = false
    
    var weatherUses: [Bool] = [Bool](repeating: false, count: Weather.allCases.count)
    @objc var weatherCounter: Int = 0
    var hexUses: [Bool] = [Bool](repeating: false, count: Hexes.allCases.count)
    @objc var hexCounter: Int = 0
    var artifactsUses: [Bool] = [Bool](repeating: false, count: Artifacts.allCases.count)
    @objc var artifactCounter: Int = 0
    
    @objc var fightOneElement: Bool = false
    
    @objc var dailyFightCounter: Int = 0
    @objc var dailyWinCounter: Int = 0
    @objc var dailyElementWin: Bool = false
    @objc var dailyArtifactUsed: Bool = false
    
    private var unlockedOutfits: [String:[Int]] = [:]
    
    var questCollected: [Bool] = [Bool](repeating: false, count: 4)
    var milestoneCollected: [Bool] = [Bool](repeating: false, count: 10)
    
    var points: Int = 0
    
    /// Advances user progress by increasing win counters.
    /// - Parameters:
    ///   - winner: Indicates the winner
    ///   - fighters: The fighters used in the fight
    func addWin(winner: Int, fighters: [Fighter]) {
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
                        dailyElementWin = true
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
    func addFight() {
        resetDaily()
        
        dailyFightCounter += 1
        fightCounter += 1
    }
    
    /// Checks if atleast one of the teams only consists of one element and which artifacts have been used.
    /// - Parameters:
    ///   - teamA: Team of fighters
    ///   - teamB: Team of fighters
    func checkTeams(teamA: [Fighter], teamB: [Fighter]) {
        var element: String
        var counter: Int = 0
        
        if !teamA.isEmpty {
            element = teamA[0].element.name
            
            for fighter in teamA {
                if fighter.element.name == element {
                    counter += 1
                }
                
                if fighter.artifact.name != Artifacts.noArtifact.rawValue {
                    dailyArtifactUsed = true
                    
                    for (index, artifact) in Artifacts.allCases.enumerated() {
                        if artifact.rawValue == fighter.artifact.name {
                            updateArtifactUses(index: index)
                            break
                        }
                    }
                }
            }
            
            if counter == teamA.count {
                fightOneElement = true
            }
        }
        
        element = teamB[0].element.name
        counter = 0
        
        for fighter in teamB {
            if fighter.element.name == element {
                counter += 1
            }
            
            if fighter.artifact.name != Artifacts.noArtifact.rawValue {
                dailyArtifactUsed = true
                
                for (index, artifact) in Artifacts.allCases.enumerated() {
                    if artifact.rawValue == fighter.artifact.name {
                        updateArtifactUses(index: index)
                        break
                    }
                }
            }
        }
        
        if counter == teamB.count {
            fightOneElement = true
        }
    }
    
    /// Returns element depending on day.
    /// - Returns: Returns daily element
    func getDailyElement() -> Element {
        var index: Int = Calendar.current.component(.month, from: lastDate) + Calendar.current.component(.weekday, from: lastDate) - 2
        index -= index/GlobalData.shared.elementArray.count * GlobalData.shared.elementArray.count
        
        return GlobalData.shared.elementArray[index]
    }
    
    /// Resets daily missions
    func resetDaily() {
        if !Calendar.current.isDateInToday(lastDate) {
            dailyFightCounter = 0
            dailyWinCounter = 0
            dailyElementWin = false
            dailyArtifactUsed = false
            
            questCollected = [Bool](repeating: false, count: 4)
            
            lastDate = Date()
        }
    }
    
    func updateWeatherUses(index: Int) {
        weatherUses[index] = true
        
        weatherCounter = 0
        for weather in weatherUses {
            if weather {
                weatherCounter += 1
            }
        }
    }
    
    func updateHexUses(index: Int) {
        hexUses[index] = true
        
        hexCounter = 0
        for hex in hexUses {
            if hex {
                hexCounter += 1
            }
        }
    }
    
    func updateArtifactUses(index: Int) {
        artifactsUses[index] = true
        
        artifactCounter = 0
        for artifact in artifactsUses {
            if artifact {
                artifactCounter += 1
            }
        }
    }
    
    /// Unlocks a outfit for a fighter.
    /// - Parameters:
    ///   - fighter: The owner of the outfit
    ///   - index: The number of the outfit
    func unlockOutfit(points: Int, fighter: String, index: Int) {
        self.points -= points
        if unlockedOutfits[fighter] == nil {
            unlockedOutfits.updateValue([index], forKey: fighter)
        } else {
            unlockedOutfits[fighter]!.append(index)
        }
    }
    
    /// Checks if the outfit has been unlocked or not.
    /// - Parameters:
    ///   - fighter: The owner of the outfit
    ///   - index: The index of the outfit
    /// - Returns: Return wether the outfit has been unlocked or not
    func isOutfitUnlocked(fighter: String, index: Int) -> Bool {
        if index == 0 {
            return true
        }
        
        if unlockedOutfits[fighter] == nil {
            return false
        } else {
            return unlockedOutfits[fighter]!.contains(index)
        }
    }

    /// Collect reward  in form of points from a mission.
    func missionCollect(mission: inout Mission, index: Int) {
        self.points += mission.reward
        self.points = min(self.points, 9999999)
        
        if index < questCollected.count {
            questCollected[index] = true
        } else {
            milestoneCollected[index - questCollected.count] = true
        }
        
        mission.isClaimed = true
    }
    
    /// Formats the number of points.
    /// - Returns: Returns formatted number of points
    func getFormattedPoints() -> String {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal

        let number: NSNumber = NSNumber(value: points)
        let formattedValue: String = formatter.string(from: number)!
        return "\(formattedValue)"
    }
}
