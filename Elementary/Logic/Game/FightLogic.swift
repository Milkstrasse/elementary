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
                if move.type == MoveType.swap {
                    backupLog.append(player.swapFighters(target: move.index, fightLogic: self))
                }
                
                return false //action is free, new fighter can make a move
            }
        }
        
        if singleMode {
            if move.spell > -1 && player.getFighter(index: move.source).singleSpells[move.spell].useCounter + player.getFighter(index: move.source).manaUse > player.getFighter(index: move.source).singleSpells[move.spell].uses {
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
            if move.spell > -1 && player.getFighter(index: move.source).multiSpells[move.spell].useCounter + player.getFighter(index: move.source).manaUse > player.getFighter(index: move.source).multiSpells[move.spell].uses {
                return false //spell cost is to high, fighter cannot use this spell
            }
            
            //marks player as ready
            gameLogic.setReady(player: player.id, ready: player.isAtLastFighter(index: move.source))
            
            //add to queue
            if player.currentFighterId + player.id * gameLogic.fullAmount/2 >= playerQueue.count {
                for _ in 0 ... player.currentFighterId + player.id * gameLogic.fullAmount/2 - playerQueue.count {
                    playerQueue.append((player: player, move: move))
                }
            }
            
            playerQueue[player.currentFighterId + player.id * gameLogic.fullAmount/2] = (player: player, move: move)
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
    
    /// Compares to fighters to determine who makes the first move
    /// - Parameters:
    ///   - playerMoveA: The player move to compare to
    ///   - playerMoveB: The player move to be compared
    /// - Returns: Returns wether the first fighter has priority or not
    func isFasterFighter(playerMoveA: (player: Player, move: Move), playerMoveB: (player: Player, move: Move)) -> Bool {
        //player wants to switch -> priority
        if playerMoveA.move.type == MoveType.swap {
            return true
        } else if playerMoveB.move.type == MoveType.swap {
            return false
        }
        
        let fighterA: Fighter = playerMoveA.player.getFighter(index: playerMoveA.move.source)
        let fighterB: Fighter = playerMoveB.player.getFighter(index: playerMoveB.move.source)
        
        let spellA: Spell
        let spellB: Spell
        
        if singleMode {
            spellA = fighterA.singleSpells[playerMoveA.move.spell]
            spellB = fighterB.singleSpells[playerMoveB.move.spell]
        } else {
            spellA = fighterA.multiSpells[playerMoveA.move.spell]
            spellB = fighterB.multiSpells[playerMoveB.move.spell]
        }
        
        //priority move goes first
        if spellA.priority > spellB.priority {
            return true
        } else if spellA.priority < spellB.priority {
            return false
        }
        
        //determine priority with using the agility stat of the fighters
        if fighterA.getModifiedBase(weather: weather).agility > fighterB.getModifiedBase(weather: weather).agility {
            return true
        } else if fighterB.getModifiedBase(weather: weather).agility > fighterA.getModifiedBase(weather: weather).agility {
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
            
            let source: Fighter = playerQueue[index].player.getFighter(index: playerQueue[index].move.source)
            let moveSpell: Spell
            
            if singleMode {
                moveSpell = source.singleSpells[playerQueue[index].move.spell]
            } else {
                moveSpell = source.multiSpells[playerQueue[index].move.spell]
            }
            
            if playerQueue[index].move.type == MoveType.spell { //spell move can be overwritten by artifacts/hexes
                if source.lastSpell >= 0 && source.hasHex(hexName: Hexes.restricted.rawValue) {
                    playerQueue[index].move.spell = source.lastSpell
                } else if source.lastSpell >= 0 && source.getArtifact().name == Artifacts.armor.rawValue && weather?.name != Weather.volcanicStorm.rawValue {
                    playerQueue[index].move.spell = source.lastSpell
                } else if source.hasHex(hexName: Hexes.confused.rawValue) {
                    let randomIndex: Int
                    let randomSpell: Spell
                    
                    if singleMode {
                        randomIndex = Int.random(in: 0 ..< source.singleSpells.count)
                        randomSpell = source.singleSpells[randomIndex]
                    } else {
                        randomIndex = Int.random(in: 0 ..< source.multiSpells.count)
                        randomSpell = source.multiSpells[randomIndex]
                    }
                    
                    let randomMove: Move
                    let target: Int
                    
                    if randomSpell.range < 3 {
                        randomMove = Move(source: playerQueue[index].move.source, index: -1, target: playerQueue[index].move.source, targetedPlayer: playerQueue[index].player.id, spell: randomIndex, type: MoveType.spell)
                    } else {
                        target = Int.random(in: 0 ..< players[playerQueue[index].player.getOppositePlayerId()].fighters.count)
                        randomMove = Move(source: playerQueue[index].move.source, index: -1, target: target, targetedPlayer: players[playerQueue[index].player.getOppositePlayerId()].id, spell: randomIndex, type: MoveType.spell)
                    }
                    
                    playerQueue[index].move = randomMove
                }
                
                //update last spell
                if moveSpell.typeID == 13 && source.lastSpell >= 0 { //check shield
                    if singleMode && source.singleSpells[source.lastSpell].typeID == 13 {
                        source.lastSpell = -2 //shield fails
                    } else if source.multiSpells[source.lastSpell].typeID == 13 {
                        source.lastSpell = -2 //shield fails
                    }
                } else {
                    if singleMode {
                        for spell in source.singleSpells.indices { //spell could be overwritten -> search
                            if source.singleSpells[spell].name == moveSpell.name {
                                source.lastSpell = spell
                                break
                            }
                        }
                    } else {
                        for spell in source.multiSpells.indices { //spell could be overwritten -> search
                            if source.multiSpells[spell].name == moveSpell.name {
                                source.lastSpell = spell
                                break
                            }
                        }
                    }
                }
            }
            
            //increase use counter of spells
            playerQueue[index].move.useSpell(fighter: source, singleMode: singleMode)
        }
        
        //sort queue
        for i in 1 ..< playerQueue.count {
            var j: Int = i
            
            while j > 0 && isFasterFighter(playerMoveA: playerQueue[j], playerMoveB: playerQueue[j - 1]) {
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
            let source: Fighter = originalArr[index].player.getFighter(index: originalArr[index].move.source)
            
            //add moves for subspells
            if originalArr[index].move.type == MoveType.spell {
                let oppositePlayer: Player = players[originalArr[index].player.getOppositePlayerId()]
                
                let spell: Spell
                if singleMode {
                    spell = source.singleSpells[originalArr[index].move.spell]
                } else {
                    spell = source.multiSpells[originalArr[index].move.spell]
                }
                
                for n in spell.subSpells.indices {
                    if spell.range == 0 || spell.subSpells[n].range == 0 {
                        playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: originalArr[index].move.source, targetedPlayer: originalArr[index].player.id, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                        
                        offset += 1
                    } else {
                        if !singleMode && spell.range == 2 {
                            for fighter in originalArr[index].player.fighters.indices {
                                playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: fighter, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                                
                                offset += 1
                            }
                        } else if !singleMode && spell.range == 4 {
                            for fighter in oppositePlayer.fighters.indices {
                                playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: fighter, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                                
                                offset += 1
                            }
                        } else {
                            playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: originalArr[index].move.target, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                            
                            offset += 1
                        }
                    }
                }
                
                if !singleMode {
                    if source.multiSpells[originalArr[index].move.spell].typeID == 21 { //change target
                        for n in originalArr.indices {
                            if originalArr[n].player.id != originalArr[index].player.id {
                                if source.multiSpells[originalArr[n].move.spell].range >= 3 {
                                    originalArr[n].move.target = originalArr[index].move.target
                                    playerQueue[playerQueue.count - originalArr.count + n].move.target = originalArr[index].move.target
                                }
                            }
                        }
                    }
                }
                
                if !singleMode && spell.range == 2 {
                    for fighter in originalArr[index].player.fighters.indices {
                        //effect of sword artifact
                        playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 0, target: originalArr[index].move.source, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 1)
                        //effect of helmet artifact
                        playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 1, target: fighter, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 2)
                        
                        offset += 2
                        
                        //attacking fighter faints or exits the fight
                        playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: -1, target: originalArr[index].move.source, targetedPlayer: originalArr[index].player.id, spell: -1, type: MoveType.special)), at: index + offset + 1)
                        offset += 1
                        //effect of thread artifact
                        playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 2, target: fighter, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 1)
                        offset += 1
                        //attacked fighter faints or exits the fight
                        playerQueue.insert((player: oppositePlayer, move: Move(source: originalArr[index].move.target, index: -1, target: fighter, targetedPlayer: originalArr[index].move.targetedPlayer, spell: -1, type: MoveType.special)), at: index + offset + 1)
                        offset += 1
                    }
                } else if !singleMode && spell.range == 4 {
                    for fighter in oppositePlayer.fighters.indices {
                        //effect of sword artifact
                        playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 0, target: originalArr[index].move.source, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 1)
                        //effect of helmet artifact
                        playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 1, target: fighter, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 2)
                        
                        offset += 2
                        
                        //attacking fighter faints or exits the fight
                        playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: -1, target: originalArr[index].move.source, targetedPlayer: originalArr[index].player.id, spell: -1, type: MoveType.special)), at: index + offset + 1)
                        offset += 1
                        //effect of thread artifact
                        playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 2, target: fighter, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 1)
                        offset += 1
                        //attacked fighter faints or exits the fight
                        playerQueue.insert((player: oppositePlayer, move: Move(source: originalArr[index].move.target, index: -1, target: fighter, targetedPlayer: originalArr[index].move.targetedPlayer, spell: -1, type: MoveType.special)), at: index + offset + 1)
                        offset += 1
                    }
                } else {
                    //effect of sword artifact
                    playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 0, target: originalArr[index].move.source, targetedPlayer: originalArr[index].player.id, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 1)
                    //effect of helmet artifact
                    playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 1, target: originalArr[index].move.target, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 2)
                    
                    offset += 2
                    
                    //attacking fighter faints or exits the fight
                    playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: -1, target: originalArr[index].move.source, targetedPlayer: originalArr[index].player.id, spell: -1, type: MoveType.special)), at: index + offset + 1)
                    offset += 1
                    //effect of thread artifact
                    playerQueue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: 2, target: originalArr[index].move.target, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: MoveType.artifact)), at: index + offset + 1)
                    offset += 1
                    //attacked fighter faints or exits the fight
                    playerQueue.insert((player: oppositePlayer, move: Move(source: originalArr[index].move.target, index: -1, target: originalArr[index].move.target, targetedPlayer: originalArr[index].move.targetedPlayer, spell: -1, type: MoveType.special)), at: index + offset + 1)
                    offset += 1
                }
            }
            
            for hex in 0 ..< 3 {
                playerQueue.append((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: hex, target: originalArr[index].move.source, targetedPlayer: originalArr[index].player.id, spell: -1, type: MoveType.hex)))
            }
            
            //fighter receives artifact effects
            playerQueue.append((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: -1, target: originalArr[index].move.source, targetedPlayer: originalArr[index].player.id, spell: -1, type: MoveType.artifact)))
        }
        
        /*for index in playerQueue.indices {
            if singleMode {
                if playerQueue[index].move.spell > -1 {
                    print("player: \(playerQueue[index].player.id), source: \(playerQueue[index].move.source), target: \(playerQueue[index].move.target), targetedPlayer: \(playerQueue[index].move.targetedPlayer), index: \(playerQueue[index].move.index), spell: " + playerQueue[index].player.fighters[playerQueue[index].move.source].singleSpells[playerQueue[index].move.spell].name + ", type: " + playerQueue[index].move.type.rawValue)
                } else {
                    print("player: \(playerQueue[index].player.id), source: \(playerQueue[index].move.source), target: \(playerQueue[index].move.target), targetedPlayer: \(playerQueue[index].move.targetedPlayer), index: \(playerQueue[index].move.index), spell: \(playerQueue[index].move.spell), type: " + playerQueue[index].move.type.rawValue)
                }
            } else {
                if playerQueue[index].move.spell > -1 {
                    print("player: \(playerQueue[index].player.id), source: \(playerQueue[index].move.source), target: \(playerQueue[index].move.target), targetedPlayer: \(playerQueue[index].move.targetedPlayer), index: \(playerQueue[index].move.index), spell: " + playerQueue[index].player.fighters[playerQueue[index].move.source].multiSpells[playerQueue[index].move.spell].name + ", type: " + playerQueue[index].move.type.rawValue)
                } else {
                    print("player: \(playerQueue[index].player.id), source: \(playerQueue[index].move.source), target: \(playerQueue[index].move.target), targetedPlayer: \(playerQueue[index].move.targetedPlayer), index: \(playerQueue[index].move.index), spell: \(playerQueue[index].move.spell), type: " + playerQueue[index].move.type.rawValue)
                }
            }
        }*/
    }
    
    /// Executes a move from the queue and skips unneccessary moves.
    /// - Parameters:
    ///   - player: The player that makes the move
    ///   - move: The move the player wants to make
    /// - Returns: Returns wether the move gets skipped or not
    private func startTurn(player: Player, move: Move) -> Bool {
        let oppositePlayer: Player = players[player.getOppositePlayerId()]
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
            
            let target: Fighter = oppositePlayer.getFighter(index: move.target)
            
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
