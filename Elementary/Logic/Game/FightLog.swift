//
//  FightLog.swift
//  Elementary
//
//  Created by Janice Hablützel on 02.07.22.
//

/// Saves latest fight data into a file.
class FightLog {
    static let shared: FightLog = FightLog()
    
    static let fileName: String = "lastFight.txt"
    var fightLog: String = ""
    
    /// Generates an overview of all fighters.
    /// - Parameters:
    ///   - player1Fighters: The fighters of player 1
    ///   - player2Fighters: The fighters of player 2
    func generatePlayerInfo(player1Fighters: [Fighter], player2Fighters: [Fighter]) {
        fightLog = "Player 1:\n"
        generateFighters(fighters: player1Fighters)
        
        fightLog += "\n"
        
        fightLog += "Player 2:\n"
        generateFighters(fighters: player2Fighters)
    }
    
    
    /// Generates an overview of all fighters of a player.
    /// - Parameter fighters: The fighters of a player
    private func generateFighters(fighters: [Fighter]) {
        for fighter in fighters {
            generateFighterInfo(fighter: fighter)
            fightLog += "\n"
        }
    }
    
    /// Generates an overview of a single fighter.
    /// - Parameter fighter: The desired fighter
    private func generateFighterInfo(fighter: Fighter) {
        fightLog += " - " + fighter.name + ": "
        fightLog += "\(fighter.currhp)/\(fighter.getModifiedBase().health), \(fighter.getModifiedBase().attack), \(fighter.getModifiedBase().defense), \(fighter.getModifiedBase().agility), \(fighter.getModifiedBase().precision), \(fighter.getModifiedBase().resistance)"
        fightLog += " + " + Localization.shared.getTranslation(key: fighter.getArtifact().name)
        
        if !fighter.hexes.isEmpty {
            fightLog += "\n"
            for hex in fighter.hexes {
                fightLog += "#" + Localization.shared.getTranslation(key: hex.name) + " "
            }
        }
    }
    
    /// Adds the content of a fight round and some background information.
    /// - Parameters:
    ///   - log: The text containing the fight round
    ///   - currentFighter1: The current fighter of player 1
    ///   - currentFighter2: The current fighter of player 2
    func addFightLog(log: [String], currentFighter1: Fighter, currentFighter2: Fighter, weather: Hex?) {
        fightLog += "\n"
        
        for line in log {
            fightLog += line
            fightLog += "\n"
        }
        
        fightLog += "\n"
        fightLog += Localization.shared.getTranslation(key: weather?.name ?? "clearSkies")
        fightLog += "\n"
        
        fightLog += "\n"
        generateFighterInfo(fighter: currentFighter1)
        fightLog += "\n"
        generateFighterInfo(fighter: currentFighter2)
        fightLog += "\n"
    }
}
