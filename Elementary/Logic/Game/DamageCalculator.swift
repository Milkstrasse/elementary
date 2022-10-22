//
//  DamageCalculator.swift
//  Elementary
//
//  Created by Janice Hablützel on 07.01.22.
//

import Foundation

/// Calculates the amount of damage of an attack and deals it to the targeted fighter. The damage calculation considers different factors like the element of the fighter, the element of a spell and the current weather, there is also a chance of an additional bonus called critical hit.
struct DamageCalculator {
    static let shared: DamageCalculator = DamageCalculator()
    
    /// Calculates the amount of damage of an attack and deals it to the targeted fighter
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - spell: The spell used to make the attack
    ///   - subSpell: The part of the spell used to make the attack
    ///   - spellElement: The element of the used spell
    ///   - weather: The current weather of the fight
    ///   - usedShield: Indicates wether the opponent used a shield successfully
    /// - Returns: Returns a description of what occured during the attack
    func applyDamage(attacker: Fighter, defender: Fighter, spell: inout Spell, subSpell: SubSpell, spellElement: Element, weather: Hex?, usedShield: Bool) -> String {
        var text: String = Localization.shared.getTranslation(key: "hit")
        
        //determine actual target
        var target: Fighter = defender
        if subSpell.range == 0 {
            target = attacker
        }
        
        if target.currhp == 0 { //target already fainted -> no target for spell
            return Localization.shared.getTranslation(key: "fail")
        }
        
        //damage calculation
        var dmg: Float
        
        switch spell.typeID {
        case 1:
            dmg = Float(subSpell.power)
        case 2:
            if usedShield {
                dmg = calcNonCriticalDamage(attacker: attacker, defender: target, spell: subSpell, spellElement: spellElement, weather: weather, powerOverride: subSpell.power * 2)
            } else {
                dmg = calcNonCriticalDamage(attacker: attacker, defender: target, spell: subSpell, spellElement: spellElement, weather: weather)
            }
        case 3:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: target, spell: subSpell, spellElement: spellElement, weather: weather, powerOverride: subSpell.power + spell.useCounter * 5)
        case 4:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: target, spell: subSpell, spellElement: spellElement, weather: weather, powerOverride: subSpell.power + attacker.getModifiedBase().health - attacker.currhp)
        case 5:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: target, spell: subSpell, spellElement: spellElement, weather: weather, powerOverride: subSpell.power + attacker.currhp)
        case 7:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: target, spell: subSpell, spellElement: spellElement, weather: weather, powerOverride: -1)
        case 8:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: target, spell: subSpell, spellElement: spellElement, weather: weather, powerOverride: subSpell.power + attacker.hexes.count * 10)
        default:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: target, spell: subSpell, spellElement: spellElement, weather: weather)
        }
        
        //multiply with critical modifier
        var chance: Int = Int.random(in: 0 ..< 100)
        if spell.typeID != 1 && chance < attacker.getModifiedBase().precision/8 {
            chance = Int.random(in: 0 ..< 100)
            
            if chance >= target.getModifiedBase().resistance/10 {
                dmg *= 2
                text = Localization.shared.getTranslation(key: "criticalHit")
            }
        }
        
        let damage: Int = Int(round(dmg))
        
        if damage >= target.currhp { //prevent hp below 0
            if subSpell.range > 0 {
                if target.currhp == target.getModifiedBase().health && target.getArtifact().name == Artifacts.ring.rawValue && weather?.name != Weather.volcanicStorm.rawValue {
                    target.currhp = 1
                    target.overrideArtifact(artifact: Artifacts.noArtifact.getArtifact())
                } else {
                    target.currhp = 0
                }
            } else { //no artifact can help with self-inflicted damage
                target.currhp = 0
            }
        } else {
            target.currhp -= damage
        }
        
        if spell.typeID == 9 { //heal after attacking
            var healAmount: Float = max(Float(damage) * 0.75, 1)
            healAmount = 100/(Float(attacker.getModifiedBase().health)/healAmount)
            healAmount = roundf(healAmount)
            
            spell.spells[spell.spells.count - 1].healAmount = Int(healAmount)
        }
        
        print(target.name + " lost \(damage)DMG.\n")
        return text
    }
    
    /// Determines which elemental modifier the attack receives.
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - spellElement: The element of the used spell
    /// - Returns: Returns the received modifier
    func getElementalModifier(attacker: Fighter, defender: Fighter, spellElement: Element, weather: Hex?) -> Float {
        var modifier: Float = 1
        
        if weather?.name == Weather.denseFog.rawValue {
            return modifier
        } else {
            //elemental modifier of fighter
            if attacker.getElement().hasAdvantage(element: defender.getElement(), weather: weather) {
                modifier *= 2
            } else if attacker.getElement().hasDisadvantage(element: defender.getElement(), weather: weather) {
                modifier *= 0.5
            }
            
            //elemental modifier of spell
            if spellElement.hasAdvantage(element: defender.getElement(), weather: weather) {
                modifier *= 2
            } else if spellElement.hasDisadvantage(element: defender.getElement(), weather: weather) {
                modifier *= 0.5
            }
        }
        
        return modifier
    }
    
    /// Determines which weather modifier the attack receives.
    /// - Parameters:
    ///   - weather: The current weather of the fight
    ///   - spellElement: The element of the used spell
    /// - Returns: Returns the received modifier
    private func getWeatherModifier(weather: Hex, spellElement: String) -> Float {
        switch weather.name {
        case Weather.snowstorm.rawValue:
            if spellElement == "ice" || spellElement == "wind" {
                return 1.5
            }
        case Weather.sunnyDay.rawValue:
            if spellElement == "fire" || spellElement == "wood" {
                return 1.5
            }
        case Weather.overcastSky.rawValue:
            if spellElement == "aether" || spellElement == "decay" {
                return 1.5
            }
        case Weather.mysticWeather.rawValue:
            if spellElement == "electric" || spellElement == "metal" {
                return 1.5
            }
        case Weather.lightRain.rawValue:
            if spellElement == "plant" || spellElement == "water" {
                return 1.5
            }
        case Weather.sandstorm.rawValue:
            if spellElement == "ground" || spellElement == "rock" {
                return 1.5
            }
        default:
            return 1
        }
        
        return 1
    }
    
    /// Calculates the damage of an attack.
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - spell: The spell used to make the attack
    ///   - spellElement: The element of the used spell
    ///   - weather: The current weather of the fight
    ///   - powerOverride: The modification to the power of the spell
    /// - Returns: Returns the damage of the attack
    func calcNonCriticalDamage(attacker: Fighter, defender: Fighter, spell: SubSpell, spellElement: Element, weather: Hex?, powerOverride: Int = 0) -> Float {
        let attack: Float
        if powerOverride > 0 {
            attack = Float(powerOverride)/100 * Float(attacker.getModifiedBase(weather: weather).attack) * 24
        } else if powerOverride == 0 {
            attack = Float(spell.power)/100 * Float(attacker.getModifiedBase(weather: weather).attack) * 24
        } else {
            attack = Float(spell.power)/100 * Float(defender.getModifiedBase(weather: weather).attack) * 24
        }
        
        let defense: Float = max(Float(defender.getModifiedBase(weather: weather).defense), 1.0) //prevent division by zero
        
        var dmg: Float = attack/defense
        
        //multiply with elemental modifier
        dmg *= getElementalModifier(attacker: attacker, defender: defender, spellElement: spellElement, weather: weather)
        
        //multiply with weather modifier
        if weather != nil {
            dmg *= getWeatherModifier(weather: weather!, spellElement: spellElement.name)
        }
        
        return dmg
    }
    
    /// Calculates damage of an attack without the critical modifier. Used by the CPU to determine if an attack is a sure K.O
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - spell: The spell used to make the attack
    ///   - subSpell: The part of the spell used to make the attack
    ///   - spellElement: The element of the used spell
    ///   - weather: The current weather of the fight
    /// - Returns: Returns wether the attack is a guaranteed K.O.
    func willDefeatFighter(attacker: Fighter, defender: Fighter, spell: Spell, subSpell: SubSpell, spellElement: Element, weather: Hex?) -> Bool {
        let dmg: Float
        
        switch spell.typeID {
        case 1:
            dmg = Float(subSpell.power)
        case 3:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: subSpell, spellElement: spellElement, weather: weather, powerOverride: subSpell.power + spell.useCounter * 5)
        case 4:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: subSpell, spellElement: spellElement, weather: weather, powerOverride: subSpell.power + attacker.getModifiedBase().health - attacker.currhp)
        case 5:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: subSpell, spellElement: spellElement, weather: weather, powerOverride: subSpell.power + attacker.currhp)
        case 8:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: subSpell, spellElement: spellElement, weather: weather, powerOverride: subSpell.power + attacker.hexes.count * 10)
        default:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: subSpell, spellElement: spellElement, weather: weather)
        }
        
        let damage: Int = Int(round(dmg))
        
        if damage >= defender.currhp {
            return true
        } else {
            return false
        }
    }
}
