//
//  PlayerQueue.swift
//  Elementary
//
//  Created by Janice Hablützel on 27.01.23.
//

/// Keeps track of player moves.
class PlayerQueue {
    var singleMode: Bool
    var queue: [(player: Player, move: Move)] = []
    
    private var startCount: Int = 0
    
    /// Create a queue to keep track of player moves.
    /// - Parameters:
    ///   - singleMode: Indicates single mode or group mode
    ///   - players: The players making the moves
    init(singleMode: Bool, players: [Player]) {
        self.singleMode = singleMode
        startCount = 0
        
        queue.append(contentsOf: createSwapTurns(player: players[0], fighter: 0, oppositePlayer: players[1], weather: nil))
        queue.append(contentsOf: createSwapTurns(player: players[1], fighter: 0, oppositePlayer: players[0], weather: nil))
    }
    
    /// Creates artifact turns that activate when swapping.
    /// - Parameters:
    ///   - player: The player who swapped
    ///   - fighter: The index of the fighter
    ///   - oppositePlayer: The opposite player
    ///   - weather: The current weather of the fight
    /// - Returns: Returns artifact turns that were created when swapping
    func createSwapTurns(player: Player, fighter: Int, oppositePlayer: Player, weather: Hex?) -> [(player: Player, move: Move)] {
        var swapQueue: [(player: Player, move: Move)] = []
        
        if weather?.name == Weather.mysticWeather.rawValue {
            return swapQueue
        }
        
        if singleMode {
            //apply effect of artifact on "entering"
            if player.getFighter(index: fighter).getArtifact().name == Artifacts.mask.rawValue && weather?.name != Weather.springWeather.rawValue {
                swapQueue.append((player: player, move: Move(source: player.currentFighterId, index: 1, target: oppositePlayer.currentFighterId, targetedPlayer: oppositePlayer.id, spell: -1, type: MoveType.swap)))
            } else if player.getFighter(index: fighter).getArtifact().name == Artifacts.grimoire.rawValue {
                swapQueue.append((player: player, move: Move(source: player.currentFighterId, index: 2, target: player.currentFighterId, targetedPlayer: player.id, spell: -1, type: MoveType.swap)))
            }
        } else {
            for fighter in player.fighterOrder {
                //apply effect of artifact on "entering"
                if player.getFighter(index: fighter).getArtifact().name == Artifacts.mask.rawValue && weather?.name != Weather.springWeather.rawValue {
                    for target in oppositePlayer.fighters.indices {
                        swapQueue.append((player: player, move: Move(source: fighter, index: 1, target: target, targetedPlayer: oppositePlayer.id, spell: -1, type: MoveType.swap)))
                    }
                } else if player.getFighter(index: fighter).getArtifact().name == Artifacts.grimoire.rawValue {
                    swapQueue.append((player: player, move: Move(source: fighter, index: 2, target: fighter, targetedPlayer: player.id, spell: -1, type: MoveType.swap)))
                }
            }
        }
        
        startCount += swapQueue.count
        
        return swapQueue
    }
    
    /// Adds a player move to the queue or rejects it.
    /// - Parameters:
    ///   - player: The player making the move
    ///   - move: The move the player makes
    ///   - oppositePlayer: The opposite player
    ///   - fighterAmount: The amount of fighters able to make a move
    ///   - weather: The current weather of the fight
    /// - Returns: Returns wether the move was added or not
    func addToQueue(player: Player, move: Move, oppositePlayer: Player, fighterAmount: Int, weather: Hex?) -> Bool {
        if move.type == MoveType.swap {
            let index: Int = startCount
            queue.insert(contentsOf: createSwapTurns(player: player, fighter: move.target, oppositePlayer: oppositePlayer, weather: weather), at: index)
        }
            
        if singleMode {
            if move.spell > -1 && player.getFighter(index: move.source).singleSpells[move.spell].useCounter + player.getFighter(index: move.source).manaUse > player.getFighter(index: move.source).singleSpells[move.spell].uses {
                return false //spell cost is to high, fighter cannot use this spell
            }
            
            //add to queue
            if player.id + startCount >= queue.count {
                for _ in 0 ... player.id + startCount - queue.count {
                    queue.append((player: Player(id: -1, fighters: []), move: move))
                }
            }
            
            queue[player.id + startCount] = (player: player, move: move)
        } else {
            if move.spell > -1 && player.getFighter(index: move.source).multiSpells[move.spell].useCounter + player.getFighter(index: move.source).manaUse > player.getFighter(index: move.source).multiSpells[move.spell].uses {
                return false //spell cost is to high, fighter cannot use this spell
            }
            
            //add to queue
            if player.currentFighterId + player.id * fighterAmount + startCount >= queue.count {
                for _ in 0 ... player.currentFighterId + player.id * fighterAmount + startCount - queue.count {
                    queue.append((player: Player(id: -1, fighters: []), move: move))
                }
            }
            
            queue[player.currentFighterId + player.id * fighterAmount + startCount] = (player: player, move: move)
        }
        
        return true
    }
    
    /// Remove player moves that are unused because fighter has fainted a long time ago.
    func cleanQueue() {
        startCount = 0
        
        var tempQueue: [(player: Player, move: Move)] = []
        
        for index in queue.indices {
            if queue[index].player.id > -1 {
                tempQueue.append(queue[index])
            }
        }
        
        queue = tempQueue
    }
    
    /// Finalize all player spells, increase spell use counter and update fighters last spells.
    /// - Parameters:
    ///   - players: The players fighting
    ///   - weather: The current weather of the fight
    func finalizeMoves(players: [Player], weather: Hex?) {
        for index in queue.indices {
            if queue[index].move.type == MoveType.swap {
                continue
            }
            
            let source: Fighter = queue[index].player.getFighter(index: queue[index].move.source)
            let moveSpell: Spell
            
            if singleMode {
                moveSpell = source.singleSpells[queue[index].move.spell]
            } else {
                moveSpell = source.multiSpells[queue[index].move.spell]
            }
            
            if queue[index].move.type == MoveType.spell { //spell move can be overwritten by artifacts/hexes
                if source.lastSpell >= 0 && source.hasHex(hexName: Hexes.restricted.rawValue) {
                    queue[index].move.spell = source.lastSpell
                } else if source.lastSpell >= 0 && source.getArtifact().name == Artifacts.armor.rawValue && weather?.name != Weather.mysticWeather.rawValue {
                    queue[index].move.spell = source.lastSpell
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
                        randomMove = Move(source: queue[index].move.source, index: -1, target: queue[index].move.source, targetedPlayer: queue[index].player.id, spell: randomIndex, type: MoveType.spell)
                    } else {
                        target = Int.random(in: 0 ..< players[queue[index].player.getOppositePlayerId()].fighters.count)
                        randomMove = Move(source: queue[index].move.source, index: -1, target: target, targetedPlayer: players[queue[index].player.getOppositePlayerId()].id, spell: randomIndex, type: MoveType.spell)
                    }
                    
                    queue[index].move = randomMove
                }
                
                //update last spell
                if moveSpell.typeID == 13 && source.lastSpell >= 0 { //check shield
                    if singleMode && source.singleSpells[source.lastSpell].typeID == 13 {
                        source.lastSpell = -2 //shield fails
                    } else if source.multiSpells[source.lastSpell].typeID == 13 {
                        source.lastSpell = -2 //shield fails
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
                } else {
                    if singleMode {
                        for spell in source.singleSpells.indices { //spell could be overwritten -> search
                            if source.singleSpells[spell].name == moveSpell.name {
                                if source.lastSpell == -1 && moveSpell.typeID == 10 {
                                    source.lastSpell = -3
                                } else {
                                    source.lastSpell = spell
                                }
                                break
                            }
                        }
                    } else {
                        for spell in source.multiSpells.indices { //spell could be overwritten -> search
                            if source.multiSpells[spell].name == moveSpell.name {
                                if source.lastSpell == -1 && moveSpell.typeID == 10 {
                                    source.lastSpell = -3
                                } else {
                                    source.lastSpell = spell
                                }
                                break
                            }
                        }
                    }
                }
            }
            
            //increase use counter of spells
            queue[index].move.useSpell(fighter: source, singleMode: singleMode)
        }
    }
    
    /// Compares to fighters to determine who makes the first move
    /// - Parameters:
    ///   - playerMoveA: The player move to compare to
    ///   - playerMoveB: The player move to be compared
    ///   - weather: The current weather of the fight
    /// - Returns: Returns wether the first fighter has priority or not
    private func isFasterFighter(playerMoveA: (player: Player, move: Move), playerMoveB: (player: Player, move: Move), weather: Hex?) -> Bool {
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
        
        var priorityA: Int = spellA.priority
        var priorityB: Int = spellB.priority
        
        if fighterA.getArtifact().name == Artifacts.hat.rawValue {
            priorityA += 7
        }
        if fighterA.getArtifact().name == Artifacts.hat.rawValue {
            priorityB += 7
        }
        
        //priority move goes first
        if priorityA > priorityB {
            return true
        } else if priorityA < priorityB {
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
    /// - Parameters:
    ///   - players: The players fighting
    ///   - weather: The current weather of the fight
    func addTurns(players: [Player], weather: Hex?) {
        //order queue
        for i in 1 ..< queue.count {
            var j: Int = i
            
            while j > 0 && isFasterFighter(playerMoveA: queue[j], playerMoveB: queue[j - 1], weather: weather) {
                let temp: (player: Player, move: Move) = queue[j]
                queue[j] = queue[j - 1]
                queue[j - 1] = temp
                
                j -= 1
            }
        }
        
        var originalArr: [(player: Player, move: Move)] = []
        for playerMove in queue {
            originalArr.append(playerMove)
        }
        
        var offset: Int = 0
        
        for index in 0 ..< originalArr.count {
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
                        queue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: originalArr[index].move.source, targetedPlayer: originalArr[index].player.id, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                        
                        offset += 1
                    } else {
                        if !singleMode && spell.range == 2 {
                            for fighter in originalArr[index].player.fighters.indices {
                                queue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: fighter, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                                
                                offset += 1
                            }
                        } else if !singleMode && spell.range == 4 {
                            for fighter in oppositePlayer.fighters.indices {
                                queue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: fighter, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                                
                                offset += 1
                            }
                        } else {
                            queue.insert((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: n, target: originalArr[index].move.target, targetedPlayer: originalArr[index].move.targetedPlayer, spell: originalArr[index].move.spell, type: originalArr[index].move.type)), at: index + offset + 1)
                            
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
                                    for m in index + offset ..< queue.count {
                                        if queue[m].player.id != originalArr[index].player.id {
                                            if source.multiSpells[queue[m].move.spell].range >= 3 {
                                                queue[m].move.target = originalArr[index].move.target
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if !singleMode && spell.range == 2 {
                    for fighter in originalArr[index].player.fighters.indices {
                        offset = addSpecialTurns(playerMove: originalArr[index], fighter: fighter, oppositePlayer: originalArr[index].player, index: index, currentOffset: offset)
                    }
                } else if !singleMode && spell.range == 4 {
                    for fighter in oppositePlayer.fighters.indices {
                        offset = addSpecialTurns(playerMove: originalArr[index], fighter: fighter, oppositePlayer: oppositePlayer, index: index, currentOffset: offset)
                    }
                } else if spell.range >= 3 {
                    offset = addSpecialTurns(playerMove: originalArr[index], fighter: originalArr[index].move.target, oppositePlayer: oppositePlayer, index: index, currentOffset: offset)
                } else {
                    offset = addSpecialTurns(playerMove: originalArr[index], fighter: originalArr[index].move.target, oppositePlayer: originalArr[index].player, index: index, currentOffset: offset)
                }
            }
            
            for hex in 0 ..< 3 {
                queue.append((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: hex, target: originalArr[index].move.source, targetedPlayer: originalArr[index].player.id, spell: -1, type: MoveType.hex)))
            }
            
            //fighter receives artifact effects
            queue.append((player: originalArr[index].player, move: Move(source: originalArr[index].move.source, index: -1, target: originalArr[index].move.source, targetedPlayer: originalArr[index].player.id, spell: -1, type: MoveType.artifact)))
        }
    }
    
    /// Add artifact and fainting/leaving moves to player queue.
    /// - Parameters:
    ///   - playerMove: The current player move
    ///   - fighter: The id of the current fighter
    ///   - oppositePlayer: The opposite player
    ///   - index: The index of the current player move
    ///   - currentOffset: The current offset to correctly insert move into the queue
    private func addSpecialTurns(playerMove: (player: Player, move: Move), fighter: Int, oppositePlayer: Player, index: Int, currentOffset: Int) -> Int {
        var offset: Int = currentOffset
        
        //effect of sword artifact
        queue.insert((player: playerMove.player, move: Move(source: playerMove.move.source, index: 0, target: playerMove.move.source, targetedPlayer: playerMove.player.id, spell: playerMove.move.spell, type: MoveType.artifact)), at: index + offset + 1)
        //effect of helmet artifact
        queue.insert((player: playerMove.player, move: Move(source: playerMove.move.source, index: 1, target: fighter, targetedPlayer: playerMove.move.targetedPlayer, spell: playerMove.move.spell, type: MoveType.artifact)), at: index + offset + 2)
        
        offset += 2
        
        //attacking fighter faints or exits the fight
        queue.insert((player: playerMove.player, move: Move(source: playerMove.move.source, index: -1, target: playerMove.move.source, targetedPlayer: playerMove.player.id, spell: -1, type: MoveType.special)), at: index + offset + 1)
        offset += 1
        //effect of thread artifact
        queue.insert((player: playerMove.player, move: Move(source: playerMove.move.source, index: 2, target: fighter, targetedPlayer: playerMove.move.targetedPlayer, spell: playerMove.move.spell, type: MoveType.artifact)), at: index + offset + 1)
        offset += 1
        
        //attacking fighter faints or exits the fight
        queue.insert((player: playerMove.player, move: Move(source: playerMove.move.source, index: -1, target: playerMove.move.source, targetedPlayer: playerMove.player.id, spell: -1, type: MoveType.special)), at: index + offset + 1)
        offset += 1
        
        //attacked fighter faints or exits the fight
        queue.insert((player: oppositePlayer, move: Move(source: playerMove.move.target, index: -1, target: fighter, targetedPlayer: playerMove.move.targetedPlayer, spell: -1, type: MoveType.special)), at: index + offset + 1)
        offset += 1
        
        if !singleMode {
            for fghter in playerMove.player.fighters.indices {
                //effect of book artifact
                queue.insert((player: playerMove.player, move: Move(source: fghter, index: 3, target: fighter, targetedPlayer: playerMove.move.targetedPlayer, spell: playerMove.move.spell, type: MoveType.artifact)), at: index + offset + 1)
                offset += 1
            }
        } else {
            //effect of book artifact
            queue.insert((player: playerMove.player, move: Move(source: playerMove.move.source, index: 3, target: fighter, targetedPlayer: playerMove.move.targetedPlayer, spell: playerMove.move.spell, type: MoveType.artifact)), at: index + offset + 1)
            offset += 1
        }
        
        return offset
    }
    
}
