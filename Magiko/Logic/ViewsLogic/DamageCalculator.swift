//
//  DamageCalculator.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import Foundation

/// Calculates the amount of damage of an attack and deals it to the targeted fighter. The damage calculation considers different factors like the element of the fighter, the element of a skill and the current weather, there is also a chance of an additional bonus called critical hit.
struct DamageCalculator {
    static let shared: DamageCalculator = DamageCalculator()
    
    /// Calculates the amount of damage of an attack and deals it to the targeted fighter
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - skill: The skill used to make the attack
    ///   - skillElement: The element of the used skill
    ///   - weather: The current weather of the fight
    /// - Returns: Returns a description of what occured during the attack
    func applyDamage(attacker: Fighter, defender: Fighter, skill: SubSkill, skillElement: String, weather: Effect?) -> String {
        var text: String = "\n"
        
        //determine actual target
        var target: Fighter = defender
        if skill.range == 0 {
            target = attacker
        }
        
        if target.currhp == 0 { //target already fainted -> no target for skill
            return "\n" + Localization.shared.getTranslation(key: "fail") + "\n"
        }
        
        //damage calculation
        var dmg: Float = calcNonCriticalDamage(attacker: attacker, defender: target, skill: skill, skillElement: skillElement, weather: weather)
        
        //multiply with critical modifier
        if !target.hasEffect(effectName: Effects.alerted.rawValue) {
            let chance: Int = Int.random(in: 0 ..< 100)
            if chance < attacker.getModifiedBase().precision/6 {
                dmg *= 1.5
                text = "\n" + Localization.shared.getTranslation(key: "criticalHit") + "\n"
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
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - skillElement: The element of the used skill
    /// - Returns: Returns the received modifier
    func getElementalModifier(attacker: Fighter, defender: Fighter, skillElement: Element) -> Float {
        var modifier: Float = 1
        
        //elemental modifier of fighter
        if attacker.element.hasAdvantage(element: defender.element) {
            modifier *= 2
        } else if attacker.element.hasDisadvantage(element: defender.element) {
            modifier *= 0.5
        }
        
        //elemental modifier of skill
        if skillElement.hasAdvantage(element: defender.element) {
            modifier *= 2
        } else if skillElement.hasDisadvantage(element: defender.element) {
            modifier *= 0.5
        }
        
        return modifier
    }
    
    /// Determines which weather modifier the attack receives.
    /// - Parameters:
    ///   - weather: The current weather of the fight
    ///   - skillElement: The element of the used skill
    /// - Returns: Returns the received modifier
    func getWeatherModifier(weather: Effect, skillElement: String) -> Float {
        switch weather.name {
            case WeatherEffects.sandstorm.rawValue:
                if skillElement == "wind" || skillElement == "rock" {
                    return 1.5
                }
            case WeatherEffects.thunderstorm.rawValue:
                if skillElement == "water" || skillElement == "electric" {
                    return 1.5
                }
            case WeatherEffects.sunnyDay.rawValue:
                if skillElement == "plant" || skillElement == "fire" {
                    return 1.5
                }
            case WeatherEffects.smog.rawValue:
                if skillElement == "metal" || skillElement == "wind" {
                    return 1.5
                }
            case WeatherEffects.mysticWeather.rawValue:
                if skillElement == "metal" || skillElement == "electric" {
                    return 1.5
                }
            case WeatherEffects.lightRain.rawValue:
                if skillElement == "water" || skillElement == "plant" {
                    return 1.5
                }
            case WeatherEffects.drought.rawValue:
                if skillElement == "rock" || skillElement == "fire" {
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
    ///   - skill: The skill used to make the attack
    ///   - skillElement: The element of the used skill
    ///   - weather: The current weather of the fight
    /// - Returns: Returns the damage of the attack
    func calcNonCriticalDamage(attacker: Fighter, defender: Fighter, skill: SubSkill, skillElement: String, weather: Effect?) -> Float {
        let element: Element = GlobalData.shared.elements[skillElement] ?? Element()
        
        let attack: Float = Float(skill.power)/100 * Float(attacker.getModifiedBase().attack) * 16
        let defense: Float = max(Float(defender.getModifiedBase().defense), 1.0) //prevent division by zero
        
        var dmg: Float = attack/defense
        
        //multiply with elemental modifier
        if attacker.ability.name != Abilities.ethereal.rawValue && defender.ability.name != Abilities.ethereal.rawValue {
            dmg *= getElementalModifier(attacker: attacker, defender: defender, skillElement: element)
        }
        
        //multiply with weather modifier
        if weather != nil {
            dmg *= getWeatherModifier(weather: weather!, skillElement: skillElement)
        }
        
        return dmg
    }
    
    func willDefeatFighter(attacker: Fighter, defender: Fighter, skill: SubSkill, skillElement: String, weather: Effect?) -> Bool {
        var dmg: Float = calcNonCriticalDamage(attacker: attacker, defender: defender, skill: skill, skillElement: skillElement, weather: weather)
        
        //multiply with critical modifier
        if !defender.hasEffect(effectName: Effects.alerted.rawValue) {
            let chance: Int = Int.random(in: 0 ..< 100)
            if chance < attacker.getModifiedBase().precision/6 {
                dmg *= 1.5
            }
        }
        
        let damage: Int = Int(round(dmg))
        
        if damage >= defender.currhp {
            return true
        } else {
            return false
        }
    }
}
