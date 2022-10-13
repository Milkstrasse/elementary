//
//  BattleLog.swift
//  Elementary
//
//  Created by Janice Hablützel on 02.07.22.
//

/// Saves latest battle data into a file.
class BattleLog {
    static let shared: BattleLog = BattleLog()
    
    static let fileName: String = "lastBattle.txt"
    var battleLog: String = ""
    
    /// Generates an overview of all fighters.
    /// - Parameters:
    ///   - player1Fighters: The fighters of player 1
    ///   - player2Fighters: The fighters of player 2
    func generatePlayerInfo(player1Fighters: [Fighter], player2Fighters: [Fighter]) {
        battleLog = "Player 1:\n"
        generateFighters(fighters: player1Fighters)
        
        battleLog += "\n"
        
        battleLog += "Player 2:\n"
        generateFighters(fighters: player2Fighters)
    }
    
    
    /// Generates an overview of all fighters of a player.
    /// - Parameter fighters: The fighters of a player
    private func generateFighters(fighters: [Fighter]) {
        for fighter in fighters {
            generateFighterInfo(fighter: fighter)
            battleLog += "\n"
        }
    }
    
    /// Generates an overview of a single fighter.
    /// - Parameter fighter: The desired fighter
    private func generateFighterInfo(fighter: Fighter) {
        battleLog += " - " + fighter.name + ": "
        battleLog += "\(fighter.currhp)/\(fighter.getModifiedBase().health), \(fighter.getModifiedBase().attack), \(fighter.getModifiedBase().defense), \(fighter.getModifiedBase().agility), \(fighter.getModifiedBase().precision), \(fighter.getModifiedBase().resistance)"
        battleLog += " + " + Localization.shared.getTranslation(key: fighter.getArtifact().name)
        
        if !fighter.hexes.isEmpty {
            battleLog += "\n"
            for hex in fighter.hexes {
                battleLog += "#" + Localization.shared.getTranslation(key: hex.name) + " "
            }
        }
    }
    
    /// Adds the content of a battle round and some background information.
    /// - Parameters:
    ///   - log: The text containing the battle round
    ///   - currentFighter1: The current fighter of player 1
    ///   - currentFighter2: The current fighter of player 2
    func addBattleLog(log: [String], currentFighter1: Fighter, currentFighter2: Fighter, weather: Hex?) {
        battleLog += "\n"
        
        for line in log {
            battleLog += line
            battleLog += "\n"
        }
        
        battleLog += "\n"
        battleLog += Localization.shared.getTranslation(key: weather?.name ?? "clearSkies")
        battleLog += "\n"
        
        battleLog += "\n"
        generateFighterInfo(fighter: currentFighter1)
        battleLog += "\n"
        generateFighterInfo(fighter: currentFighter2)
        battleLog += "\n"
    }
}
