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
    
    let fighterCounts: [Int]
    
    init(topFighterCount: Int, bottomFighterCount: Int) {
        tempSpells = [Int](repeating: -1, count: topFighterCount + bottomFighterCount)
        fighterCounts = [topFighterCount, bottomFighterCount]
    }
    
    /// Flags player as ready or not for starting a game, starting a new round or having a rematch.
    /// - Parameters:
    ///   - player: The id of the player
    ///   - ready: The ready status of the player
    mutating func setReady(player: Int, ready: Bool) {
        readyPlayers[player] = ready
    }
    
    /// Stores a spell before chossing the target of a move.
    /// - Parameters:
    ///   - player: The id of the player
    ///   - fighter: The id of the fighter using the spell
    ///   - spell: The id of the spell
    mutating func useSpell(player: Int, fighter: Int, spell: Int) {
        tempSpells[fighter + player * fighterCounts[0]] = spell
    }
    
    /// Removes the spell after an undo.
    /// - Parameters:
    ///   - player: The id of the player
    ///   - fighter: The id of the fighter using the spell
    mutating func removeSpell(player: Int, fighter: Int) {
        tempSpells[fighter + player * fighterCounts[0]] = -1
    }
    
    /// Checks if any spells have been stored.
    /// - Parameter player: The id of the player
    /// - Returns: Returns if atleast one spell has been stored
    func spellHasBeenUsed(player: Int) -> Bool {
        var counter: Int = 0
        for index in player * fighterCounts[0] ..< fighterCounts[0] + player * fighterCounts[player] {
            if tempSpells[index] > -1 {
                counter += 1
            }
        }
        
        return counter > 1
    }
    
    /// Remove all stored spells.
    mutating func clearSpells() {
        tempSpells = [Int](repeating: -1, count: fighterCounts[0] + fighterCounts[1])
    }
    
    /// Checks if both players are flagged as ready.
    /// - Returns: Return wether both players are flagged as ready
    func areBothReady() -> Bool {
        return readyPlayers[0] && readyPlayers[1]
    }
    
    /// Stores which player wants to forfeit.
    /// - Parameter player: The id of the player
    mutating func forfeit(player: Int) {
        forfeited[player] = true
    }
}
