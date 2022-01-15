//
//  DamageCalculator.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import Foundation

struct DamageCalculator {
    static let shared: DamageCalculator = DamageCalculator()
    
    func applyDamage(attacker: Fighter, defender: Fighter, skill: SubSkill, skillElement: String, weather: Effect?) -> String {
        if defender.currhp == 0 {
            return Localization.shared.getTranslation(key: "fail") + "\n"
        }
        
        var text: String = ""
        
        let element: Element = GlobalData.shared.elements[skillElement] ?? Element()
        
        let attack: Float = Float(skill.power)/100 * Float(attacker.getModifiedBase().attack) * 16
        let defense: Float = max(Float(defender.getModifiedBase().defense), 1.0) //prevent division by zero
        
        var dmg: Float = attack/defense
        
        if attacker.ability.name != Abilities.ethereal.rawValue && defender.ability.name != Abilities.ethereal.rawValue {
            dmg *= getElementalModifier(attacker: attacker, defender: defender, skillElement: element)
        }
        
        if !defender.hasEffect(effectName: Effects.alerted.rawValue) {
            let chance: Int = Int.random(in: 0 ..< 100)
            if chance < attacker.getModifiedBase().precision/6 {
                dmg *= 1.5
                text = "\n" + Localization.shared.getTranslation(key: "criticalHit")
            }
        }
        
        if weather != nil {
            dmg *= getWeatherModifier(weather: weather!, skillElement: skillElement)
        }
        
        let damage: Int = Int(round(dmg))
        
        if damage >= defender.currhp {
            print(defender.name + " lost \(damage)DMG.\n")
            defender.currhp = 0
            
            return text + "\n"
        }
        
        print(defender.name + " lost \(damage)DMG.\n")
        defender.currhp -= damage
        return text + "\n"
    }
    
    func getElementalModifier(attacker: Fighter, defender: Fighter, skillElement: Element) -> Float {
        var modifier: Float = 1
        
        if attacker.element.hasAdvantage(element: defender.element) {
            modifier *= 2
        } else if attacker.element.hasDisdvantage(element: defender.element) {
            modifier *= 0.5
        }
        
        if skillElement.hasAdvantage(element: defender.element) {
            modifier *= 2
        } else if skillElement.hasDisdvantage(element: defender.element) {
            modifier *= 0.5
        }
        
        return modifier
    }
    
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
}
