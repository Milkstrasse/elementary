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
    ///   - enemy: The current witch of the player
    ///   - weather: The current weather of the fight
    ///   - isAbleToSwitch: Wether the witch can swap or not
    /// - Returns: Returns the best move
    func getMove(witch: Witch, enemy: Witch, weather: Hex?, isAbleToSwitch: Bool) -> Move? {
        //avoid fighting against enemy with advantage
        if witch.element.hasDisadvantage(element: enemy.element) && isAbleToSwitch {
            if !witch.hasHex(hexName: Hexes.chained.rawValue) {
                return nil
            }
        }
        
        //collect all useable spells
        var availableSpells: [Int] = []
        
        for index in witch.spells.indices {
            if witch.spells[index].useCounter + witch.staminaUse <= witch.spells[index].getUses(witch: witch) {
                availableSpells.append(index)
            }
        }
        
        //have control over weather since the weather boosts certain attacks
        if weather == nil || weather?.duration == 1 {
            for index in availableSpells.indices {
                for spell in witch.spells[availableSpells[index]].spells {
                    if spell.weather != nil {
                        return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                    }
                }
            }
        }
        
        //top priority: find move that defeats the enemy witch!
        for index in availableSpells.indices {
            if witch.spells[availableSpells[index]].type == "attack" {
                if DamageCalculator.shared.willDefeatWitch(attacker: witch, defender: enemy, spell: witch.spells[availableSpells[index]].spells[0], spellElement: witch.spells[availableSpells[index]].element, weather: weather) {
                    return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                }
            }
        }
        
        //low health -> should heal
        if witch.currhp <= witch.getModifiedBase().health/2 && !witch.hasHex(hexName: Hexes.haunted.rawValue) {
            for index in availableSpells.indices {
                if witch.spells[availableSpells[index]].type == "heal" {
                    return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                }
            }
        }
        
        //main goal is to do damage
        for index in availableSpells.indices {
            let spellElement: Element = witch.spells[availableSpells[index]].element
            
            if witch.spells[availableSpells[index]].type == "attack" {
                if spellElement.hasAdvantage(element: enemy.element) {
                    return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                }
            }
        }
        
        for index in availableSpells.indices {
            let spellElement: Element = witch.spells[availableSpells[index]].element
            
            if witch.spells[availableSpells[index]].type == "attack" {
                if !spellElement.hasDisadvantage(element: enemy.element) {
                    return Move(source: witch, target: -1, spell: witch.spells[availableSpells[index]])
                }
            }
        }
        
        //no good move has been found
        return Move(source: witch, target: -1, spell: witch.spells[0])
    }
    
    /// Determines the best witch to swap to for the CPU.
    /// - Parameters:
    ///   - currentWitch: The current witch
    ///   - witches: The current team
    ///   - enemyElement: The element of the enemy witch
    /// - Returns: Returns the index of the best witch to swap to
    func getTarget(currentWitch: Int, witches: [Witch], enemyElement: Element) -> Int {
        for index in witches.indices {
            if witches[index].element.hasAdvantage(element: enemyElement) && index != currentWitch {
                if witches[index].currhp > 0 {
                    return index
                }
            }
        }
        
        for index in witches.indices {
            if !witches[index].element.hasDisadvantage(element: enemyElement) && index != currentWitch {
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
}
