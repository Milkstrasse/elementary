//
//  CPULogic.swift
//  Witchery
//
//  Created by Janice Hablützel on 15.01.22.
//

/// This is the logic that determines the best possible move or target for a swap.
struct CPULogic {
    static let shared: CPULogic = CPULogic()
    
    /// Determines the best move for the CPU.
    /// - Parameters:
    ///   - witch: The current witch
    ///   - target: The current witch of the player
    ///   - weather: The current weather of the fight
    ///   - isAbleToSwitch: Wether the witch can swap or not
    ///   - lastMove: The last move of the witch
    /// - Returns: Returns the best move
    func getMove(witch: Witch, target: Witch, weather: Hex?, isAbleToSwitch: Bool, lastMove: Move?) -> Move? {
        //collect all useable spells
        var availableSpells: [Int] = []
        
        for index in witch.spells.indices {
            if witch.spells[index].useCounter + witch.manaUse <= witch.spells[index].uses {
                availableSpells.append(index)
            }
        }
        
        //no moves found
        if availableSpells.isEmpty {
            if isAbleToSwitch {
                if !witch.hasHex(hexName: Hexes.chained.rawValue) {
                    return nil
                }
            } else {
                return Move(source: witch, target: -1, spell: witch.spells[0])
            }
        }
        
        if witch.getArtifact().name == Artifacts.corset.rawValue || witch.hasHex(hexName: Hexes.restricted.rawValue) { //witch is restricted -> use best move
            if witch.getElement().hasDisadvantage(element: target.getElement()) && isAbleToSwitch {
                if !witch.hasHex(hexName: Hexes.chained.rawValue) {
                    return nil
                }
            }
            
            var bestSpell: (Float, Int)
            bestSpell = (calcDamage(attacker: witch, defender: target, spell: witch.spells[availableSpells[0]], weather: weather), 0)
            
            for index in 1 ..< availableSpells.count {
                if witch.spells[availableSpells[index]].typeID < 9 {
                    let dmg: Float = calcDamage(attacker: witch, defender: target, spell: witch.spells[availableSpells[index]], weather: weather)
                    if dmg > bestSpell.0 {
                        bestSpell = (dmg, index)
                    }
                }
            }
            
            if  witch.spells[bestSpell.1].typeID < 9 {
                return Move(source: witch, target: -1, spell: witch.spells[bestSpell.1])
            }
        }
        
        //top priority: find move that defeats the enemy witch!
        for index in availableSpells.indices {
            if witch.spells[availableSpells[index]].typeID < 9 {
                if DamageCalculator.shared.willDefeatWitch(attacker: witch, defender: target, spell: witch.spells[availableSpells[index]], subSpell: witch.spells[availableSpells[index]].spells[0], spellElement: witch.spells[availableSpells[index]].element, weather: weather) {
                    return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                }
            }
        }
        
        //avoid fighting against enemy with advantage
        if witch.getElement().hasDisadvantage(element: target.getElement()) && isAbleToSwitch {
            if !witch.hasHex(hexName: Hexes.chained.rawValue) {
                return nil
            }
        }
        
        //low health -> should heal
        if witch.currhp <= witch.getModifiedBase().health/3 && !witch.hasHex(hexName: Hexes.haunted.rawValue) {
            for index in availableSpells.indices {
                if witch.spells[availableSpells[index]].typeID == 11 {
                    return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                }
            }
        }
        
        //have control over weather since the weather boosts certain attacks
        var rndm: Int = Int.random(in: 0 ..< 3)
        if rndm > 0 {
            for index in availableSpells.indices {
                if witch.spells[availableSpells[index]].typeID == 10 {
                    if weather?.name != witch.spells[availableSpells[index]].spells[0].weather! {
                        return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                    }
                }
            }
        }
        
        //consider using shield
        if target.getHexDuration(hexName: Hexes.poisoned.rawValue) > 0 || witch.getHexDuration(hexName: Hexes.healed.rawValue) > 0 {
            if lastMove == nil || lastMove?.spell.typeID != 12 {
                for index in availableSpells.indices {
                    if witch.spells[availableSpells[index]].typeID == 12 {
                        return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                    }
                }
            }
        }
        
        //consider using a hex
        rndm = Int.random(in: 0 ..< 3)
        if rndm > 0 {
            if witch.currhp > witch.getModifiedBase().health/4 * 3 {
                for index in availableSpells.indices {
                    if witch.spells[availableSpells[index]].typeID == 13 {
                        if witch.spells[availableSpells[index]].spells[0].range == 0 && witch.hexes.count < 2 {
                            //protect witch from negative hexes & useless move
                            if witch.getArtifact().name != Artifacts.talisman.rawValue && witch.getArtifact().name != Artifacts.amulet.rawValue {
                                return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                            }
                        } else if witch.spells[availableSpells[index]].spells[0].range == 1 && target.hexes.count < 2 {
                            return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                        }
                    }
                }
            }
        }
        
        //main goal is to do the most damage
        var bestSpell: (Float, Int)
        bestSpell = (calcDamage(attacker: witch, defender: target, spell: witch.spells[availableSpells[0]], weather: weather), 0)
        
        for index in 1 ..< availableSpells.count {
            if witch.spells[availableSpells[index]].typeID < 9 {
                let dmg: Float = calcDamage(attacker: witch, defender: target, spell: witch.spells[availableSpells[index]], weather: weather)
                if dmg > bestSpell.0 {
                    bestSpell = (dmg, index)
                }
            }
        }
        
        return Move(source: witch, target: -1, spell: witch.spells[bestSpell.1])
    }
    
    /// Determines the best witch to swap to for the CPU.
    /// - Parameters:
    ///   - currentWitch: The current witch
    ///   - witches: The current team
    ///   - enemyElement: The element of the enemy witch
    /// - Returns: Returns the index of the best witch to swap to
    func getTarget(currentWitch: Int, witches: [Witch], enemyElement: Element) -> Int {
        for index in witches.indices {
            if witches[index].getElement().hasAdvantage(element: enemyElement) && index != currentWitch {
                if witches[index].currhp > 0 {
                    return index
                }
            }
        }
        
        for index in witches.indices {
            if !witches[index].getElement().hasDisadvantage(element: enemyElement) && index != currentWitch {
                if witches[index].currhp > 0 {
                    return index
                }
            }
        }
        
        //no good witch was found, find any witch who hasn't fainted
        for index in witches.indices {
            if index != currentWitch && witches[index].currhp > 0 {
                return index
            }
        }
        
        return currentWitch + 1 //should be impossible to reach if everything works correctly
    }
    
    /// Calculate the minimum damage of a spell.
    /// - Parameters:
    ///   - attacker: The witch that attacks
    ///   - defender: The witch to be targeted
    ///   - spell: The spell used to make the attack
    ///   - weather: The current weather of the fight
    /// - Returns: Returns the minimu damage of the spell
    private func calcDamage(attacker: Witch, defender: Witch, spell: Spell, weather: Hex?) -> Float {
        var dmg: Float
        switch spell.typeID {
            case 1:
                dmg = Float(spell.spells[0].power)
            case 3:
                dmg = DamageCalculator.shared.calcNonCriticalDamage(attacker: attacker, defender: defender, spell: spell.spells[0], spellElement: spell.element, weather: weather, powerOverride: spell.spells[0].power + spell.useCounter * 5)
            case 4:
                dmg = DamageCalculator.shared.calcNonCriticalDamage(attacker: attacker, defender: defender, spell: spell.spells[0], spellElement: spell.element, weather: weather, powerOverride: attacker.getModifiedBase().health - attacker.currhp)
            case 5:
                dmg = DamageCalculator.shared.calcNonCriticalDamage(attacker: attacker, defender: defender, spell: spell.spells[0], spellElement: spell.element, weather: weather, powerOverride: attacker.currhp)
            default:
                dmg = DamageCalculator.shared.calcNonCriticalDamage(attacker: attacker, defender: defender, spell: spell.spells[0], spellElement: spell.element, weather: weather)
        }
        
        return dmg
    }
}
