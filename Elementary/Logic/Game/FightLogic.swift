//
//  FightLogic.swift
//  Elementary
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

/// This is the main logic of the game. Stores all participating fighters, determines the turn order and the amount of turns needed in each round, swaps fighters , determines when the game is over and who has won.
class FightLogic: ObservableObject {
    var gameLogic: GameLogic
    
    let singleMode: Bool
    let hasCPUPlayer: Bool
    let players: [Player]
    var playerQueue: [(player: Player, move: Move)] = []
    
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
            gameLogic = GameLogic(fullAmount: 2)
        } else {
            gameLogic = GameLogic(fullAmount: 8)
        }
        
        self.hasCPUPlayer = hasCPUPlayer
        self.singleMode = singleMode
        
        backupLog = []
        
        self.players = players
        
        if singleMode {
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
        } else {
            for fighter in players[0].fighters {
                //apply effect of artifact on "entering"
                if fighter.getArtifact().name == Artifacts.mask.rawValue {
                    for fghtr in players[1].fighters {
                        if fghtr.applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) {
                            backupLog.append(Localization.shared.getTranslation(key: "statDecreased", params: [fghtr.name, "attack"]))
                        }
                    }
                }
            }
            
            for fighter in players[1].fighters {
                //apply effect of artifact on "entering"
                if fighter.getArtifact().name == Artifacts.mask.rawValue {
                    for fghtr in players[0].fighters {
                        if fghtr.applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) {
                            backupLog.append(Localization.shared.getTranslation(key: "statDecreased", params: [fghtr.name, "attack"]))
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
        if singleMode {
            return (!players[0].fighters.isEmpty && players[0].fighters.count <= 4) && (!players[1].fighters.isEmpty && players[1].fighters.count <= 4)
        } else {
            return players[0].fighters.count == gameLogic.fullAmount/2 && players[1].fighters.count == gameLogic.fullAmount/2
        }
    }
    
    /// Player declares which move they want to make in the following round of the fight.
    /// - Parameters:
    ///   - player: The index of the player who makes the move
    ///   - move: The action the player wants to make
    /// - Returns: Returns whether a round of fighting will begin or the player has to or is able to do another action
    func makeMove(player: Player, move: Move) -> Bool {
        if singleMode && player.hasToSwap { //fighter either fainted or has special artifact to swap
            if !player.getCurrentFighter().hasHex(hexName: Hexes.chained.rawValue) || player.getCurrentFighter().currhp == 0 {
                if move.type == .swap {
                    backupLog.append(swapFighters(player: player, target: move.index))
                }
                
                return false //action is free, new fighter can make a move
            }
        }
        
        if singleMode {
            if move.spell > -1 && move.source.singleSpells[move.spell].useCounter + move.source.manaUse > move.source.singleSpells[move.spell].uses {
                return false //spell cost is to high, fighter cannot use this spell
            }
            
            //marks player as ready
            gameLogic.setReady(player: player.id, ready: true)
            
            //add to queue
            if player.id * gameLogic.fullAmount/2 >= playerQueue.count {
                for _ in 0 ... player.id * gameLogic.fullAmount/2 - playerQueue.count {
                    playerQueue.append((player: player, move: move))
                }
            }
            
            playerQueue[player.id * gameLogic.fullAmount/2] = (player: player, move: move)
        } else {
            if move.spell > -1 && move.source.multiSpells[move.spell].useCounter + move.source.manaUse > move.source.multiSpells[move.spell].uses {
                return false //spell cost is to high, fighter cannot use this spell
            }
            
            //marks player as ready
            gameLogic.setReady(player: player.id, ready: gameLogic.isPlayerReady(player: player))
            
            //add to queue
            if player.currentFighterId + player.id * gameLogic.fullAmount/2 >= playerQueue.count {
                for _ in 0 ... player.currentFighterId + player.id * gameLogic.fullAmount/2 - playerQueue.count {
                    playerQueue.append((player: player, move: move))
                }
            }
            
            playerQueue[player.currentFighterId + player.id * gameLogic.fullAmount/2] = (player: player, move: move)
        }
        
        /*for index in playerQueue.indices {
            if playerQueue[index].move.spell > -1 {
                print("player: \(playerQueue[index].player.id), source: " + playerQueue[index].move.source.name + ", target: " + playerQueue[index].move.target.name + ", index: \(playerQueue[index].move.index), spell: " + playerQueue[index].move.source.singleSpells[playerQueue[index].move.spell].name + ", type: " + playerQueue[index].move.type.rawValue)
            } else {
                print("player: \(playerQueue[index].player.id), source: " + playerQueue[index].move.source.name + ", target: " + playerQueue[index].move.target.name + ", index: \(playerQueue[index].move.index), spell: \(playerQueue[index].move.spell), type: " + playerQueue[index].move.type.rawValue)
            }
        }*/
        
        //CPU makes its move
        if hasCPUPlayer {
            if players[0].hasToSwap {
                backupLog.append(swapFighters(player: players[0], target: CPULogic.shared.getTarget(currentFighter: players[0].currentFighterId, fighters: players[0].fighters, enemyElement: players[1].getCurrentFighter().getElement(), hasToSwap: true, weather: weather)))
            }
            
            var rndmMove: Move
            if players[0].getCurrentFighter().lastSpell >= 0 {
                rndmMove = CPULogic.shared.getMove(player: players[0], target: players[1], weather: weather, lastSpell: players[0].getCurrentFighter().singleSpells[players[0].getCurrentFighter().lastSpell])
            } else {
                rndmMove = CPULogic.shared.getMove(player: players[0], target: players[1], weather: weather, lastSpell: nil)
            }
            
            //update target for swap
            if playerQueue[1].move.type == MoveType.swap && rndmMove.type == MoveType.spell {
                rndmMove.target = playerQueue[1].move.target
            }
            
            playerQueue[0] = (player: players[0], move: rndmMove)
        }
        
        //fight begins
        if gameLogic.areBothReady() || hasCPUPlayer {
            fighting = true
            fightLog = [Localization.shared.getTranslation(key: "loading")]
            
            //reset hasToSwap marker to prevent free swaps
            players[0].hasToSwap = false
            players[1].hasToSwap = false
            
            addTurns()
            
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
                                
                                players[0].currentFighterId = 0
                                if players[0].getCurrentFighter().currhp == 0 {
                                    players[0].goToNextFighter()
                                }
                                
                                players[1].currentFighterId = 0
                                if players[1].getCurrentFighter().currhp == 0 {
                                    players[1].goToNextFighter()
                                }
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                                AudioPlayer.shared.playStandardSound()
                                
                                gameLogic.setReady(player: 0, ready: false)
                                gameLogic.setReady(player: 1, ready: false)
                                gameLogic.clearSpells()
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
        if !singleMode {
            gameLogic.tempSpells[player.currentFighterId + player.id * gameLogic.fullAmount/2] = -1
            
            player.currentFighterId = 0
            while player.getCurrentFighter().currhp == 0 {
                player.goToNextFighter()
            }
        }
        
        gameLogic.setReady(player: player.id, ready: false)
    }
    
    /// Compares to fighters to determine who makes the first move
    /// - Parameters:
    ///   - fighterA: The first fighter
    ///   - fighterB: The second fighter
    /// - Returns: Returns wether the first fighter has priority or not
    func isFasterPlayer(fighterA: Int, fighterB: Int) -> Bool {
        //player wants to switch -> priority
        if playerQueue[fighterA].move.type == MoveType.swap {
            return true
        } else if playerQueue[fighterB].move.type == MoveType.swap {
            return false
        }
        
        let spellA: Spell
        let spellB: Spell
        
        if singleMode {
            spellA = playerQueue[fighterA].move.source.singleSpells[playerQueue[fighterA].move.spell]
            spellB = playerQueue[fighterB].move.source.singleSpells[playerQueue[fighterB].move.spell]
        } else {
            spellA = playerQueue[fighterA].move.source.multiSpells[playerQueue[fighterA].move.spell]
            spellB = playerQueue[fighterB].move.source.multiSpells[playerQueue[fighterB].move.spell]
        }
        
        //priority move goes first
        if spellA.priority > spellB.priority {
            return true
        } else if spellA.priority < spellB.priority {
            return false
        }
        
        //determine priority with using the agility stat of the fighters
        if playerQueue[fighterA].move.source.getModifiedBase(weather: weather).agility > playerQueue[fighterB].move.source.getModifiedBase(weather: weather).agility {
            return true
        } else if playerQueue[fighterB].move.source.getModifiedBase(weather: weather).agility > playerQueue[fighterA].move.source.getModifiedBase(weather: weather).agility {
            return false
        } else { //agility stat tie -> random player has priority
            return Bool.random()
        }
    }
    
    /// Plans whole fight in advance and adds the moves to the queue.
    private func addTurns() {
        //finalize move
        for index in playerQueue.indices {
            if playerQueue[index].move.type == MoveType.swap {
                continue
            }
            
            let moveSpell: Spell
            
            if singleMode {
                moveSpell = playerQueue[index].move.source.singleSpells[playerQueue[index].move.spell]
            } else {
                moveSpell = playerQueue[index].move.source.multiSpells[playerQueue[index].move.spell]
            }
            
            if playerQueue[index].move.type == MoveType.spell { //spell move can be overwritten by artifacts/hexes
                if playerQueue[index].move.source.lastSpell >= 0 && playerQueue[index].move.source.hasHex(hexName: Hexes.restricted.rawValue) {
                    playerQueue[index].move.spell = playerQueue[index].move.source.lastSpell
                } else if playerQueue[index].move.source.lastSpell >= 0 && playerQueue[index].move.source.getArtifact().name == Artifacts.armor.rawValue && weather?.name != Weather.volcanicStorm.rawValue {
                    playerQueue[index].move.spell = playerQueue[index].move.source.lastSpell
                } else if playerQueue[index].move.source.hasHex(hexName: Hexes.confused.rawValue) {
                    let randomIndex: Int
                    let randomSpell: Spell
                    
                    if singleMode {
                        randomIndex = Int.random(in: 0 ..< playerQueue[index].move.source.singleSpells.count)
                        randomSpell = playerQueue[index].move.source.singleSpells[randomIndex]
                    } else {
                        randomIndex = Int.random(in: 0 ..< playerQueue[index].move.source.multiSpells.count)
                        randomSpell = playerQueue[index].move.source.multiSpells[randomIndex]
                    }
                    
                    let randomMove: Move
                    let target: Int
                    
                    if randomSpell.subSpells[0].range == 0 {
                        randomMove = Move(source: playerQueue[index].move.source, index: -1, target: playerQueue[index].move.source, spell: randomIndex, type: MoveType.spell)
                    } else if randomSpell.subSpells[0].range == 1 {
                        target = Int.random(in: 0 ..< playerQueue[index].player.fighters.count)
                        randomMove = Move(source: playerQueue[index].move.source, index: -1, target: playerQueue[index].player.fighters[target], spell: randomIndex, type: MoveType.spell)
                    } else if index == 0 {
                        target = Int.random(in: 0 ..< players[1].fighters.count)
                        randomMove = Move(source: playerQueue[index].move.source, index: -1, target: players[1].fighters[target], spell: randomIndex, type: MoveType.spell)
                    } else {
                        target = Int.random(in: 0 ..< players[0].fighters.count)
                        randomMove = Move(source: playerQueue[index].move.source, index: -1, target: players[0].fighters[target], spell: randomIndex, type: MoveType.spell)
                    }
                    
                    playerQueue[index].move = randomMove
                }
                
                if moveSpell.typeID == 13 && playerQueue[index].move.source.lastSpell >= 0 { //check shield
                    if singleMode && playerQueue[index].move.source.singleSpells[playerQueue[index].move.source.lastSpell].typeID == 13 {
                        playerQueue[index].move.source.lastSpell = -2 //shield fails
                    } else if playerQueue[index].move.source.multiSpells[playerQueue[index].move.source.lastSpell].typeID == 13 {
                        playerQueue[index].move.source.lastSpell = -2 //shield fails
                    }
                } else if moveSpell.typeID != 10 { //prevent copy spell loop
                    if singleMode {
                        for spell in playerQueue[index].move.source.singleSpells.indices {
                            if playerQueue[index].move.source.singleSpells[spell].name == moveSpell.name {
                                playerQueue[index].move.source.lastSpell = spell
                                
                                break
                            }
                        }
                    } else {
                        for spell in playerQueue[index].move.source.multiSpells.indices {
                            if playerQueue[index].move.source.multiSpells[spell].name == moveSpell.name {
                                playerQueue[index].move.source.lastSpell = spell
                                
                                break
                            }
                        }
                    }
                }
            }
            
            if moveSpell.typeID == 10 { //player wants to copy last move
                if playerQueue[index].move.source.lastSpell >= 0 {
                    playerQueue[index].move.spell = playerQueue[index].move.source.lastSpell
                }
            }
            
            //targeted player will change because of swap
            if index > 0 && playerQueue[index - 1].move.type == MoveType.swap {
                if moveSpell.subSpells[0].range == 1 {
                    playerQueue[index].move.target = playerQueue[index - 1].move.target
                }
            }
            
            //increase use counter of spells
            playerQueue[index].move.useSpell(amount: playerQueue[index].move.source.manaUse, singleMode: singleMode)
        }
        
        //sort queue
        for i in 1 ..< playerQueue.count {
            var j: Int = i
            
            while j > 0 && isFasterPlayer(fighterA: j, fighterB: j - 1) {
                let temp = playerQueue[j]
                playerQueue[j] = playerQueue[j - 1]
                playerQueue[j - 1] = temp
                
                j -= 1
            }
        }
        
        var originalArr: [(player: Player, move: Move)] = []
        for playerMove in playerQueue {
            originalArr.append(playerMove)
        }
        
        var offset: Int = 0
        
        for index in 0 ..< gameLogic.fullAmount {
            //add moves for subspells
            if originalArr[index].move.type == MoveType.spell {
                if singleMode {
                    for n in originalArr[index].move.source.singleSpells[originalArr[index].move.spell].subSpells.indices {
                        if originalArr[index].move.source.singleSpells[originalArr[index].move.spell].subSpells[n].range ==  0 && originalArr[index].move.source.singleSpells[originalArr[index].move.spell].subSpells[0].range == 1 {
                            playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: originalArr[index].move.source, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                        } else {
                            playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: originalArr[index].move.target, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                        }
                        
                        offset += 1
                    }
                } else {
                    for n in originalArr[index].move.source.multiSpells[originalArr[index].move.spell].subSpells.indices {
                        if originalArr[index].move.source.multiSpells[originalArr[index].move.spell].subSpells[n].range == 1 {
                            playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: originalArr[index].move.target, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                        } else {
                            playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: originalArr[index].move.source, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                        }
                        offset += 1
                    }
                }
                
                //effect of sword artifact
                playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 0, target: originalArr[index].move.source, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 1)
                //effect of helmet artifact
                playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 1, target: originalArr[index].move.target, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 2)
                
                offset += 2
            }
            
            var oppositePlayer: Player = players[0]
            if originalArr[index].player.id == 0 {
                oppositePlayer = players[1]
            }
            
            //attacking fighter faints or exits the fight
            playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: -1, target: originalArr[index].move.source, spell: -1, type: MoveType.special)), at: index + offset + 1)
            offset += 1
            //attacked fighter faints or exits the fight
            playerQueue.insert((player: oppositePlayer, move: Move(source: originalArr[index].move.target, index: -1, target: originalArr[index].move.target, spell: -1, type: MoveType.special)), at: index + offset + 1)
            offset += 1

            //fighter receives hex effects
            if originalArr[index].move.type == MoveType.swap { //source & target will change because of swap
                for hex in 0 ..< 3 {
                    playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.target, index: hex, target: originalArr[index].move.target, spell: -1, type: MoveType.hex)), at: index + offset + 1)
                    offset += 1
                }
                
                //fighter receives artifact effects
                playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.target, index: -1, target: originalArr[index].move.target, spell: -1, type: MoveType.artifact)), at: index + offset + 1)
                offset += 1
            } else {
                for hex in 0 ..< 3 {
                    playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: hex, target: originalArr[index].move.source, spell: -1, type: MoveType.hex)), at: index + offset + 1)
                    offset += 1
                }
                
                //fighter receives artifact effects
                playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: -1, target: originalArr[index].move.source, spell: -1, type: MoveType.artifact)), at: index + offset + 1)
                offset += 1
            }
        }
    }
    
    /// Executes a move from the queue and skips unneccessary moves.
    /// - Parameters:
    ///   - player: The player that makes the move
    ///   - move: The move the player wants to make
    /// - Returns: Returns wether the move gets skipped or not
    private func startTurn(player: Player, move: Move) -> Bool {
        let attacker: Fighter = move.source
        
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
            
            if weather?.name != Weather.volcanicStorm.rawValue {
                if move.index < 0 {
                    if attacker.getArtifact().name != Artifacts.cornucopia.rawValue { //artifact has no effect
                        return true
                    } else if attacker.getArtifact().name == Artifacts.potion.rawValue && attacker.currhp > attacker.getModifiedBase().health/2 { //artifact has no effect yet
                        return true
                    }
                } else if move.index == 0 {
                    if singleMode {
                        if attacker.getArtifact().name != Artifacts.sword.rawValue || move.source.singleSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    } else {
                        if attacker.getArtifact().name != Artifacts.sword.rawValue || move.source.singleSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    }
                } else {
                    if singleMode {
                        if move.target.getArtifact().name != Artifacts.helmet.rawValue || move.source.singleSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    } else {
                        if move.target.getArtifact().name != Artifacts.helmet.rawValue || move.source.singleSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
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
                fightLog.append(swapFighters(player: player, target: move.index))
            }
        } else {
            fightLog.append(TurnLogic.shared.startTurn(player: player, fightLogic: self))
        }
        
        return false
    }
    
    /// Swaps two fighters.
    /// - Parameters:
    ///   - player: The player who wants to swap
    ///   - target: The index of the targeted fighter
    /// - Returns: Returns the description of what occured during the swap
    private func swapFighters(player: Player, target: Int) -> String {
        player.hasToSwap = false //flag no longer necessary
        
        var text: String
        
        if player.getCurrentFighter().getArtifact().name == Artifacts.grimoire.rawValue && weather?.name != Weather.volcanicStorm.rawValue {
            for hex in player.getCurrentFighter().hexes {
                player.getCurrentFighter().removeHex(hex: hex)
            }
        }
        
        text = Localization.shared.getTranslation(key: "swapWith", params: [player.getCurrentFighter().name, player.fighters[target].name]) + "\n"
        player.currentFighterId = target
        
        //heal new fighter after making a wish
        if player.wishActivated && player.getCurrentFighter().currhp < player.getCurrentFighter().getModifiedBase().health {
            player.getCurrentFighter().currhp = player.getCurrentFighter().getModifiedBase().health
            
            text += Localization.shared.getTranslation(key: "gainedHP", params: [player.getCurrentFighter().name]) + "\n"
            
            player.wishActivated = false
        }
        
        var oppositePlayer: Player = players[0]
        if player.id == 0 {
            oppositePlayer = players[1]
        }
        
        //apply artifact effect
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
