//
//  GameLogic.swift
//  Witchery
//
//  Created by Janice Hablützel on 06.01.22.
//

/// This is the logic used to track which players are ready for different actions, like starting a game, starting a new round  or when they want to end a game prematurely.
struct GameLogic {
    private var readyPlayers: [Bool] = [false, false]
    var forfeited: [Bool] = [false, false]
    
    /// Flags player as ready or not for starting a game, starting a new round or having a rematch.
    /// - Parameters:
    ///   - player: The id of the player
    ///   - ready: The ready status of the player
    mutating func setReady(player: Int, ready: Bool) {
        readyPlayers[player] = ready
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
