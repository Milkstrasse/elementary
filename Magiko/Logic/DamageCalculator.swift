//
//  DamageCalculator.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import Foundation

struct DamageCalculator {
    static let shared = DamageCalculator()
    
    func calcDamage(attacker: Fighter, defender: Fighter, skill: SubSkill, skillElement: String) -> UInt {
        let element: Element = GlobalData.shared.elements[skillElement] ?? Element()
        
        let attack: Float = Float(skill.power)/100 * Float(attacker.getModifiedBase().attack) * 16
        let defense: Float = Float(defender.getModifiedBase().defense)
        
        var dmg: Float = attack/defense
        dmg *= getElementalModifier(attacker: attacker, defender: defender, skillElement: element)
        
        let damage: UInt = UInt(round(dmg))
        
        if damage > defender.currhp {
            return defender.currhp
        }
        
        print(Int(damage))
        
        return damage
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
}
