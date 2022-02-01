//
//  DamageCalculator.swift
//  Witchery
//
//  Created by Janice Hablützel on 07.01.22.
//

import Foundation

/// Calculates the amount of damage of an attack and deals it to the targeted witch. The damage calculation considers different factors like the element of the witch, the element of a spell and the current weather, there is also a chance of an additional bonus called critical hit.
struct DamageCalculator {
    static let shared: DamageCalculator = DamageCalculator()
    
    /// Calculates the amount of damage of an attack and deals it to the targeted witch
    /// - Parameters:
    ///   - attacker: The witch that attacks
    ///   - defender: The witch to be targeted
    ///   - spell: The spell used to make the attack
    ///   - spellElement: The element of the used spell
    ///   - weather: The current weather of the fight
    /// - Returns: Returns a description of what occured during the attack
    func applyDamage(attacker: Witch, defender: Witch, spell: SubSpell, spellElement: Element, weather: Hex?) -> String {
        var text: String = Localization.shared.getTranslation(key: "hit") + "\n"
        
        //determine actual target
        var target: Witch = defender
        if spell.range == 0 {
            target = attacker
        }
        
        if target.currhp == 0 { //target already fainted -> no target for spell
            return Localization.shared.getTranslation(key: "fail") + "\n"
        }
        
        //damage calculation
        var dmg: Float = calcNonCriticalDamage(attacker: attacker, defender: target, spell: spell, spellElement: spellElement, weather: weather)
        
        //multiply with critical modifier
        var chance: Int = Int.random(in: 0 ..< 100)
        if chance < attacker.getModifiedBase().precision/8 {
            chance = Int.random(in: 0 ..< 100)
            
            if chance >= attacker.getModifiedBase().resistance/10 {
                dmg *= 1.5
                text = Localization.shared.getTranslation(key: "criticalHit") + "\n"
            }
        }
        
        let damage: Int = Int(round(dmg))
        
        if damage >= target.currhp { //prevent hp below 0
            print(target.name + " lost \(damage)DMG.\n")
            target.currhp = 0
            
            return text
        }
        
        print(target.name + " lost \(damage)DMG.\n")
        target.currhp -= damage
        return text
    }
    
    /// Determines which elemental modifier the attack receives.
    /// - Parameters:
    ///   - attacker: The witch that attacks
    ///   - defender: The witch to be targeted
    ///   - spellElement: The element of the used spell
    /// - Returns: Returns the received modifier
    func getElementalModifier(attacker: Witch, defender: Witch, spellElement: Element) -> Float {
        var modifier: Float = 1
        
        //elemental modifier of witch
        if attacker.element.hasAdvantage(element: defender.element) {
            modifier *= 2
        } else if attacker.element.hasDisadvantage(element: defender.element) {
            modifier *= 0.5
        }
        
        //elemental modifier of spell
        if spellElement.hasAdvantage(element: defender.element) {
            modifier *= 2
        } else if spellElement.hasDisadvantage(element: defender.element) {
            modifier *= 0.5
        }
        
        return modifier
    }
    
    /// Determines which weather modifier the attack receives.
    /// - Parameters:
    ///   - weather: The current weather of the fight
    ///   - spellElement: The element of the used spell
    /// - Returns: Returns the received modifier
    func getWeatherModifier(weather: Hex, spellElement: String) -> Float {
        switch weather.name {
            case Weather.sandstorm.rawValue:
                if spellElement == "wind" || spellElement == "rock" {
                    return 1.5
                }
            case Weather.thunderstorm.rawValue:
                if spellElement == "water" || spellElement == "electric" {
                    return 1.5
                }
            case Weather.sunnyDay.rawValue:
                if spellElement == "plant" || spellElement == "fire" {
                    return 1.5
                }
            case Weather.smog.rawValue:
                if spellElement == "metal" || spellElement == "wind" {
                    return 1.5
                }
            case Weather.mysticWeather.rawValue:
                if spellElement == "metal" || spellElement == "electric" {
                    return 1.5
                }
            case Weather.lightRain.rawValue:
                if spellElement == "water" || spellElement == "plant" {
                    return 1.5
                }
            case Weather.drought.rawValue:
                if spellElement == "rock" || spellElement == "fire" {
                    return 1.5
                }
            default:
                return 1
        }
        
        return 1
    }
    
    /// Calculates the damage of an attack.
    /// - Parameters:
    ///   - attacker: The witch that attacks
    ///   - defender: The witch to be targeted
    ///   - spell: The spell used to make the attack
    ///   - spellElement: The element of the used spell
    ///   - weather: The current weather of the fight
    /// - Returns: Returns the damage of the attack
    func calcNonCriticalDamage(attacker: Witch, defender: Witch, spell: SubSpell, spellElement: Element, weather: Hex?) -> Float {
        let attack: Float = Float(spell.power)/100 * Float(attacker.getModifiedBase().attack) * 16
        let defense: Float = max(Float(defender.getModifiedBase().defense), 1.0) //prevent division by zero
        
        var dmg: Float = attack/defense
        
        //multiply with elemental modifier
        if attacker.getArtifact().name != Artifacts.ring.rawValue && defender.getArtifact().name != Artifacts.ring.rawValue {
            dmg *= getElementalModifier(attacker: attacker, defender: defender, spellElement: spellElement)
        }
        
        //multiply with weather modifier
        if weather != nil {
            dmg *= getWeatherModifier(weather: weather!, spellElement: spellElement.name)
        }
        
        return dmg
    }
    
    /// Calculates damage of an attack without the critical modifier. Used by the CPU to determine if an attack is a sure K.O
    /// - Parameters:
    ///   - attacker: The witch that attacks
    ///   - defender: The witch to be targeted
    ///   - spell: The spell used to make the attack
    ///   - spellElement: The element of the used spell
    ///   - weather: The current weather of the fight
    /// - Returns: Returns wether the attack is a guaranteed K.O.
    func willDefeatWitch(attacker: Witch, defender: Witch, spell: SubSpell, spellElement: Element, weather: Hex?) -> Bool {
        var dmg: Float = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: spell, spellElement: spellElement, weather: weather)
        
        let damage: Int = Int(round(dmg))
        
        if damage >= defender.currhp {
            return true
        } else {
            return false
        }
    }
}
