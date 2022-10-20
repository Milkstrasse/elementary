//
//  PlayerProgress.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.10.22.
//

struct PlayerProgress: Codable {
    var battleCounter: Int = 0
    private var winCounter: Int = 0
    var winStreak: Int = 0
    
    var fighterWins: Dictionary<String, Int> = [:]
    
    mutating func addWin(winner: Int, fighters: [Fighter]) {
        if winner == 1 {
            winCounter += 1
            
            if winCounter > winStreak {
                winStreak = winCounter
            }
            
            for fighter in fighters {
                if let counter = fighterWins[fighter.name] {
                    fighterWins.updateValue(min(counter + 1, 25), forKey: fighter.name)
                } else {
                    fighterWins.updateValue(1, forKey: fighter.name)
                }
            }
        } else {
            winCounter = 0
        }
    }
}
