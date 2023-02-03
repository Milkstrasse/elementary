//
//  CPULogic.swift
//  Elementary
//
//  Created by Janice Hablützel on 15.01.22.
//

/// This is the logic that determines the best possible move or target for a swap.
struct CPULogic {
    static let shared: CPULogic = CPULogic()
    
    /// Determines the best move for the CPU.
    /// - Parameters:
    ///   - player: The current player
    ///   - target: The opponent player
    ///   - weather: The current weather of the fight
    ///   - lastSpell: The last spell of the fighter
    /// - Returns: Returns the best move
    func getMove(player: Player, target: Player, weather: Hex?, lastSpell: Spell?) -> Move {
        let attacker: Fighter = player.getCurrentFighter()
        var defender: Fighter = target.getCurrentFighter()
        
        //collect all useable spells
        var availableSpells: [Int] = []
        
        for index in attacker.singleSpells.indices {
            if attacker.singleSpells[index].useCounter + attacker.manaUse <= attacker.singleSpells[index].uses {
                availableSpells.append(index)
            }
        }
        
        //no moves found
        if availableSpells.isEmpty {
            if player.isAbleToSwap() && getTarget(currentFighter: player.currentFighterId, player: player, enemyElement: defender.getElement(), hasToSwap: false, weather: weather) != player.currentFighterId {
                return createSwapMove(player: player, target: target, weather: weather)
            } else {
                return Move(source: player.currentFighterId, index: -1, target: target.currentFighterId, targetedPlayer: target.id, spell: 0, type: MoveType.spell)
            }
        }
        
        //fighter is restricted -> use best move
        if (attacker.getArtifact().name == Artifacts.armor.rawValue && weather?.name != Weather.volcanicStorm.rawValue) || attacker.hasHex(hexName: Hexes.restricted.rawValue) {
            if attacker.getElement().hasDisadvantage(element: defender.getElement(), weather: weather) && player.isAbleToSwap() {
                if !attacker.hasHex(hexName: Hexes.chained.rawValue) && getTarget(currentFighter: player.currentFighterId, player: player, enemyElement: defender.getElement(), hasToSwap: false, weather: weather) != player.currentFighterId {
                    return createSwapMove(player: player, target: target, weather: weather)
                }
            }
            
            var bestSpell: (Float, Int)
            bestSpell = (calcDamage(attacker: attacker, defender: defender, spell: attacker.singleSpells[availableSpells[0]], weather: weather), 0)
            
            for index in 1 ..< availableSpells.count {
                if attacker.singleSpells[availableSpells[index]].typeID < 10 {
                    let dmg: Float = calcDamage(attacker: attacker, defender: defender, spell: attacker.singleSpells[availableSpells[index]], weather: weather)
                    if dmg > bestSpell.0 {
                        bestSpell = (dmg, index)
                    }
                }
            }
            
            if  attacker.singleSpells[bestSpell.1].typeID < 10 {
                return Move(source: player.currentFighterId, index: -1, target: target.currentFighterId, targetedPlayer: target.id, spell: bestSpell.1, type: MoveType.spell)
            }
        }
        
        //predict if target will swap
        var rndm: Int = Int.random(in: 0 ..< 1)
        if rndm > 0 {
            if defender.getElement().hasDisadvantage(element: attacker.getElement(), weather: weather) && target.isAbleToSwap() {
                let newFighter: Int = getTarget(currentFighter: target.currentFighterId, player: target, enemyElement: attacker.getElement(), hasToSwap: target.hasToSwap, weather: weather)
                if newFighter != target.currentFighterId {
                    defender = target.getFighter(index: newFighter)
                }
            }
        }
        
        //top priority: find move that defeats the enemy fighter!
        for spell in availableSpells {
            if attacker.singleSpells[spell].typeID < 11 {
                if DamageCalculator.shared.willDefeatFighter(attacker: attacker, defender: defender, spell: attacker.singleSpells[spell], subSpell: attacker.singleSpells[spell].subSpells[0], spellElement: attacker.singleSpells[spell].element, weather: weather) {
                    return Move(source: player.currentFighterId, index: -1, target: target.currentFighterId, targetedPlayer: target.id, spell: spell, type: MoveType.spell)
                }
            }
        }
        
        //avoid fighting against advantaged enemy
        if attacker.getElement().hasDisadvantage(element: defender.getElement(), weather: weather) {
            if attacker.getModifiedBase(weather: weather).agility > defender.getModifiedBase(weather: weather).agility { //disable or flip elemental check
                for spell in availableSpells {
                    if attacker.singleSpells[spell].typeID == 11 {
                        if attacker.singleSpells[spell].subSpells[0].weather! == "magneticStorm" || attacker.singleSpells[spell].subSpells[0].weather! == "denseFog" {
                            if Weather.isBeneficial(weather: attacker.singleSpells[spell].subSpells[0].weather!, attacker: attacker, defender: target.getCurrentFighter()) {
                                return Move(source: player.currentFighterId, index: -1, target: player.currentFighterId, targetedPlayer: player.id, spell: spell, type: MoveType.spell)
                            }
                        }
                    }
                }
                
                if target.isAbleToSwap() { //force out
                    for spell in availableSpells {
                        if attacker.singleSpells[spell].typeID == 15 {
                            return Move(source: player.currentFighterId, index: -1, target: target.currentFighterId, targetedPlayer: target.id, spell: spell, type: MoveType.spell)
                        }
                    }
                }
            } else if player.isAbleToSwap() { //swap
                if !attacker.hasHex(hexName: Hexes.chained.rawValue) && getTarget(currentFighter: player.currentFighterId, player: player, enemyElement: defender.getElement(), hasToSwap: false, weather: weather) != player.currentFighterId {
                    return createSwapMove(player: player, target: target, weather: weather)
                }
            }
        }
        
        //low health -> should heal
        if attacker.currhp <= attacker.getModifiedBase().health/3 && !attacker.hasHex(hexName: Hexes.cursed.rawValue) {
            for spell in availableSpells {
                if attacker.singleSpells[spell].typeID == 12 {
                    return Move(source: player.currentFighterId, index: -1, target: player.currentFighterId, targetedPlayer: player.id, spell: spell, type: MoveType.spell)
                }
            }
        }
        
        //have control over weather since the weather boosts certain attacks
        rndm = Int.random(in: 0 ..< 3)
        if rndm > 0 {
            for spell in availableSpells {
                if attacker.singleSpells[spell].typeID == 11 {
                    if Weather.isBeneficial(weather: attacker.singleSpells[spell].subSpells[0].weather!, attacker: attacker, defender: target.getCurrentFighter()) && weather?.name != attacker.singleSpells[spell].subSpells[0].weather! {
                        return Move(source: player.currentFighterId, index: -1, target: player.currentFighterId, targetedPlayer: player.id, spell: spell, type: MoveType.spell)
                    }
                }
            }
        }
        
        //consider using shield
        if defender.getHexDuration(hexName: Hexes.poisoned.rawValue) > 0 || attacker.getHexDuration(hexName: Hexes.healed.rawValue) > 0 {
            if lastSpell == nil || lastSpell!.typeID != 13 {
                for spell in availableSpells {
                    if attacker.singleSpells[spell].typeID == 13 {
                        return Move(source: player.currentFighterId, index: -1, target: player.currentFighterId, targetedPlayer: player.id, spell: spell, type: MoveType.spell)
                    }
                }
            }
        }
        
        //consider using a hex
        rndm = Int.random(in: 0 ..< 3)
        if rndm > 1 && weather?.name != Weather.volcanicStorm.rawValue {
            if attacker.currhp > attacker.getModifiedBase().health/4 * 3 {
                for spell in availableSpells {
                    if attacker.singleSpells[spell].typeID == 14 {
                        if attacker.singleSpells[spell].range < 3 && attacker.hexes.count < 1 {
                            //protect fighter from negative hexes & useless move
                            if attacker.getArtifact().name != Artifacts.talisman.rawValue && attacker.getArtifact().name != Artifacts.amulet.rawValue {
                                return Move(source: player.currentFighterId, index: -1, target: player.currentFighterId, targetedPlayer: player.id, spell: spell, type: MoveType.spell)
                            }
                        } else if attacker.singleSpells[spell].range >= 3 && defender.hexes.count < 1 {
                            return Move(source: player.currentFighterId, index: -1, target: target.currentFighterId, targetedPlayer: target.id, spell: spell, type: MoveType.spell)
                        }
                    }
                }
            }
        }
        
        //main goal is to do the most damage
        var bestSpell: (Float, Int)
        bestSpell = (calcDamage(attacker: attacker, defender: defender, spell: attacker.singleSpells[availableSpells[0]], weather: weather), availableSpells[0])
        
        for index in 1 ..< availableSpells.count {
            if attacker.singleSpells[availableSpells[index]].typeID < 11 {
                let dmg: Float = calcDamage(attacker: attacker, defender: defender, spell: attacker.singleSpells[availableSpells[index]], weather: weather)
                if dmg > bestSpell.0 {
                    bestSpell = (dmg, index)
                }
            }
        }
        
        return Move(source: player.currentFighterId, index: -1, target: target.currentFighterId, targetedPlayer: target.id, spell: bestSpell.1, type: MoveType.spell)
    }
    
    /// Determines the best fighter to swap to for the CPU.
    /// - Parameters:
    ///   - currentFighter: The current fighter
    ///   - player: The targeted player
    ///   - enemyElement: The element of the enemy fighter
    ///   - hasToSwap: Determines if fighter has to swap
    ///   - weather: The current weather of the fight
    /// - Returns: Returns the index of the best fighter to swap to
    func getTarget(currentFighter: Int, player: Player, enemyElement: Element, hasToSwap: Bool, weather: Hex?) -> Int {
        for index in player.fighters.indices {
            if index != currentFighter && player.getFighter(index: index).getElement().hasAdvantage(element: enemyElement ,weather: weather) {
                if player.getFighter(index: index).currhp > 0 {
                    var unusableSpells: Int = 0
                    for spell in player.getFighter(index: index).singleSpells { //check if fighter can use any spell
                        if spell.useCounter + player.getFighter(index: index).manaUse > spell.uses {
                            unusableSpells += 1
                        }
                    }
                    
                    if unusableSpells < player.getFighter(index: index).singleSpells.count {
                        return index
                    }
                }
            }
        }
        
        for index in player.fighters.indices {
            if index != currentFighter && !player.getFighter(index: index).getElement().hasDisadvantage(element: enemyElement, weather: weather) {
                if player.getFighter(index: index).currhp > 0 {
                    var unusableSpells: Int = 0
                    for spell in player.getFighter(index: index).singleSpells { //check if fighter can use any spell
                        if spell.useCounter + player.getFighter(index: index).manaUse > spell.uses {
                            unusableSpells += 1
                        }
                    }
                    
                    if unusableSpells < player.getFighter(index: index).singleSpells.count {
                        return index
                    }
                }
            }
        }
        
        if hasToSwap {
            //no good fighter was found, find any fighter who hasn't fainted
            for index in player.fighters.indices {
                if index != currentFighter && player.getFighter(index: index).currhp > 0 {
                    var unusableSpells: Int = 0
                    for spell in player.getFighter(index: index).singleSpells { //check if fighter can use any spell
                        if spell.useCounter + player.getFighter(index: index).manaUse > spell.uses {
                            unusableSpells += 1
                        }
                    }
                    
                    if unusableSpells < player.getFighter(index: index).singleSpells.count {
                        return index
                    }
                }
            }
        }
        
        return currentFighter //no fighter was found
    }
    
    /// Calculate the minimum damage of a spell.
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - spell: The spell used to make the attack
    ///   - weather: The current weather of the fight
    /// - Returns: Returns the minimu damage of the spell
    private func calcDamage(attacker: Fighter, defender: Fighter, spell: Spell, weather: Hex?) -> Float {
        var dmg: Float
        
        switch spell.typeID {
        case 1:
            dmg = Float(spell.subSpells[0].power)
        case 3:
            dmg = DamageCalculator.shared.calcNonCriticalDamage(attacker: attacker, defender: defender, spell: spell.subSpells[0], spellElement: spell.element, weather: weather, powerOverride: spell.subSpells[0].power + spell.useCounter * 5)
        case 4:
            dmg = DamageCalculator.shared.calcNonCriticalDamage(attacker: attacker, defender: defender, spell: spell.subSpells[0], spellElement: spell.element, weather: weather, powerOverride: attacker.getModifiedBase().health - attacker.currhp)
        case 5:
            dmg = DamageCalculator.shared.calcNonCriticalDamage(attacker: attacker, defender: defender, spell: spell.subSpells[0], spellElement: spell.element, weather: weather, powerOverride: attacker.currhp)
        case 10:
            if attacker.lastSpell >= 0 || attacker.lastSpell == -2 {
                dmg = 0
            } else {
                fallthrough
            }
        default:
            dmg = DamageCalculator.shared.calcNonCriticalDamage(attacker: attacker, defender: defender, spell: spell.subSpells[0], spellElement: spell.element, weather: weather)
        }
        
        return dmg
    }
    
    /// Creates a move to indicate a swap.
    /// - Parameters:
    ///   - player: The current player
    ///   - target: The opponent player
    ///   - weather: The current weather of the fight
    /// - Returns: Returns a swap move
    private func createSwapMove(player: Player, target: Player, weather: Hex?) -> Move {
        let targetIndex: Int = CPULogic.shared.getTarget(currentFighter: player.currentFighterId, player: player, enemyElement: target.getCurrentFighter().getElement(), hasToSwap: true, weather: weather)
        
        return Move(source: player.currentFighterId, index: targetIndex, target: targetIndex, targetedPlayer: player.id, spell: -1, type: MoveType.swap)
    }
}
