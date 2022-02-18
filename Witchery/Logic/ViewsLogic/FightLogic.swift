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
    
    let players: [Player]
    
    var gameLogic: GameLogic = GameLogic()
    
    var playerStack: [(player: Player, index: Int)] = []
    
    @Published var battling: Bool = false
    @Published var battleLog: String
    @Published var gameOver: Bool = false
    
    @Published var weather: Hex?
    
    /// Creates the logic used for a fight.
    /// - Parameters:
    ///   - players: The player fighting against each other
    ///   - hasCPUPlayer: If one of the players is the CPU
    init(players: [Player], hasCPUPlayer: Bool = false) {
        self.hasCPUPlayer = hasCPUPlayer

        self.players = players
        
        //mirror artifact
        if players[0].getCurrentWitch().getArtifact().name == Artifacts.mirror.rawValue {
            players[0].getCurrentWitch().overrideArtifact(artifact: players[1].getCurrentWitch().getArtifact())
        }
        if players[1].getCurrentWitch().getArtifact().name == Artifacts.mirror.rawValue {
            players[1].getCurrentWitch().overrideArtifact(artifact: players[0].getCurrentWitch().getArtifact())
        }
        
        //apply effect of artifact on "entering"
        if players[0].getCurrentWitch().getArtifact().name == Artifacts.mask.rawValue {
            players[1].getCurrentWitch().applyHex(hex: Hexes.attackDrop.getHex())
        }
        if players[1].getCurrentWitch().getArtifact().name == Artifacts.mask.rawValue {
            players[0].getCurrentWitch().applyHex(hex: Hexes.attackDrop.getHex())
        }
        
        battleLog = "let the fight begin"
    }
    
    /// Checks if there are enough witches on both sides.
    /// - Returns: Returns whether this fight has enough witches on both sides
    func isValid() -> Bool {
        return (!players[0].witches.isEmpty && players[0].witches.count <= 4) && (!players[1].witches.isEmpty && players[1].witches.count <= 4)
    }
    
    /// Player declares which move they want to make in the following round of the fight.
    /// - Parameters:
    ///   - player: The index of the player who makes the move
    ///   - move: The action the player wants to make
    /// - Returns: Returns whether a round of fighting will begin or the player has to or is able to do another action
    func makeMove(player: Player, move: Move) -> Bool {
        //CPU makes its move
        if hasCPUPlayer {
            if players[0].hasToSwap {
                swapWitches(player: players[0], target: CPULogic.shared.getTarget(currentWitch: players[0].currentWitchId, witches: players[0].witches, enemyElement: players[1].getCurrentWitch().getElement()))
            }
            
            var rndmMove: Move? = CPULogic.shared.getMove(witch: players[0].getCurrentWitch(), target: players[1].getCurrentWitch(), weather: weather, isAbleToSwitch: isAbleToSwap(player: players[0]), lastMove: players[0].usedMoves.first)
            
            if rndmMove == nil { //CPU wants to switch
                rndmMove = Move(source: players[0].getCurrentWitch(), target: CPULogic.shared.getTarget(currentWitch: players[0].currentWitchId, witches: players[0].witches, enemyElement: players[1].getCurrentWitch().getElement()), spell: Spell())
            }
            
            players[0].usedMoves.insert(rndmMove!, at: 0)
        }
        
        if move.spell.useCounter + player.getCurrentWitch().manaUse > move.spell.uses {
            return false //spell cost is to high, witch cannot use this spell
        } else if move.target > -1 {
            if player.witches[move.target].currhp == 0 {
                return false //witch cannot switch with fainted witches
            }
        }
        
        if player.hasToSwap { //witch either fainted or has special artifact to swap
            if !player.getCurrentWitch().hasHex(hexName: Hexes.chained.rawValue) || player.getCurrentWitch().currhp == 0 {
                if move.target > -1 {
                    swapWitches(player: player, target: move.target)
                }
                
                return false //action is free, new witch can make a move
            }
        }
        
        //marks player as ready
        gameLogic.setReady(player: player.id, ready: true)
        
        //adds move into the used moves collection
        if move.target < 0 { //move can be influenced by move changing hexes
            if !player.usedMoves.isEmpty && player.getCurrentWitch().hasHex(hexName: Hexes.restricted.rawValue) {
                if player.usedMoves[0].target < 0 {
                    player.usedMoves.insert(player.usedMoves[0], at: 0)
                } else { //last move was a swap which can't be locked in
                    player.usedMoves.insert(move, at: 0)
                }
            } else if !player.usedMoves.isEmpty && player.getCurrentWitch().getArtifact().name == Artifacts.corset.rawValue {
                if player.usedMoves[0].target < 0 {
                    player.usedMoves.insert(player.usedMoves[0], at: 0)
                } else { //last move was a swap which can't be locked in
                    player.usedMoves.insert(move, at: 0)
                }
            } else if player.getCurrentWitch().hasHex(hexName: Hexes.confused.rawValue) {
                let randomMove: Move = Move(source: player.getCurrentWitch(), spell: player.getCurrentWitch().spells[Int.random(in: 0 ..< player.getCurrentWitch().spells.count)])
                player.usedMoves.insert(randomMove, at: 0)
            } else {
                player.usedMoves.insert(move, at: 0)
            }
        } else { //swapping move, can't be influenced by move changing hexes
            player.usedMoves.insert(move, at: 0)
        }
        
        //fight begins
        if gameLogic.areBothReady() || hasCPUPlayer {
            battling = true
            battleLog = Localization.shared.getTranslation(key: "loading")
            
            //increase useCounter of spells
            players[0].usedMoves[0].useSpell(amount: players[0].getCurrentWitch().manaUse)
            players[1].usedMoves[0].useSpell(amount: players[1].getCurrentWitch().manaUse)
            
            //reset hasToSwap marker to prevent free swaps
            players[0].hasToSwap = false
            players[1].hasToSwap = false
            
            //adds faster player to playerStack
            addMoveTurn(player: players[getFasterPlayer()])
            
            var endRound: Bool = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                var turns: Int = 0
                //amount of turns first player needs to do their action
                let firstTurns: Int = playerStack.count
                
                //processes all actions on playerStack
                Timer.scheduledTimer(withTimeInterval: GlobalData.shared.getTextSpeed() , repeats: true) { timer in
                    let currentPlayer: Player = playerStack[0].player;
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
                        
                        //decrease counter of all hexes and remove if duration reached 0
                        if weather != nil {
                            weather!.duration -= 1
                            
                            if weather!.duration == 0 {
                                weather = nil
                            }
                        }
                        
                        for hex in players[0].getCurrentWitch().hexes {
                            hex.duration -= 1
                            
                            if hex.duration == 0 {
                                players[0].getCurrentWitch().removeHex(hex: hex)
                            }
                        }
                        for hex in players[1].getCurrentWitch().hexes {
                            hex.duration -= 1
                            
                            if hex.duration == 0 {
                                players[1].getCurrentWitch().removeHex(hex: hex)
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            AudioPlayer.shared.playConfirmSound()
                            
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
    func undoMove(player: Player) {
        gameLogic.setReady(player: player.id, ready: false)
        player.usedMoves.removeFirst()
    }
    
    /// Determines which player has priority.
    /// - Returns: Returns the index of the player with priority
    func getFasterPlayer() -> Int {
        //move has a target -> player wants to switch whis is a priority move
        if players[0].usedMoves[0].target > -1 {
            return 0
        } else if players[1].usedMoves[0].target > -1 {
            return 1
        }
        
        //priority move goes first
        if players[0].usedMoves[0].spell.priority > players[1].usedMoves[0].spell.priority {
            return 0
        } else if players[0].usedMoves[0].spell.priority < players[1].usedMoves[0].spell.priority {
            return 1
        }
        
        //determine priority with using the agility stat of the witches
        if players[0].getCurrentWitch().getModifiedBase().agility > players[1].getCurrentWitch().getModifiedBase().agility {
            return weather?.name == Weather.fullMoon.rawValue ? 1 : 0
        } else if players[1].getCurrentWitch().getModifiedBase().agility > players[0].getCurrentWitch().getModifiedBase().agility {
            return weather?.name == Weather.fullMoon.rawValue ? 0 : 1
        } else { //agility stat tie -> random player has priority
            return Int.random(in: 0 ... 1)
        }
    }
    
    /// Adds turns to the current round of fighting.
    /// - Parameters:
    ///   - currentPlayer: The index of player whose turn it is
    ///   - turns: The amount of turns in the current round
    ///   - firstTurns: The amount of turn the first player needed
    /// - Returns: Returns wether all necessary turns were determined or a future analysis is needed
    func addTurns(currentPlayer: Player, turns: Int, firstTurns: Int) -> Bool {
        if players[1].getCurrentWitch().currhp == 0 {
            playerStack.insert((player: players[1], index: 0), at: 0) //add turn to display faint message
            
            if players[0].getCurrentWitch().currhp == 0 {
                playerStack.insert((player: players[0], index: 0), at: 0) //add turn to display faint message
                return true //both witches have fainted, round is over
            }
            
            if currentPlayer.id == 0 { //witch fainted before they made their move
                addHexTurns(player: players[0])
            } else {
                if turns != firstTurns { //both players made their move
                    addHexTurns(player: players[0])
                } else {
                    addMoveTurn(player: players[0])
                }
            }
            
            return true //no further turns needed
        } else if players[0].getCurrentWitch().currhp == 0 {
            playerStack.insert((player: players[0], index: 0), at: 0) //add turn to display faint message
            
            if players[1].getCurrentWitch().currhp == 0 {
                playerStack.insert((player: players[1], index: 0), at: 0) //add turn to display faint message
                return true //both witches have fainted, round is over
            }
            
            if currentPlayer.id == 1 { //witch fainted before they made their move
                addHexTurns(player: players[1])
            } else {
                if turns != firstTurns { //both players made their move
                    addHexTurns(player: players[1])
                } else {
                    addMoveTurn(player: players[1])
                }
            }
            
            return true //no further turns needed
        }
        
        if turns == firstTurns { //other player has not made their move yet
            var oppositePlayer: Player = players[0]
            if currentPlayer.id == 0 {
                oppositePlayer = players[1]
            }
            
            addMoveTurn(player: oppositePlayer)
            return false
        } else { //both players made their move
            addHexTurns(player: players[0])
            addHexTurns(player: players[1])
        }
        
        return true //no further turns needed
    }
    
    /// Adds turns depending on the move of the player to the current round of fighting.
    /// - Parameter player: The index of the player
    func addMoveTurn(player: Player) {
        if player.usedMoves[0].spell.typeID == 9 { //player wants to copy enemy's move
            var oppositePlayer: Player = players[0]
            if player.id == 0 {
                oppositePlayer = players[1]
            }
            
            if players[oppositePlayer.id].usedMoves[0].target < 0 {
                player.usedMoves[0] = players[oppositePlayer.id].usedMoves[0]
            }
        }
        
        if player.usedMoves[0].target < 0 {
            for index in player.usedMoves[0].spell.spells.indices.reversed() {
                playerStack.insert((player: player, index: index + 1), at: 0)
            }
            
            playerStack.insert((player: player, index: 0), at: 0)
        } else { //this is a swap not a spell
            playerStack.insert((player: player, index: 0), at: 0)
        }
    }
    
    /// Adds turns depending on the hexes of the player to the current round of fighting.
    /// - Parameter player: The index of the player
    func addHexTurns(player: Player) {
        if !player.getCurrentWitch().hexes.isEmpty {
            for index in player.getCurrentWitch().hexes.indices {
                let hex: Hex = player.getCurrentWitch().hexes[index]
                
                if hex.damageAmount != 0 && hex.name != Hexes.bombed.rawValue {
                    playerStack.insert((player: player, index: -1 - index), at: 0)
                } else if hex.name == Hexes.bombed.rawValue && hex.duration == 1 {
                    playerStack.insert((player: player, index: -1 - index), at: 0)
                }
            }
        }
        
        if player.getCurrentWitch().getArtifact().name == Artifacts.cornucopia.rawValue {
            playerStack.insert((player: player, index: -10), at: 0)
        }
    }
    
    /// Starts the turn of a player.
    /// - Parameter player: The player
    func startTurn(player: Player) {
        let attacker: Witch = player.getCurrentWitch()
        
        if player.usedMoves[0].target > -1 {
            if attacker.hasHex(hexName: Hexes.chained.rawValue) {
                battleLog += Localization.shared.getTranslation(key: "swapFailed", params: [attacker.name]) + "\n"
                return
            }
            
            battleLog += swapWitches(player: player, target: player.usedMoves[0].target)
        } else {
            battleLog += TurnLogic.shared.startTurn(player: player, fightLogic: self)
        }
    }
    
    /// Swaps two witches.
    /// - Parameters:
    ///   - player: The player
    ///   - target: The index of the targeted witch
    /// - Returns: Returns the description of what occured during the swap
    func swapWitches(player: Player, target: Int) -> String {
        if player.witches[target].currhp == 0 {
            return ""
        }
        
        player.hasToSwap = false //flag no longer necessary
        
        var text: String
        var applyHex: Bool = false
        
        if player.getCurrentWitch().getArtifact().name == Artifacts.lastWill.rawValue {
            applyHex = true
        } else if player.getCurrentWitch().getArtifact().name == Artifacts.grimoire.rawValue {
            for hex in player.getCurrentWitch().hexes {
                player.getCurrentWitch().removeHex(hex: hex)
            }
        }
        
        text = Localization.shared.getTranslation(key: "swapWith", params: [player.getCurrentWitch().name, player.witches[target].name]) + "\n"
        player.currentWitchId = target
        
        if applyHex {
            if player.getCurrentWitch().applyHex(hex: Hexes.blessed.getHex(), resistable: false) {
                text += Localization.shared.getTranslation(key: "becameHex", params: [player.getCurrentWitch().name, Hexes.blessed.rawValue]) + "\n"
            }
        }
        
        if player.wishActivated && player.getCurrentWitch().currhp < player.getCurrentWitch().getModifiedBase().health {
            player.getCurrentWitch().currhp = player.getCurrentWitch().getModifiedBase().health
            
            text += Localization.shared.getTranslation(key: "gainedHP", params: [player.getCurrentWitch().name]) + "\n"
            
            player.wishActivated = false
        }
        
        var oppositePlayer: Player = players[0]
        if player.id == 0 {
            oppositePlayer = players[1]
        }
        
        if player.getCurrentWitch().getArtifact().name == Artifacts.mirror.rawValue {
            player.getCurrentWitch().overrideArtifact(artifact: oppositePlayer.getCurrentWitch().getArtifact())
            if player.getCurrentWitch().getArtifact().name == Artifacts.mask.rawValue {
                if oppositePlayer.getCurrentWitch().applyHex(hex: Hexes.attackDrop.getHex()) {
                    text += Localization.shared.getTranslation(key: "statDecreased", params: [oppositePlayer.getCurrentWitch().name, "attack"]) + "\n"
                }
            }
        }
        
        if oppositePlayer.getCurrentWitch().getArtifact().name == Artifacts.mask.rawValue {
            if player.getCurrentWitch().applyHex(hex: Hexes.attackDrop.getHex()) {
                text += Localization.shared.getTranslation(key: "statDecreased", params: [player.getCurrentWitch().name, "attack"]) + "\n"
            }
        }
                                                                                
        return text
                                                                                
    }
    
    /// Checks if witch can swap within their team.
    /// - Parameter player: The player
    /// - Returns: Returns whether the witch can swap in their team
    func isAbleToSwap(player: Player) -> Bool {
        if player.getCurrentWitch().hasHex(hexName: Hexes.chained.rawValue) {
            return false
        }
        
        var counter: Int = 0
        for witch in player.witches {
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
        for witch in players[0].witches {
            if witch.currhp > 0 {
                counter += 1
            }
        }
        
        if counter == 0 { //all witches in team have fainted -> unable to fight
            return true
        }
        
        for witch in players[1].witches {
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
        for witch in players[0].witches {
            if witch.currhp > 0 {
                return 0
            }
        }
        
        return 1
    }
}
