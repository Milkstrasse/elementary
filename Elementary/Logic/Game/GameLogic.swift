//
//  GameLogic.swift
//  Elementary
//
//  Created by Janice Hablützel on 06.01.22.
//

/// This is the logic used to track which players are ready for different actions, like starting a game, starting a new round  or when they want to end a game prematurely.
struct GameLogic {
    private var readyPlayers: [Bool] = [false, false]
    var forfeited: [Bool] = [false, false]
    var tempSpells: [Int]
    
    let fullAmount: Int
    
    init(fullAmount: Int) {
        self.fullAmount = fullAmount
        tempSpells = [Int](repeating: -1, count: fullAmount)
    }
    
    /// Flags player as ready or not for starting a game, starting a new round or having a rematch.
    /// - Parameters:
    ///   - player: The id of the player
    ///   - ready: The ready status of the player
    mutating func setReady(player: Int, ready: Bool) {
        readyPlayers[player] = ready
    }
    
    mutating func useSpell(player: Int, fighter: Int, spell: Int) {
        tempSpells[fighter + player * fullAmount/2] = spell
    }
    
    mutating func removeSpell(player: Int, fighter: Int) {
        tempSpells[fighter + player * fullAmount/2] = -1
    }
    
    func spellHasBeenUsed(player: Int) -> Bool {
        var counter: Int = 0
        for index in player * fullAmount/2 ..< fullAmount/2 + player * fullAmount/2 {
            if tempSpells[index] > -1 {
                counter += 1
            }
        }
        
        return counter > 1
    }
    
    mutating func clearSpells() {
        tempSpells = [Int](repeating: -1, count: fullAmount)
    }
    
    /// Checks if both players are flagged as ready.
    /// - Returns: Return wether both players are flagged as ready
    func areBothReady() -> Bool {
        return readyPlayers[0] && readyPlayers[1]
    }
    
    func isPlayerReady(player: Player) -> Bool {
        var counter: Int = 0
        for index in player.id * fullAmount/2 ..< fullAmount/2 + player.id * fullAmount/2 {
            if tempSpells[index] > -1 {
                counter += 1
            }
        }
        
        for fighter in player.fighters {
            if fighter.currhp == 0 {
                counter += 1
            }
        }
        
        return counter == fullAmount/2
    }
    
    /// Stores which player wants to forfeit.
    /// - Parameter player: The id of the player
    mutating func forfeit(player: Int) {
        forfeited[player] = true
    }
}
