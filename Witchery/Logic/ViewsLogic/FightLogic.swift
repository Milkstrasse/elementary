//
//  FightLogic.swift
//  Witchery
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

/// This is the main logic of the game. Stores all participating witches, determines the turn order and the amount of turns needed in each round, swaps witches , determines when the game is over and who has won.
class FightLogic: ObservableObject {
    let hasCPUPlayer: Bool
    
    @Published var currentWitch: [Int] = [0, 0]
    var hasToSwap: [Bool] = [false, false]
    
    @Published var witches: [[Witch]] = [[], []]
    
    var gameLogic: GameLogic = GameLogic()
    
    var usedMoves: [[Move]] = [[], []]
    var playerStack: [(player: Int, index: Int)] = []
    
    @Published var battling: Bool = false
    @Published var battleLog: String = "let the fight begin"
    @Published var gameOver: Bool = false
    
    @Published var weather: Hex?
    
    init(leftWitches: [Witch], rightWitches: [Witch], hasCPUPlayer: Bool = false) {
        self.hasCPUPlayer = hasCPUPlayer

        witches[0] = leftWitches
        witches[1] = rightWitches
        
        if getWitch(player: 0).artifact.name == Artifacts.mask.rawValue {
            getWitch(player: 1).applyHex(hex: Hexes.attackDrop.getHex(duration: 4))
        }
        if getWitch(player: 1).artifact.name == Artifacts.mask.rawValue {
            getWitch(player: 0).applyHex(hex: Hexes.attackDrop.getHex(duration: 4))
        }
        
        for witch in witches[0] {
            if witch.artifact.name == Artifacts.corset.rawValue {
                witch.applyHex(hex: Hexes.restricted.getHex(duration: -1))
            }
        }
        for witch in witches[1] {
            if witch.artifact.name == Artifacts.corset.rawValue {
                witch.applyHex(hex: Hexes.restricted.getHex(duration: -1))
            }
        }
    }
    
    /// Checks if there are enough witches on both sides.
    /// - Returns: Returns whether this fight has enough witches on both sides
    func isValid() -> Bool {
        return (!witches[0].isEmpty && witches[0].count <= 4) && (!witches[1].isEmpty && witches[1].count <= 4)
    }
    
    /// Returns current witch of player.
    /// - Parameter player: The index of the  player
    /// - Returns: The current witch of the player
    func getWitch(player: Int) -> Witch {
        return witches[player][currentWitch[player]]
    }
    
    /// Player declares which move they want to make in the following round of the fight.
    /// - Parameters:
    ///   - player: The index of the player who makes the move
    ///   - move: The action the player wants to make
    /// - Returns: Returns whether a round of fighting will begin or the player has to or is able to do another action
    func makeMove(player: Int, move: Move) -> Bool {
        //CPU makes its move
        if hasCPUPlayer {
            if hasToSwap[0] {
                swapWitches(player: 0, target: CPULogic.shared.getTarget(currentWitch: currentWitch[0], witches: witches[0], enemyElement: getWitch(player: 1).element))
            }
            
            var rndmMove: Move? = CPULogic.shared.getMove(witch: getWitch(player: 0), enemy: getWitch(player: 1), weather: weather, isAbleToSwitch: isAbleToSwap(player: 0))
            
            if rndmMove == nil { //CPU wants to switch
                rndmMove = Move(source: getWitch(player: 0), target: CPULogic.shared.getTarget(currentWitch: currentWitch[0], witches: witches[0], enemyElement: getWitch(player: 1).element), spell: Spell())
            }
            
            usedMoves[0].insert(rndmMove!, at: 0)
        }
        
        if move.spell.useCounter + getWitch(player: player).manaUse > move.spell.uses {
            return false //spell cost is to high, witch cannot use this spell
        } else if move.target > -1 {
            if witches[player][move.target].currhp == 0 {
                return false //witch cannot switch with fainted witches
            }
        }
        
        if hasToSwap[player] { //witch either fainted or has special artifact to swap
            if !getWitch(player: player).hasHex(hexName: Hexes.chained.rawValue) || getWitch(player: player).currhp == 0 {
                if move.target > -1 {
                    swapWitches(player: player, target: move.target)
                }
                
                return false //action is free, new witch can make a move
            }
        }
        
        //marks player as ready
        gameLogic.setReady(player: player, ready: true)
        
        //adds move into the used moves collection
        if move.target < 0 { //move can be influenced by move changing hexes
            if getWitch(player: player).hasHex(hexName: Hexes.confused.rawValue) {
                let randomMove: Move = Move(source: move.source, spell: getWitch(player: player).spells[Int.random(in: 0 ..< getWitch(player: player).spells.count)])
                usedMoves[player].insert(randomMove, at: 0)
            } else if !usedMoves[player].isEmpty && getWitch(player: player).hasHex(hexName: Hexes.restricted.rawValue) {
                if usedMoves[player][0].target < 0 {
                    usedMoves[player].insert(usedMoves[player][0], at: 0)
                } else { //last move was a swap which can't be locked in
                    usedMoves[player].insert(move, at: 0)
                }
            } else { //no moves have been made yet to be locked in
                usedMoves[player].insert(move, at: 0)
            }
        } else { //swapping move, can't be influenced by move changing hexes
            usedMoves[player].insert(move, at: 0)
        }
        
        //fight begins
        if gameLogic.areBothReady() || hasCPUPlayer {
            battling = true
            battleLog = Localization.shared.getTranslation(key: "loading")
            
            //increase useCounter of spells
            usedMoves[0][0].useSpell(amount: getWitch(player: 0).manaUse)
            usedMoves[1][0].useSpell(amount: getWitch(player: 1).manaUse)
            
            //reset hasToSwap marker to prevent free swaps
            hasToSwap[0] = false
            hasToSwap[1] = false
            
            //decrease counter of all hexes and remove if duration reached 0
            if weather != nil {
                weather!.duration -= 1
                
                if weather!.duration == 0 {
                    weather = nil
                }
            }
            
            for hex in getWitch(player: 0).hexes {
                hex.duration -= 1
                
                if hex.duration == 0 {
                    getWitch(player: 0).removeHex(hex: hex)
                }
            }
            for hex in getWitch(player: 1).hexes {
                hex.duration -= 1
                
                if hex.duration == 0 {
                    getWitch(player: 1).removeHex(hex: hex)
                }
            }
            
            //adds faster player to playerStack
            addMoveTurn(player: getFasterPlayer())
            
            var endRound: Bool = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                var turns: Int = 0
                //amount of turns first player needs to do their action
                let firstTurns: Int = playerStack.count
                
                //processes all actions on playerStack
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    let currentPlayer: Int = playerStack[0].player;
                    turns += 1
                    
                    if turns == 1 {
                        battleLog = ""
                    }
                    
                    startTurn(player: currentPlayer)
                    playerStack.removeFirst()
                    
                    if playerStack.isEmpty && !endRound { //adds new action if neccessary during the fight
                        endRound = addTurns(currentPlayer: currentPlayer, turns: turns, firstTurns: firstTurns)
                    }
                    
                    if playerStack.isEmpty {
                        timer.invalidate()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            gameLogic.setReady(player: 0, ready: false)
                            gameLogic.setReady(player: 1, ready: false)
                            //players are now able to choose their moves again
                            
                            print(battleLog)
                            
                            battling = false
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    /// Retracts the move a player has made before a round of fighting starts.
    /// - Parameter player: The index of the player
    func undoMove(player: Int) {
        gameLogic.setReady(player: player, ready: false)
        usedMoves[player].removeFirst()
    }
    
    /// Determines which player has priority.
    /// - Returns: Returns the index of the player with priority
    func getFasterPlayer() -> Int {
        //move has a target -> player wants to switch whis is a priority move
        if usedMoves[0][0].target > -1 {
            return 0
        } else if usedMoves[1][0].target > -1 {
            return 1
        }
        
        //shielding moves have priority
        if usedMoves[0][0].spell.type == "shield" {
            return 0
        } else if usedMoves[1][0].spell.type == "shield" {
            return 1
        }
        
        var fasterPlayer: Int
        
        //determine priority with using the agility stat of the witches
        if getWitch(player: 0).base.agility > getWitch(player: 1).base.agility {
            fasterPlayer = 0
        } else if getWitch(player: 1).base.agility > getWitch(player: 0).base.agility {
            fasterPlayer = 1
        } else if Bool.random() { //agility stat tie -> random player has priority
            fasterPlayer = 0
        } else {
            fasterPlayer = 1
        }
        
        return fasterPlayer
    }
    
    /// Adds turns to the current round of fighting.
    /// - Parameters:
    ///   - currentPlayer: The index of player whose turn it is
    ///   - turns: The amount of turns in the current round
    ///   - firstTurns: The amount of turn the first player needed
    /// - Returns: Returns wether all necessary turns were determined or a future analysis is needed
    func addTurns(currentPlayer: Int, turns: Int, firstTurns: Int) -> Bool {
        if getWitch(player: 1).currhp == 0 {
            playerStack.insert((player: 1, index: 0), at: 0) //add turn to display faint message
            
            if getWitch(player: 0).currhp == 0 {
                playerStack.insert((player: 0, index: 0), at: 0) //add turn to display faint message
                return true //both witches have fainted, round is over
            }
            
            if currentPlayer == 0 { //witch fainted before they made their move
                addHexTurns(player: 0)
            } else {
                if turns != firstTurns { //both players made their move
                    addHexTurns(player: 0)
                } else {
                    addMoveTurn(player: 0)
                }
            }
            
            return true //no further turns needed
        } else if getWitch(player: 0).currhp == 0 {
            playerStack.insert((player: 0, index: 0), at: 0) //add turn to display faint message
            
            if getWitch(player: 1).currhp == 0 {
                playerStack.insert((player: 1, index: 0), at: 0) //add turn to display faint message
                return true //both witches have fainted, round is over
            }
            
            if currentPlayer == 1 { //witch fainted before they made their move
                addHexTurns(player: 1)
            } else {
                if turns != firstTurns { //both players made their move
                    addHexTurns(player: 1)
                } else {
                    addMoveTurn(player: 1)
                }
            }
            
            return true //no further turns needed
        }
        
        if turns == firstTurns { //other player has not made their move yet
            var oppositePlayer: Int = 0
            if currentPlayer == 0 {
                oppositePlayer = 1
            }
            
            addMoveTurn(player: oppositePlayer)
            return false
        } else { //both players made their move
            addHexTurns(player: 0)
            addHexTurns(player: 1)
        }
        
        return true //no further turns needed
    }
    
    /// Adds turns depending on the move of the player to the current round of fighting.
    /// - Parameter player: The index of the player
    func addMoveTurn(player: Int) {
        if !usedMoves[player][0].spell.spells.isEmpty {
            for index in usedMoves[player][0].spell.spells.indices.reversed() {
                playerStack.insert((player: player, index: index + 1), at: 0)
            }
            
            playerStack.insert((player: player, index: 0), at: 0)
        } else { //this is a swap not a spell
            playerStack.insert((player: player, index: 0), at: 0)
        }
    }
    
    /// Adds turns depending on the hexes of the player to the current round of fighting.
    /// - Parameter player: The index of the player
    func addHexTurns(player: Int) {
        if !getWitch(player: player).hexes.isEmpty {
            for index in getWitch(player: player).hexes.indices {
                let hex: Hex = getWitch(player: player).hexes[index]
                
                if hex.damageAmount != 0 && hex.name != Hexes.bombed.rawValue {
                    playerStack.insert((player: player, index: -1 - index), at: 0)
                } else if hex.name == Hexes.bombed.rawValue && hex.duration == 1 {
                    playerStack.insert((player: player, index: -1 - index), at: 0)
                }
            }
        }
    }
    
    /// Starts the turn of a player.
    /// - Parameter player: The id of the player
    func startTurn(player: Int) {
        let attacker: Witch = getWitch(player: player)
        
        if usedMoves[player][0].target > -1 {
            if attacker.hasHex(hexName: Hexes.chained.rawValue) {
                battleLog += Localization.shared.getTranslation(key: "swapFailed", params: [attacker.name]) + "\n"
                return
            }
            
            battleLog += swapWitches(player: player, target: usedMoves[player][0].target)
        } else {
            battleLog += TurnLogic.shared.startTurn(player: player, fightLogic: self)
        }
    }
    
    /// Swaps two witches.
    /// - Parameters:
    ///   - player: The id of the player
    ///   - target: The index of the targeted witch
    /// - Returns: Returns the description of what occured during the swap
    func swapWitches(player: Int, target: Int) -> String {
        if witches[player][target].currhp == 0 {
            return ""
        }
        
        hasToSwap[player] = false //flag no longer necessary
        
        var text: String
        var applyHex: Bool = false
        
        if getWitch(player: player).artifact.name == Artifacts.lastWill.rawValue {
            applyHex = true
        } else if getWitch(player: player).artifact.name == Artifacts.grimoire.rawValue {
            for hex in getWitch(player: player).hexes {
                getWitch(player: player).removeHex(hex: hex)
            }
        }
        
        text = Localization.shared.getTranslation(key: "swapWith", params: [getWitch(player: player).name, witches[player][target].name]) + "\n"
        currentWitch[player] = target
        
        if applyHex {
            getWitch(player: player).applyHex(hex: Hexes.blessed.getHex(duration: 4))
        }
        
        var oppositePlayer: Int = 0
        if player == 0 {
            oppositePlayer = 1
        }
        if getWitch(player: oppositePlayer).artifact.name == Artifacts.mask.rawValue {
            if getWitch(player: player).applyHex(hex: Hexes.attackDrop.getHex(duration: 4)) {
                text += Localization.shared.getTranslation(key: "statDecreased", params: [getWitch(player: player).name, "attack"]) + "\n"
            }
        }
                                                                                
        return text
                                                                                
    }
    
    /// Checks if witch can swap within their team.
    /// - Parameter player: The id of the player
    /// - Returns: Returns whether the witch can swap in their team
    func isAbleToSwap(player: Int) -> Bool {
        var counter: Int = 0
        for witch in witches[player] {
            if witch.currhp > 0 {
                counter += 1
            }
        }
        
        if counter >= 2 { //enough witches are alive to make a swap
            return true
        } else {
            return false
        }
    }
    
    /// Checks if game is over.
    /// - Returns: Returns whether one of the teams only consists of fainted witches
    func isGameOver() -> Bool {
        var counter: Int = 0
        for witch in witches[0] {
            if witch.currhp > 0 {
                counter += 1
            }
        }
        
        if counter == 0 { //all witches in team have fainted -> unable to fight
            return true
        }
        
        for witch in witches[1] {
            if witch.currhp > 0 {
                return false //witch able to fight was found, both teams are able to fight
            }
        }
        
        return true //all witches in team have fainted -> unable to fight
    }
    
    /// Ends the game with a forfeit.
    /// - Parameter player: The id of the player
    func forfeit(player: Int) {
        gameLogic.forfeit(player: player)
    }
    
    /// Determines the winner of the game. Currently no draws possible.
    /// - Returns: Returns the id of the winning player
    func getWinner() -> Int {
        //player who has forfeited loses automatically
        if gameLogic.forfeited[0] {
            return 1
        } else if gameLogic.forfeited[1] {
            return 0
        }
        
        //if one player has alive witches other autmatically loses
        for witch in witches[0] {
            if witch.currhp > 0 {
                return 0
            }
        }
        
        return 1
    }
}
