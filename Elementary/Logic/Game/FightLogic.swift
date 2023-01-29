//
//  FightLogic.swift
//  Elementary
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

/// This is the main logic of the game. Stores all participating fighters, determines the turn order and the amount of turns needed in each round, determines when the game is over and who has won.
class FightLogic: ObservableObject {
    var gameLogic: GameLogic
    
    let singleMode: Bool
    let hasCPUPlayer: Bool
    let players: [Player]
    var playerQueue: PlayerQueue
    
    @Published var fighting: Bool = false
    
    private var backupLog: [String]
    @Published var fightLog: [String]
    
    @Published var weather: Hex?
    
    /// Creates the logic used for a fight.
    /// - Parameters:
    ///   - players: The player fighting against each other
    ///   - hasCPUPlayer: If one of the players is the CPU
    init(players: [Player], hasCPUPlayer: Bool, singleMode: Bool) {
        if singleMode {
            gameLogic = GameLogic(topFighterCount: 1, bottomFighterCount: 1)
        } else {
            gameLogic = GameLogic(topFighterCount: players[0].fighters.count, bottomFighterCount: players[1].fighters.count)
        }
        
        self.hasCPUPlayer = hasCPUPlayer
        self.singleMode = singleMode
        
        backupLog = []
        
        self.players = players
        
        playerQueue = PlayerQueue(singleMode: singleMode)
        
        if singleMode {
            //apply effect of artifact on "entering"
            if players[0].getCurrentFighter().getArtifact().name == Artifacts.mask.rawValue {
                if players[1].getCurrentFighter().applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) == 0 {
                    backupLog.append(Localization.shared.getTranslation(key: Hexes.attackDrop.getHex().name, params: [players[1].getCurrentFighter().name]))
                }
            }
            
            if players[1].getCurrentFighter().getArtifact().name == Artifacts.mask.rawValue {
                if players[0].getCurrentFighter().applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) == 0 {
                    backupLog.append(Localization.shared.getTranslation(key: Hexes.attackDrop.getHex().name, params: [players[0].getCurrentFighter().name]))
                }
            }
        } else {
            for fighter in players[0].fighters {
                //apply effect of artifact on "entering"
                if fighter.getArtifact().name == Artifacts.mask.rawValue {
                    for fghtr in players[1].fighters {
                        if fghtr.applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) == 0 {
                            backupLog.append(Localization.shared.getTranslation(key: Hexes.attackDrop.getHex().name, params: [fghtr.name]))
                        }
                    }
                }
            }
            
            for fighter in players[1].fighters {
                //apply effect of artifact on "entering"
                if fighter.getArtifact().name == Artifacts.mask.rawValue {
                    for fghtr in players[0].fighters {
                        if fghtr.applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) == 0 {
                            backupLog.append(Localization.shared.getTranslation(key: Hexes.attackDrop.getHex().name, params: [fghtr.name]))
                        }
                    }
                }
            }
        }
        
        fightLog = [Localization.shared.getTranslation(key: "fightBegin")]
        
        FightLog.shared.generatePlayerInfo(player1Fighters: players[0].fighters, player2Fighters: players[1].fighters)
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
        if singleMode && player.hasToSwap { //fighter either fainted or has special artifact to swap
            if !player.getCurrentFighter().hasHex(hexName: Hexes.chained.rawValue) || player.getCurrentFighter().currhp == 0 {
                if move.type == MoveType.swap {
                    backupLog.append(player.swapFighters(target: move.index, fightLogic: self))
                }
                
                return false //action is free, new fighter can make a move
            }
        }
        
        if playerQueue.addToQueue(player: player, move: move, fighterAmount: gameLogic.fighterCounts[0]) {
            if singleMode {
                gameLogic.setReady(player: player.id, ready: true)
            } else {
                gameLogic.setReady(player: player.id, ready: player.isAtLastFighter(index: move.source))
            }
        } else {
            return false
        }
        
        //CPU makes its move
        if hasCPUPlayer {
            if players[0].hasToSwap {
                backupLog.append(players[0].swapFighters(target: CPULogic.shared.getTarget(currentFighter: players[0].currentFighterId, player: players[0], enemyElement: players[1].getCurrentFighter().getElement(), hasToSwap: true, weather: weather), fightLogic: self))
            }
            
            var rndmMove: Move
            if players[0].getCurrentFighter().lastSpell >= 0 {
                rndmMove = CPULogic.shared.getMove(player: players[0], target: players[1], weather: weather, lastSpell: players[0].getCurrentFighter().singleSpells[players[0].getCurrentFighter().lastSpell])
            } else {
                rndmMove = CPULogic.shared.getMove(player: players[0], target: players[1], weather: weather, lastSpell: nil)
            }
            
            playerQueue.queue[0] = (player: players[0], move: rndmMove)
        }
        
        //fight begins
        if gameLogic.areBothReady() || hasCPUPlayer {
            fighting = true
            fightLog = [Localization.shared.getTranslation(key: "loading")]
            
            //reset hasToSwap marker to prevent free swaps
            players[0].hasToSwap = false
            players[1].hasToSwap = false
            
            playerQueue.cleanQueue()
            playerQueue.finalizeMoves(players: players, weather: weather)
            playerQueue.addTurns(players: players, weather: weather)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                var turns: Int = -1
                
                //processes all actions on playerQueue
                Timer.scheduledTimer(withTimeInterval: GlobalData.shared.getTextSpeed() , repeats: true) { [self] timer in
                    if turns < 0 {
                        fightLog = []
                        turns = 0
                    }
                    
                    if !backupLog.isEmpty {
                        fightLog.append(backupLog.removeFirst())
                    } else {
                        if !playerQueue.queue.isEmpty {
                            while startTurn(player: playerQueue.queue[0].player, move: playerQueue.queue[0].move) && playerQueue.queue.count > 1 {
                                playerQueue.queue.removeFirst()
                            }
                            
                            playerQueue.queue.removeFirst()
                        }
                        
                        if playerQueue.queue.isEmpty {
                            timer.invalidate()
                            
                            //decrease counter of all hexes and remove if duration reached 0
                            if weather != nil {
                                weather!.duration -= 1
                                
                                if weather!.duration == 0 {
                                    weather = nil
                                }
                            }
                            
                            if singleMode {
                                players[0].getCurrentFighter().hasSwapped = false
                                for hex in players[0].getCurrentFighter().hexes {
                                    hex.duration -= 1
                                    
                                    if hex.duration == 0 {
                                        players[0].getCurrentFighter().removeHex(hex: hex)
                                    }
                                }
                                
                                players[1].getCurrentFighter().hasSwapped = false
                                for hex in players[1].getCurrentFighter().hexes {
                                    hex.duration -= 1
                                    
                                    if hex.duration == 0 {
                                        players[1].getCurrentFighter().removeHex(hex: hex)
                                    }
                                }
                            } else {
                                for fighter in players[0].fighters {
                                    fighter.hasSwapped = false
                                    for hex in fighter.hexes {
                                        hex.duration -= 1
                                        
                                        if hex.duration == 0 {
                                            fighter.removeHex(hex: hex)
                                        }
                                    }
                                }
                                
                                for fighter in players[1].fighters {
                                    fighter.hasSwapped = false
                                    for hex in fighter.hexes {
                                        hex.duration -= 1
                                        
                                        if hex.duration == 0 {
                                            fighter.removeHex(hex: hex)
                                        }
                                    }
                                }
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                                AudioPlayer.shared.playStandardSound()
                                
                                gameLogic.setReady(player: 0, ready: false)
                                gameLogic.setReady(player: 1, ready: false)
                                gameLogic.clearSpells()
                                //players are now able to choose their moves again
                                
                                fighting = false
                                
                                if singleMode {
                                    FightLog.shared.addFightLog(log: fightLog, currentFighter1: players[0].getCurrentFighter(), currentFighter2: players[1].getCurrentFighter(), weather: weather)
                                } else {
                                    FightLog.shared.addFightLog(log: fightLog, player1Fighters: players[0].fighters, player2Fighters: players[1].fighters, weather: weather)
                                }
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
        if !singleMode {
            player.currentFighterId = 0
            while player.getCurrentFighter().currhp == 0 {
                player.goToNextFighter()
            }
        }
        
        gameLogic.setReady(player: player.id, ready: false)
    }
    
    /// Executes a move from the queue and skips unneccessary moves.
    /// - Parameters:
    ///   - player: The player that makes the move
    ///   - move: The move the player wants to make
    /// - Returns: Returns wether the move gets skipped or not
    private func startTurn(player: Player, move: Move) -> Bool {
        let attacker: Fighter = player.getFighter(index: move.source)
        
        //check if move is skippable
        switch move.type {
        case .spell:
            if player.hasToSwap || attacker.currhp == 0 { //fighter is unable to use spells
                return true
            }
        case .special:
            if attacker.hasSwapped {
                return true
            } else if !player.hasToSwap && attacker.currhp > 0 { //fighter is still able to fight
                return true
            }
        case .hex:
            if player.hasToSwap || attacker.currhp == 0 { //fighter is no longer present
                return true
            } else if move.index >= attacker.hexes.count { //fighter has not enough hexes
                return true
            }
            
            let hex: Hex = attacker.hexes[move.index]
            
            if hex.damageAmount == 0 { //hex has no effect
                return true
            } else if hex.name == Hexes.bombed.rawValue && hex.duration != 1 { //hex has no effect yet
                return true
            } else if hex.name == Hexes.doomed.rawValue && hex.duration != 1 { //hex has no effect yet
                return true
            }
        case .artifact:
            if player.hasToSwap || attacker.currhp == 0 { //fighter is no longer present
                return true
            }
            
            let target: Fighter = players[move.targetedPlayer].getFighter(index: move.target)
            
            if weather?.name != Weather.volcanicStorm.rawValue {
                switch move.index {
                case 0:
                    if singleMode {
                        if attacker.getArtifact().name != Artifacts.sword.rawValue || attacker.singleSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    } else {
                        if attacker.getArtifact().name != Artifacts.sword.rawValue || attacker.multiSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    }
                case 1:
                    if singleMode {
                        if target.getArtifact().name != Artifacts.helmet.rawValue || attacker.singleSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    } else {
                        if target.getArtifact().name != Artifacts.helmet.rawValue || attacker.multiSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    }
                case 2:
                    if (target.getArtifact().name != Artifacts.thread.rawValue && attacker.getArtifact().name != Artifacts.thread.rawValue) || target.currhp > 0 {
                        return true
                    }
                default:
                    if attacker.getArtifact().name != Artifacts.cornucopia.rawValue { //artifact has no effect
                        return true
                    } else if attacker.getArtifact().name == Artifacts.potion.rawValue && attacker.currhp > attacker.getModifiedBase().health/2 { //artifact has no effect yet
                        return true
                    }
                }
            } else { //weather makes artifacts useless
                return true
            }
        default:
            break
        }
        
        //execute move
        if move.type == MoveType.swap { //check if swap possible
            if attacker.hasHex(hexName: Hexes.chained.rawValue) {
                fightLog.append(Localization.shared.getTranslation(key: "swapFailed", params: [attacker.name]))
            } else {
                fightLog.append(player.swapFighters(target: move.index, fightLogic: self))
            }
        } else {
            fightLog.append(TurnLogic.shared.startTurn(player: player, fightLogic: self))
        }
        
        return false
    }
    
    /// Checks if game is over.
    /// - Returns: Returns whether one of the teams only consists of fainted fighters
    func isGameOver() -> Bool {
        var counter: Int = 0
        
        for fighter in players[0].fighters {
            var unusableSpells: Int = 0
            
            if singleMode {
                if fighter.currhp > 0 {
                    for spell in fighter.singleSpells { //check if fighter can use any spell
                        if spell.useCounter + fighter.manaUse > spell.uses {
                            unusableSpells += 1
                        }
                    }
                    
                    if unusableSpells < fighter.singleSpells.count {
                        counter += 1
                    }
                }
            } else {
                if fighter.currhp > 0 {
                    for spell in fighter.multiSpells { //check if fighter can use any spell
                        if spell.useCounter + fighter.manaUse > spell.uses {
                            unusableSpells += 1
                        }
                    }
                    
                    if unusableSpells < fighter.multiSpells.count {
                        counter += 1
                    }
                }
            }
        }
        
        if counter == 0 { //all fighters in team are unable to fight
            return true
        }
        
        for fighter in players[1].fighters {
            var unusableSpells: Int = 0
            
            if singleMode {
                if fighter.currhp > 0 {
                    for spell in fighter.singleSpells { //check if fighter can use any spell
                        if spell.useCounter + fighter.manaUse > spell.uses {
                            unusableSpells += 1
                        }
                    }
                    
                    if unusableSpells < fighter.singleSpells.count {
                        return false //fighter able to fight was found, both teams are able to fight
                    }
                }
            } else {
                if fighter.currhp > 0 {
                    for spell in fighter.multiSpells { //check if fighter can use any spell
                        if spell.useCounter + fighter.manaUse > spell.uses {
                            unusableSpells += 1
                        }
                    }
                    
                    if unusableSpells < fighter.multiSpells.count {
                        return false //fighter able to fight was found, both teams are able to fight
                    }
                }
            }
        }
        
        return true //all fighters in team are unable to fight
    }
    
    /// Ends the game with a forfeit.
    /// - Parameter player: The id of the player who forfeits
    func forfeit(player: Int) {
        gameLogic.forfeit(player: player)
    }
    
    /// Determines the winner of the game. Currently no draws possible.
    /// - Returns: Returns the id of the winning player
    func getWinner() -> Int {
        SaveData.saveFight()
        
        //player who has forfeited loses automatically
        if gameLogic.forfeited[0] {
            return 1
        } else if gameLogic.forfeited[1] {
            return 0
        }
        
        for fighter in players[0].fighters {
            var unusableSpells: Int = 0
            
            if fighter.currhp > 0 {
                if singleMode {
                    for spell in fighter.singleSpells { //check if fighter can use any spell
                        if spell.useCounter + fighter.manaUse > spell.uses {
                            unusableSpells += 1
                        }
                    }
                    
                    if unusableSpells < fighter.singleSpells.count {
                        return 0 //one able fighter was found -> player 0 has won by default
                    }
                } else {
                    for spell in fighter.multiSpells { //check if fighter can use any spell
                        if spell.useCounter + fighter.manaUse > spell.uses {
                            unusableSpells += 1
                        }
                    }
                    
                    if unusableSpells < fighter.multiSpells.count {
                        return 0 //one able fighter was found -> player 0 has won by default
                    }
                }
            }
        }
        
        return 1
    }
}
