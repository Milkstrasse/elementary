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
    
    let hasCPUPlayer: Bool
    let players: [Player]
    var playerQueue: [(player: Player, move: Move)] = []
    
    @Published var fighting: Bool = false
    var backupLog: [String]
    @Published var fightLog: [String]
    
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
        if move.spell.useCounter + player.getCurrentFighter().manaUse > move.spell.uses {
            return false //spell cost is to high, fighter cannot use this spell
        }
        
        if player.hasToSwap { //fighter either fainted or has special artifact to swap
            if !player.getCurrentFighter().hasHex(hexName: Hexes.chained.rawValue) || player.getCurrentFighter().currhp == 0 {
                if move.index > -1 {
                    backupLog.append(swapFighters(player: player, target: move.index))
                }
                
                return false //action is free, new fighter can make a move
            }
        }
        
        //marks player as ready
        gameLogic.setReady(player: player.id, ready: true)
        
        switch playerQueue.count {
        case 0:
            playerQueue.append((player: player, move: move))
            if player.id > 0 {
                playerQueue.append((player: player, move: move))
            }
        case 1:
            if player.id > 0 {
                playerQueue.append((player: player, move: move))
            } else {
                playerQueue[0] = (player: player, move: move)
            }
        default:
            playerQueue[player.id] = (player: player, move: move)
        }
        
        playerQueue[player.id] = (player: player, move: move)
        
        //CPU makes its move
        if hasCPUPlayer {
            if players[0].hasToSwap {
                backupLog.append(swapFighters(player: players[0], target: CPULogic.shared.getTarget(currentFighter: players[0].currentFighterId, fighters: players[0].fighters, enemyElement: players[1].getCurrentFighter().getElement(), hasToSwap: true, weather: weather)))
            }
            
            var rndmMove: Move? = CPULogic.shared.getMove(player: players[0], target: players[1], weather: weather, lastSpell: players[0].getCurrentFighter().lastSpell)
            
            if rndmMove == nil { //CPU wants to switch
                rndmMove = Move(source: players[0].getCurrentFighter(), index: CPULogic.shared.getTarget(currentFighter: players[0].currentFighterId, fighters: players[0].fighters, enemyElement: players[1].getCurrentFighter().getElement(), hasToSwap: true, weather: weather), spell: Spell(), type: MoveType.swap)
            }
            
            playerQueue[0] = (player: players[0], move: rndmMove!)
        }
        
        //fight begins
        if gameLogic.areBothReady() || hasCPUPlayer {
            fighting = true
            fightLog = [Localization.shared.getTranslation(key: "loading")]
            
            //reset hasToSwap marker to prevent free swaps
            players[0].hasToSwap = false
            players[1].hasToSwap = false
            
            addTurns(fasterPlayer: players[getFasterPlayer()])
            
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
                        if !playerQueue.isEmpty {
                            while startTurn(player: playerQueue[0].player, move: playerQueue[0].move) && playerQueue.count > 1 {
                                playerQueue.removeFirst()
                            }
                            
                            playerQueue.removeFirst()
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
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                                AudioPlayer.shared.playStandardSound()
                                
                                gameLogic.setReady(player: 0, ready: false)
                                gameLogic.setReady(player: 1, ready: false)
                                //players are now able to choose their moves again
                                
                                fighting = false
                                
                                FightLog.shared.addFightLog(log: fightLog, currentFighter1: players[0].getCurrentFighter(), currentFighter2: players[1].getCurrentFighter(), weather: weather)
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
    }
    
    /// Determines which player has priority.
    /// - Returns: Returns the index of the player with priority
    private func getFasterPlayer() -> Int {
        //player wants to switch which -> priority
        if playerQueue[0].move.type == MoveType.swap {
            return 0
        } else if playerQueue[1].move.type == MoveType.swap {
            return 1
        }
        
        //priority move goes first
        if playerQueue[0].move.spell.priority > playerQueue[1].move.spell.priority {
            return 0
        } else if playerQueue[0].move.spell.priority < playerQueue[1].move.spell.priority {
            return 1
        }
        
        //determine priority with using the agility stat of the fighters
        if weather?.name == Weather.heavyStorm.rawValue { //flips speed check
            if players[0].getCurrentFighter().getModifiedBase(weather: weather).agility > players[1].getCurrentFighter().getModifiedBase(weather: weather).agility {
                return 1
            } else if players[1].getCurrentFighter().getModifiedBase(weather: weather).agility > players[0].getCurrentFighter().getModifiedBase(weather: weather).agility {
                return 0
            } else { //agility stat tie -> random player has priority
                return Int.random(in: 0 ... 1)
            }
        } else {
            if players[0].getCurrentFighter().getModifiedBase(weather: weather).agility > players[1].getCurrentFighter().getModifiedBase(weather: weather).agility {
                return 0
            } else if players[1].getCurrentFighter().getModifiedBase(weather: weather).agility > players[0].getCurrentFighter().getModifiedBase(weather: weather).agility {
                return 1
            } else { //agility stat tie -> random player has priority
                return Int.random(in: 0 ... 1)
            }
        }
    }
    
    /// Plans whole fight in advance and adds the moves to the queue.
    /// - Parameter fasterPlayer: The player that starts first
    private func addTurns(fasterPlayer: Player) {
        //finalize move
        for index in players.indices {
            if playerQueue[index].move.type == MoveType.spell { //spell move can be overwritten by artifacts/hexes
                if players[index].getCurrentFighter().lastSpell != nil && players[index].getCurrentFighter().hasHex(hexName: Hexes.restricted.rawValue) {
                    playerQueue[index].move.spell = players[index].getCurrentFighter().lastSpell!
                } else if players[index].getCurrentFighter().lastSpell != nil && players[index].getCurrentFighter().getArtifact().name == Artifacts.armor.rawValue && weather?.name != Weather.volcanicStorm.rawValue {
                    playerQueue[index].move.spell = players[index].getCurrentFighter().lastSpell!
                } else if players[index].getCurrentFighter().hasHex(hexName: Hexes.confused.rawValue) {
                    let randomMove: Move = Move(source: players[index].getCurrentFighter(), index: -1, spell: players[index].getCurrentFighter().spells[Int.random(in: 0 ..< players[index].getCurrentFighter().spells.count)], type: MoveType.spell)
                    playerQueue[index].move = randomMove
                }
                
                if playerQueue[index].move.spell.typeID == 13 && players[index].getCurrentFighter().lastSpell?.typeID == 13 {
                    players[index].getCurrentFighter().lastSpell = Spell(name: "shieldFail") //shield fails
                } else if playerQueue[index].move.spell.typeID != 10 { //prevent copy spell loop
                    players[index].getCurrentFighter().lastSpell = playerQueue[index].move.spell
                }
            }
            
            if playerQueue[index].move.spell.typeID == 10 { //player wants to copy last move
                if players[index].getCurrentFighter().lastSpell != nil {
                    playerQueue[index].move.spell = players[index].getCurrentFighter().lastSpell!
                }
            }
            
            //increase use counter of spells
            playerQueue[index].move.useSpell(amount: players[index].getCurrentFighter().manaUse)
        }
        
        var slowerPlayer: Player = players[0]
        if fasterPlayer.id == 0 {
            slowerPlayer = players[1]
        }
        
        //faster fighter makes move
        playerQueue.append((player: fasterPlayer, move: playerQueue[fasterPlayer.id].move))
        if playerQueue[fasterPlayer.id].move.type == MoveType.spell {
            for index in playerQueue[fasterPlayer.id].move.spell.spells.indices {
                playerQueue.append((player: fasterPlayer, move: Move(source: fasterPlayer.getCurrentFighter(), index: index, spell: playerQueue[fasterPlayer.id].move.spell, type: playerQueue[fasterPlayer.id].move.type)))
            }
            
            //buffer for artifact effects
            playerQueue.append((player: fasterPlayer, move: Move(source: fasterPlayer.getCurrentFighter(), index: 0, spell: playerQueue[fasterPlayer.id].move.spell, type: MoveType.artifact)))
            playerQueue.append((player: fasterPlayer, move: Move(source: fasterPlayer.getCurrentFighter(), index: 1, spell: playerQueue[fasterPlayer.id].move.spell, type: MoveType.artifact)))
        }
        
        //fighters faint or exit the fight
        if playerQueue[fasterPlayer.id].move.spell.typeID != 19 {
            playerQueue.append((player: slowerPlayer, move: Move(source: slowerPlayer.getCurrentFighter(), index: -1, spell: Spell(), type: MoveType.special)))
            playerQueue.append((player: fasterPlayer, move: Move(source: fasterPlayer.getCurrentFighter(), index: -1, spell: Spell(), type: MoveType.special)))
        }
        
        //slower fighter makes move
        playerQueue.append((player: slowerPlayer, move: playerQueue[slowerPlayer.id].move))
        if playerQueue[slowerPlayer.id].move.type == MoveType.spell {
            for index in playerQueue[slowerPlayer.id].move.spell.spells.indices {
                playerQueue.append((player: slowerPlayer, move: Move(source: slowerPlayer.getCurrentFighter(), index: index, spell: playerQueue[slowerPlayer.id].move.spell, type: playerQueue[slowerPlayer.id].move.type)))
            }
            
            //buffer for artifact effects
            playerQueue.append((player: slowerPlayer, move: Move(source: slowerPlayer.getCurrentFighter(), index: 0, spell: playerQueue[slowerPlayer.id].move.spell, type: MoveType.artifact)))
            playerQueue.append((player: slowerPlayer, move: Move(source: slowerPlayer.getCurrentFighter(), index: 1, spell: playerQueue[slowerPlayer.id].move.spell, type: MoveType.artifact)))
        }
        
        //fighters faint or exit the fight
        if playerQueue[slowerPlayer.id].move.spell.typeID != 19 {
            if playerQueue[fasterPlayer.id].move.spell.typeID != 19 {
                playerQueue.append((player: fasterPlayer, move: Move(source: fasterPlayer.getCurrentFighter(), index: -1, spell: Spell(), type: MoveType.special)))
            }
            playerQueue.append((player: slowerPlayer, move: Move(source: slowerPlayer.getCurrentFighter(), index: -1, spell: Spell(), type: MoveType.special)))
        }
        
        //faster fighter receives hex effects
        for index in 0 ..< 3 {
            playerQueue.append((player: fasterPlayer, move: Move(source: fasterPlayer.getCurrentFighter(), index: index, spell: Spell(), type: MoveType.hex)))
        }
        
        //slower fighter receives hex effects
        for index in 0 ..< 3 {
            playerQueue.append((player: slowerPlayer, move: Move(source: slowerPlayer.getCurrentFighter(), index: index, spell: Spell(), type: MoveType.hex)))
        }
        
        //faster fighter receives artifact effects
        playerQueue.append((player: fasterPlayer, move: Move(source: fasterPlayer.getCurrentFighter(), index: -1, spell: Spell(), type: MoveType.artifact)))
        
        //slower fighter receives artifact effects
        playerQueue.append((player: slowerPlayer, move: Move(source: slowerPlayer.getCurrentFighter(), index: -1, spell: Spell(), type: MoveType.artifact)))
        
        //remove placeholders
        playerQueue.removeFirst()
        playerQueue.removeFirst()
    }
    
    /// Executes a move from the queue and skips unneccessary moves.
    /// - Parameters:
    ///   - player: The player that makes the move
    ///   - move: The move the player wants to make
    /// - Returns: Returns wether the move gets skipped or not
    private func startTurn(player: Player, move: Move) -> Bool {
        let attacker: Fighter = player.getCurrentFighter()
        
        //check if move is skippable
        switch move.type {
        case .spell:
            if player.hasToSwap || player.getCurrentFighter().currhp == 0 { //fighter is unable to use spells
                return true
            }
        case .special:
            if !player.hasToSwap && player.getCurrentFighter().currhp > 0 { //fighter is still able to fight
                return true
            } else { //player can't leave/faint twice -> remove duplicate
                var movesToRemove: [Int] = []
                for index in 1 ..< playerQueue.count {
                    if playerQueue[index].move.type == MoveType.special && playerQueue[index].player.id == player.id {
                        movesToRemove.append(index)
                    }
                }
                
                for index in movesToRemove {
                    playerQueue.remove(at: index)
                }
            }
        case .hex:
            if player.hasToSwap || player.getCurrentFighter().currhp == 0 { //fighter is no longer present
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
            if player.hasToSwap || player.getCurrentFighter().currhp == 0 { //fighter is no longer present
                return true
            }
            
            if weather?.name != Weather.volcanicStorm.rawValue {
                if move.index < 0 {
                    if attacker.getArtifact().name != Artifacts.cornucopia.rawValue { //artifact has no effect
                        return true
                    } else if attacker.getArtifact().name == Artifacts.potion.rawValue && attacker.currhp > attacker.getModifiedBase().health/2 { //artifact has no effect yet
                        return true
                    }
                } else if move.index == 0 {
                    if attacker.getArtifact().name != Artifacts.sword.rawValue || move.spell.typeID < 10 {
                        return true
                    }
                } else {
                    var oppositePlayer: Player = players[0]
                    if player.id == 0 {
                        oppositePlayer = players[1]
                    }
                    
                    if oppositePlayer.getCurrentFighter().getArtifact().name != Artifacts.helmet.rawValue || move.spell.typeID < 10 {
                        return true
                    }
                }
            } else { //weather makes artifacts useless
                return true
            }
        default:
            break
        }
        
        if move.type == MoveType.swap { //check if swap possible
            if attacker.hasHex(hexName: Hexes.chained.rawValue) {
                fightLog.append(Localization.shared.getTranslation(key: "swapFailed", params: [attacker.name]))
            } else {
                fightLog.append(swapFighters(player: player, target: move.index))
            }
        } else {
            fightLog.append(TurnLogic.shared.startTurn(player: player, fightLogic: self))
        }
        
        return false
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
        
        if player.getCurrentFighter().getArtifact().name == Artifacts.grimoire.rawValue && weather?.name != Weather.volcanicStorm.rawValue {
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
        
        if weather?.name != Weather.volcanicStorm.rawValue && player.getCurrentFighter().getArtifact().name == Artifacts.mask.rawValue {
            if weather?.name != Weather.springWeather.rawValue && oppositePlayer.getCurrentFighter().applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) {
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
            var unusableSpells: Int = 0
            
            if fighter.currhp > 0 {
                for spell in fighter.spells { //check if fighter can use any spell
                    if spell.useCounter + fighter.manaUse > spell.uses {
                        unusableSpells += 1
                    }
                }
                
                if unusableSpells < fighter.spells.count {
                    counter += 1
                }
            }
        }
        
        if counter == 0 { //all fighters in team are unable to fight
            return true
        }
        
        for fighter in players[1].fighters {
            var unusableSpells: Int = 0
            
            if fighter.currhp > 0 {
                for spell in fighter.spells { //check if fighter can use any spell
                    if spell.useCounter + fighter.manaUse > spell.uses {
                        unusableSpells += 1
                    }
                }
                
                if unusableSpells < fighter.spells.count {
                    return false //fighter able to fight was found, both teams are able to fight
                }
            }
        }
        
        return true //all fighters in team are unable to fight
    }
    
    /// Ends the game with a forfeit.
    /// - Parameter player: The id of the player
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
                for spell in fighter.spells { //check if fighter can use any spell
                    if spell.useCounter + fighter.manaUse > spell.uses {
                        unusableSpells += 1
                    }
                }
                
                if unusableSpells < fighter.spells.count {
                    return 0 //one able fighter was found -> player 0 has won by default
                }
            }
        }
        
        return 1
    }
}
