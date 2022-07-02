//
//  BattleLog.swift
//  Witchery
//
//  Created by Janice Hablützel on 02.07.22.
//

/// Saves latest battle data into a file.
class BattleLog {
    static let shared: BattleLog = BattleLog()
    
    static let fileName: String = "lastBattle.txt"
    var battleLog: String = ""
    
    /// Generates an overview of all witches.
    /// - Parameters:
    ///   - player1Witches: The witches of player 1
    ///   - player2Witches: The witches of player 2
    func generatePlayerInfo(player1Witches: [Witch], player2Witches: [Witch]) {
        battleLog = "Player 1:\n"
        generateWitches(witches: player1Witches)
        
        battleLog += "\n"
        
        battleLog += "Player 2:\n"
        generateWitches(witches: player2Witches)
    }
    
    
    /// Generates an overview of all witches of a player.
    /// - Parameter witches: The witches of a player
    private func generateWitches(witches: [Witch]) {
        for witch in witches {
            generateWitchInfo(witch: witch)
            battleLog += "\n"
        }
    }
    
    /// Generates an overview of a single witch.
    /// - Parameter witch: The desired witch
    private func generateWitchInfo(witch: Witch) {
        battleLog += " - " + witch.name + ": "
        battleLog += "\(witch.currhp), \(witch.getModifiedBase().attack), \(witch.getModifiedBase().defense), \(witch.getModifiedBase().agility), \(witch.getModifiedBase().precision), \(witch.getModifiedBase().resistance)"
        battleLog += " + " + witch.getArtifact().name
        
        if !witch.hexes.isEmpty {
            battleLog += "\n"
            for hex in witch.hexes {
                battleLog += "#" + hex.name + " "
            }
        }
    }
    
    /// Adds the content of a battle round and some background information.
    /// - Parameters:
    ///   - log: The text containing the battle round
    ///   - currentWitch1: The current witch of player 1
    ///   - currentWitch2: The current witch of player 2
    func addBattleLog(log: [String], currentWitch1: Witch, currentWitch2: Witch, weather: Hex?) {
        battleLog += "\n"
        
        for line in log {
            battleLog += line
            battleLog += "\n"
        }
        
        battleLog += "\n"
        battleLog += "weather: " + (weather?.name ?? "-")
        battleLog += "\n"
        
        battleLog += "\n"
        generateWitchInfo(witch: currentWitch1)
        battleLog += "\n"
        generateWitchInfo(witch: currentWitch2)
        battleLog += "\n"
    }
}
