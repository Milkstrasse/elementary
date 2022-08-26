//
//  FightLogic.swift
//  Elementary
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

/// This is the main logic of the game. Stores all participating fighters, determines the turn order and the amount of turns needed in each round, swaps fighters , determines when the game is over and who has won.
class FightLogic: ObservableObject {
    private var gameLogic: GameLogic = GameLogic()
    
    private let hasCPUPlayer: Bool
    let players: [Player]
    var playerQueue: [(player: Player, index: Int)] = []
    
    @Published var battling: Bool = false
    var backupLog: [String]
    @Published var battleLog: [String]
    @Published var gameOver: Bool = false
    
    @Published var weather: Hex?
    
    /// Creates the logic used for a fight.
    /// - Parameters:
    ///   - players: The player fighting against each other
    ///   - hasCPUPlayer: If one of the players is the CPU
    init(players: [Player], hasCPUPlayer: Bool = false) {
        self.hasCPUPlayer = hasCPUPlayer
        backupLog = []

        self.players = players
        
        //apply effect of artifact on "entering"
        if players[0].getCurrentFighter().getArtifact().name == Artifacts.mask.rawValue {
            if players[1].getCurrentFighter().applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) {
                backupLog.append(Localization.shared.getTranslation(key: "statDecreased", params: [players[1].getCurrentFighter().name, "attack"]))
            }
        }
        
        if players[1].getCurrentFighter().getArtifact().name == Artifacts.mask.rawValue {
            if players[0].getCurrentFighter().applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) {
                backupLog.append(Localization.shared.getTranslation(key: "statDecreased", params: [players[0].getCurrentFighter().name, "attack"]))
            }
        }
        
        battleLog = [Localization.shared.getTranslation(key: "fightBegin")]
        
        BattleLog.shared.generatePlayerInfo(player1Fighters: players[0].fighters, player2Fighters: players[1].fighters)
    }
    
    /// Checks if there are enough fighters on both sides.
    /// - Returns: Returns whether this fight has enough fighters on both sides
    func isValid() -> Bool {
        return (!players[0].fighters.isEmpty && players[0].fighters.count <= 4) && (!players[1].fighters.isEmpty && players[1].fighters.count <= 4)
    }
    
    /// Player declares which move they want to make in the following round of the fight.
    /// - Parameters:
    ///   - player: The index of the player who makes the move
    ///   - move: The action the player wants to make
    /// - Returns: Returns whether a round of fighting will begin or the player has to or is able to do another action
    func makeMove(player: Player, move: Move) -> Bool {
        if move.spell.useCounter + player.getCurrentFighter().manaUse > move.spell.uses {
            return false //spell cost is to high, fighter cannot use this spell
        } else if move.target > -1 {
            if player.fighters[move.target].currhp == 0 {
                return false //fighter cannot switch with fainted fighters
            }
        }
        
        if player.hasToSwap { //fighter either fainted or has special artifact to swap
            if !player.getCurrentFighter().hasHex(hexName: Hexes.chained.rawValue) || player.getCurrentFighter().currhp == 0 {
                if move.target > -1 {
                    backupLog.append(swapFighters(player: player, target: move.target))
                }
                
                return false //action is free, new fighter can make a move
            }
        }
        
        //marks player as ready
        gameLogic.setReady(player: player.id, ready: true)
        player.usedMoves.insert(move, at: 0)
        
        //CPU makes its move
        if hasCPUPlayer {
            if players[0].hasToSwap {
                backupLog.append(swapFighters(player: players[0], target: CPULogic.shared.getTarget(currentFighter: players[0].currentFighterId, fighters: players[0].fighters, enemyElement: players[1].getCurrentFighter().getElement(), hasToSwap: true)))
            }
            
            var rndmMove: Move? = CPULogic.shared.getMove(player: players[0], target: players[1], weather: weather, lastMove: players[0].usedMoves.first)
            
            if rndmMove == nil { //CPU wants to switch
                rndmMove = Move(source: players[0].getCurrentFighter(), target: CPULogic.shared.getTarget(currentFighter: players[0].currentFighterId, fighters: players[0].fighters, enemyElement: players[1].getCurrentFighter().getElement(), hasToSwap: true), spell: Spell())
            }
            
            players[0].usedMoves.insert(rndmMove!, at: 0)
        }
        
        //fight begins
        if gameLogic.areBothReady() || hasCPUPlayer {
            battling = true
            battleLog = [Localization.shared.getTranslation(key: "loading")]
            
            //reset hasToSwap marker to prevent free swaps
            players[0].hasToSwap = false
            players[1].hasToSwap = false
            
            //adds faster player to playerQueue
            addMoveTurn(player: players[getFasterPlayer()])
            
            var endRound: Bool = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                var turns: Int = -1
                //amount of turns first player needs to do their action
                let firstTurns: Int = playerQueue.count
                
                //processes all actions on playerQueue
                Timer.scheduledTimer(withTimeInterval: GlobalData.shared.getTextSpeed() , repeats: true) { [self] timer in
                    if turns < 0 {
                        battleLog = []
                        turns = 0
                    }
                    
                    if !backupLog.isEmpty {
                        battleLog.append(backupLog.removeFirst())
                    } else {
                        let currentPlayer: Player = playerQueue[0].player;
                        turns += 1
                        
                        startTurn(player: currentPlayer)
                        playerQueue.removeFirst()
                        
                        if playerQueue.isEmpty && !endRound { //adds new action if neccessary during the fight
                            endRound = addTurns(currentPlayer: currentPlayer, turns: turns, firstTurns: firstTurns)
                        }
                        
                        if playerQueue.isEmpty {
                            timer.invalidate()
                            
                            //decrease counter of all hexes and remove if duration reached 0
                            if weather != nil {
                                weather!.duration -= 1
                                
                                if weather!.duration == 0 {
                                    weather = nil
                                }
                            }
                            
                            for hex in players[0].getCurrentFighter().hexes {
                                hex.duration -= 1
                                
                                if hex.duration == 0 {
                                    players[0].getCurrentFighter().removeHex(hex: hex)
                                }
                            }
                            for hex in players[1].getCurrentFighter().hexes {
                                hex.duration -= 1
                                
                                if hex.duration == 0 {
                                    players[1].getCurrentFighter().removeHex(hex: hex)
                                }
                            }
                            
                            if players[0].tauntCounter > 0 {
                                players[0].tauntCounter -= 1
                            }
                            if players[1].tauntCounter > 0 {
                                players[1].tauntCounter -= 1
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                                AudioPlayer.shared.playConfirmSound()
                                
                                gameLogic.setReady(player: 0, ready: false)
                                gameLogic.setReady(player: 1, ready: false)
                                //players are now able to choose their moves again
                                
                                battling = false
                                
                                BattleLog.shared.addBattleLog(log: battleLog, currentFighter1: players[0].getCurrentFighter(), currentFighter2: players[1].getCurrentFighter(), weather: weather)
                            }
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
    private func getFasterPlayer() -> Int {
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
        
        //determine priority with using the agility stat of the fighters
        if players[0].getCurrentFighter().getModifiedBase().agility > players[1].getCurrentFighter().getModifiedBase().agility {
            return 0
        } else if players[1].getCurrentFighter().getModifiedBase().agility > players[0].getCurrentFighter().getModifiedBase().agility {
            return 1
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
    private func addTurns(currentPlayer: Player, turns: Int, firstTurns: Int) -> Bool {
        if players[0].getCurrentFighter().currhp > 0 && players[1].getCurrentFighter().currhp > 0 {
            if turns == firstTurns {
                if currentPlayer.id == 0 {
                    addMoveTurn(player: players[1])
                } else {
                    addMoveTurn(player: players[0])
                }
            } else {
                addHexTurns(player: players[0])
                addHexTurns(player: players[1])
                return true
            }
            
            return false
        }
        
        if players[0].getCurrentFighter().currhp == 0 && players[1].getCurrentFighter().currhp == 0 {
            playerQueue.append((player: players[0], index: 0))
            playerQueue.append((player: players[1], index: 0))
            
            return true
        } else if players[0].getCurrentFighter().currhp == 0 {
            playerQueue.append((player: players[0], index: 0))
            
            if currentPlayer.id == 0 && turns == firstTurns {
                addMoveTurn(player: players[1])
                addHexTurns(player: players[1])
                return true
            } else {
                addHexTurns(player: players[1])
                return true
            }
        } else if players[1].getCurrentFighter().currhp == 0 {
            playerQueue.append((player: players[1], index: 0))
            
            if currentPlayer.id == 1 && turns == firstTurns {
                addMoveTurn(player: players[0])
                addHexTurns(player: players[0])
                return true
            } else {
                addHexTurns(player: players[0])
                return true
            }
        }
        
        return false
    }
    
    /// Adds turns depending on the move of the player to the current round of fighting.
    /// - Parameter player: The index of the player
    private func addMoveTurn(player: Player) {
        //adds move into the used moves collection
        if player.usedMoves[0].target < 0 { //non swap move can be overwritten by hexes
            if player.getCurrentFighter().lastMove != nil && player.getCurrentFighter().hasHex(hexName: Hexes.restricted.rawValue) {
                player.usedMoves[0] = player.getCurrentFighter().lastMove!
            } else if player.getCurrentFighter().lastMove != nil && player.getCurrentFighter().getArtifact().name == Artifacts.corset.rawValue {
                if player.usedMoves[1].target < 0 { //last move was not a swap
                    player.usedMoves[0] = player.getCurrentFighter().lastMove!
                }
            } else if player.getCurrentFighter().hasHex(hexName: Hexes.confused.rawValue) {
                let randomMove: Move = Move(source: player.getCurrentFighter(), spell: player.getCurrentFighter().spells[Int.random(in: 0 ..< player.getCurrentFighter().spells.count)])
                player.usedMoves[0] = randomMove
            }
            
            player.getCurrentFighter().lastMove = player.usedMoves[0]
        } else {
            player.getCurrentFighter().lastMove = nil
        }
            
        //increase useCounter of spells
        player.usedMoves[0].useSpell(amount: player.getCurrentFighter().manaUse)
        
        var oppositePlayer: Player = players[0]
        if player.id == 0 {
            oppositePlayer = players[1]
        }
            
        if player.usedMoves[0].spell.typeID == 9 { //player wants to copy enemy's move
            if players[oppositePlayer.id].usedMoves[0].target < 0 {
                player.usedMoves[0] = players[oppositePlayer.id].usedMoves[0]
            }
        }
        
        if player.usedMoves[0].target < 0 && oppositePlayer.getCurrentFighter().currhp > 0 {
            playerQueue.append((player: player, index: 0))
            
            for index in player.usedMoves[0].spell.spells.indices {
                playerQueue.append((player: player, index: index + 1))
            }
            
            if player.getCurrentFighter().getArtifact().name == Artifacts.sword.rawValue && player.usedMoves[0].spell.typeID < 10 {
                playerQueue.append((player: player, index: player.usedMoves[0].spell.spells.count + 1))
            } else if  oppositePlayer.getCurrentFighter().getArtifact().name == Artifacts.helmet.rawValue && player.usedMoves[0].spell.typeID < 10 {
                playerQueue.append((player: player, index: player.usedMoves[0].spell.spells.count + 1))
            }
        } else { //this is a swap or spell will fail
            playerQueue.append((player: player, index: 0))
        }
    }
    
    /// Adds turns depending on the hexes of the player to the current round of fighting.
    /// - Parameter player: The index of the player
    private func addHexTurns(player: Player) {
        if !player.getCurrentFighter().hexes.isEmpty {
            for index in player.getCurrentFighter().hexes.indices {
                let hex: Hex = player.getCurrentFighter().hexes[index]
                
                if hex.damageAmount != 0 && hex.name != Hexes.bombed.rawValue {
                    playerQueue.append((player: player, index: -1 - index))
                } else if hex.name == Hexes.bombed.rawValue && hex.duration == 1 {
                    playerQueue.append((player: player, index: -1 - index))
                }
            }
        }
        
        if player.getCurrentFighter().getArtifact().name == Artifacts.cornucopia.rawValue {
            playerQueue.append((player: player, index: -10))
        } else if player.getCurrentFighter().getArtifact().name == Artifacts.potion.rawValue && player.getCurrentFighter().currhp <= player.getCurrentFighter().getModifiedBase().health/2 {
            playerQueue.append((player: player, index: -15))
        }
    }
    
    /// Starts the turn of a player.
    /// - Parameter player: The player
    private func startTurn(player: Player) {
        let attacker: Fighter = player.getCurrentFighter()
        
        if player.usedMoves[0].target > -1 {
            if attacker.hasHex(hexName: Hexes.chained.rawValue) {
                battleLog.append(Localization.shared.getTranslation(key: "swapFailed", params: [attacker.name]))
                return
            }
            
            battleLog.append(swapFighters(player: player, target: player.usedMoves[0].target))
        } else {
            battleLog.append(TurnLogic.shared.startTurn(player: player, fightLogic: self))
        }
    }
    
    /// Swaps two fighters.
    /// - Parameters:
    ///   - player: The player
    ///   - target: The index of the targeted fighter
    /// - Returns: Returns the description of what occured during the swap
    private func swapFighters(player: Player, target: Int) -> String {
        if player.fighters[target].currhp == 0 || player.fighters[target] == player.getCurrentFighter() { //temporary fix to double swap in same round
            return ""
        }
        
        player.hasToSwap = false //flag no longer necessary
        
        var text: String
        
        if player.getCurrentFighter().getArtifact().name == Artifacts.grimoire.rawValue {
            for hex in player.getCurrentFighter().hexes {
                player.getCurrentFighter().removeHex(hex: hex)
            }
        }
        
        text = Localization.shared.getTranslation(key: "swapWith", params: [player.getCurrentFighter().name, player.fighters[target].name]) + "\n"
        player.currentFighterId = target
        
        if player.wishActivated && player.getCurrentFighter().currhp < player.getCurrentFighter().getModifiedBase().health {
            player.getCurrentFighter().currhp = player.getCurrentFighter().getModifiedBase().health
            
            text += Localization.shared.getTranslation(key: "gainedHP", params: [player.getCurrentFighter().name]) + "\n"
            
            player.wishActivated = false
        }
        
        var oppositePlayer: Player = players[0]
        if player.id == 0 {
            oppositePlayer = players[1]
        }
        
        if player.getCurrentFighter().getArtifact().name == Artifacts.mask.rawValue {
            if oppositePlayer.getCurrentFighter().applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) {
                text += Localization.shared.getTranslation(key: "statDecreased", params: [oppositePlayer.getCurrentFighter().name, "attack"]) + "\n"
            } else {
                text += Localization.shared.getTranslation(key: "hexFailed")
            }
        }
                                                                                
        return String(text.dropLast())
                                                                                
    }
    
    /// Checks if game is over.
    /// - Returns: Returns whether one of the teams only consists of fainted fighters
    func isGameOver() -> Bool {
        var counter: Int = 0
        for fighter in players[0].fighters {
            if fighter.currhp > 0 {
                counter += 1
            }
        }
        
        if counter == 0 { //all fighters in team have fainted -> unable to fight
            return true
        }
        
        for fighter in players[1].fighters {
            if fighter.currhp > 0 {
                return false //fighter able to fight was found, both teams are able to fight
            }
        }
        
        return true //all fighters in team have fainted -> unable to fight
    }
    
    /// Ends the game with a forfeit.
    /// - Parameter player: The id of the player
    func forfeit(player: Int) {
        gameLogic.forfeit(player: player)
    }
    
    /// Determines the winner of the game. Currently no draws possible.
    /// - Returns: Returns the id of the winning player
    func getWinner() -> Int {
        SaveLogic.shared.saveBattle()
        
        //player who has forfeited loses automatically
        if gameLogic.forfeited[0] {
            return 1
        } else if gameLogic.forfeited[1] {
            return 0
        }
        
        //if one player has alive fighters other autmatically loses
        for fighter in players[0].fighters {
            if fighter.currhp > 0 {
                return 0
            }
        }
        
        return 1
    }
}
