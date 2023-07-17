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
    ///   - spell: The index of the spell used
    ///   - subSpell: The index of the part of the spell used
    ///   - spellElement: The element of the used spell
    ///   - weather: The current weather of the fight
    ///   - usedShield: Indicates wether the target used a shield successfully
    ///   - singleMode: Indicates the category of the spell used
    /// - Returns: Returns a description of what occured during the attack
    func applyDamage(attacker: Fighter, defender: Fighter, spell: Int, spellIndex: Int, spellElement: Element, weather: Hex?, usedShield: Bool, singleMode: Bool) -> String {
        var text: String
        
        let moveSpell: Spell
        if singleMode {
            moveSpell = attacker.singleSpells[spell]
        } else {
            moveSpell = attacker.multiSpells[spell]
        }
        
        if moveSpell.subSpells[spellIndex].range == 0 {
            text = Localization.shared.getTranslation(key: "lostHP", params: [defender.name])
        } else {
            text = Localization.shared.getTranslation(key: "hit")
        }
        
        //damage calculation
        var dmg: Float
        
        switch moveSpell.typeID {
        case 1:
            dmg = Float(moveSpell.subSpells[spellIndex].power)
        case 2:
            if usedShield {
                dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: moveSpell.subSpells[spellIndex], spellElement: spellElement, weather: weather, powerOverride: moveSpell.subSpells[spellIndex].power * 2)
            } else {
                dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: moveSpell.subSpells[spellIndex], spellElement: spellElement, weather: weather)
            }
        case 3:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: moveSpell.subSpells[spellIndex], spellElement: spellElement, weather: weather, powerOverride: moveSpell.subSpells[spellIndex].power + moveSpell.useCounter * 5)
        case 4:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: moveSpell.subSpells[spellIndex], spellElement: spellElement, weather: weather, powerOverride: moveSpell.subSpells[spellIndex].power + attacker.getModifiedBase().health - attacker.currhp)
        case 5:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: moveSpell.subSpells[spellIndex], spellElement: spellElement, weather: weather, powerOverride: moveSpell.subSpells[spellIndex].power + attacker.currhp)
        case 7:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: moveSpell.subSpells[spellIndex], spellElement: spellElement, weather: weather, powerOverride: -1)
        case 8:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: moveSpell.subSpells[spellIndex], spellElement: spellElement, weather: weather, powerOverride: moveSpell.subSpells[spellIndex].power + attacker.hexes.count * 10)
        default:
            dmg = calcNonCriticalDamage(attacker: attacker, defender: defender, spell: moveSpell.subSpells[spellIndex], spellElement: spellElement, weather: weather)
        }
        
        //multiply with critical modifier
        var chance: Int = Int.random(in: 0 ..< 100)
        
        if moveSpell.typeID != 1 && chance < (18 + attacker.getModifiedBase().precision) * (10/100) {
            chance = Int.random(in: 0 ..< 100)
            
            if chance >= (defender.getModifiedBase().resistance/10 * defender.getModifiedBase().resistance/10)/10 {
                dmg *= GlobalData.shared.criticalModifier
                text = Localization.shared.getTranslation(key: "criticalHit")
            }
        }
        
        //add random modifier
        if GlobalData.shared.deviation > 0 {
            let random: Int = Int.random(in: GlobalData.shared.deviation * -1 ..< GlobalData.shared.deviation)
            dmg = dmg + Float(random)/100 * dmg
        }
        
        let damage: Int = Int(max(ceil(dmg), 0))
        
        if damage >= defender.currhp { //prevent hp below 0
            if defender.getArtifact().name == Artifacts.ring.rawValue && weather?.name != Weather.mysticWeather.rawValue {
                defender.currhp = 1
            } else {
                defender.currhp = 0
            }
        } else {
            defender.currhp -= damage
        }
        
        if defender.getArtifact().name == Artifacts.ring.rawValue {
            defender.overrideArtifact(artifact: Artifacts.noArtifact.getArtifact())
        }
        
        if moveSpell.typeID == 9 { //heal after attacking
            var healAmount: Float = max(Float(damage) * 0.75, 1)
            healAmount = 100/(Float(attacker.getModifiedBase().health)/healAmount)
            healAmount = roundf(healAmount)
            
            if singleMode {
                attacker.singleSpells[spell].subSpells[spellIndex + 1].healAmount = Int(healAmount)
            } else {
                attacker.multiSpells[spell].subSpells[spellIndex + 1].healAmount = Int(healAmount)
            }
        }
        
        print(defender.name + " lost \(damage)DMG.")
        return text
    }
    
    /// Determines which elemental modifier the attack receives.
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - spellElement: The element of the used spell
    ///   - weather: The current weather of the fight
    /// - Returns: Returns the received modifier
    func getElementalModifier(attacker: Fighter, defender: Fighter, spellElement: Element, weather: Hex?) -> Float {
        var modifier: Float = 1
        
        if weather?.name == Weather.denseFog.rawValue {
            return modifier
        } else {
            //elemental modifier of fighter
            if attacker.getElement().hasAdvantage(element: defender.getElement(), weather: weather) {
                modifier *= GlobalData.shared.elementalModifier
            } else if attacker.getElement().hasDisadvantage(element: defender.getElement(), weather: weather) {
                modifier *= 1/GlobalData.shared.elementalModifier
            }
            
            //elemental modifier of spell
            if spellElement.hasAdvantage(element: defender.getElement(), weather: weather) {
                modifier *= GlobalData.shared.elementalModifier
            } else if spellElement.hasDisadvantage(element: defender.getElement(), weather: weather) {
                modifier *= 1/GlobalData.shared.elementalModifier
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
        case Weather.blizzard.rawValue:
            if spellElement == "ice" || spellElement == "wind" {
                return GlobalData.shared.weatherModifier
            }
        case Weather.sunnyDay.rawValue:
            if spellElement == "fire" || spellElement == "plant" {
                return GlobalData.shared.weatherModifier
            }
        case Weather.overcastSky.rawValue:
            if spellElement == "aether" || spellElement == "rock" {
                return GlobalData.shared.weatherModifier
            }
        case Weather.lightRain.rawValue:
            if spellElement == "water" || spellElement == "wood" {
                return GlobalData.shared.weatherModifier
            }
        case Weather.sandstorm.rawValue:
            if spellElement == "ground" || spellElement == "time" {
                return GlobalData.shared.weatherModifier
            }
        case Weather.thunderstorm.rawValue:
            if spellElement == "electric" || spellElement == "metal" {
                return GlobalData.shared.weatherModifier
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
    ///   - spell: The part of the spell used
    ///   - spellElement: The element of the used spell
    ///   - weather: The current weather of the fight
    ///   - powerOverride: The modification to the power of the spell
    /// - Returns: Returns the damage of the attack
    func calcNonCriticalDamage(attacker: Fighter, defender: Fighter, spell: SubSpell, spellElement: Element, weather: Hex?, powerOverride: Int = 0) -> Float {
        let attack: Float
        if powerOverride > 0 {
            attack = Float(powerOverride)/100 * Float(attacker.getModifiedBase(weather: weather).attack) * GlobalData.shared.attackModifier
        } else if powerOverride == 0 {
            attack = Float(spell.power)/100 * Float(attacker.getModifiedBase(weather: weather).attack) * GlobalData.shared.attackModifier
        } else {
            attack = Float(spell.power)/100 * Float(defender.getModifiedBase(weather: weather).attack) * GlobalData.shared.attackModifier
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
    ///   - spell: The spell used
    ///   - subSpell: The part of the spell used
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
        
        let damage: Int = Int(ceil(dmg))
        
        if damage >= defender.currhp {
            return true
        } else {
            return false
        }
    }
}
