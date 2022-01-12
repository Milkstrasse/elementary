//
//  DamageCalculator.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import Foundation

struct DamageCalculator {
    static let shared: DamageCalculator = DamageCalculator()
    
    func calcDamage(attacker: Fighter, defender: Fighter, skill: SubSkill, skillElement: String) -> (damage: Int, text: String) {
        var text: String = ""
        let element: Element = GlobalData.shared.elements[skillElement] ?? Element()
        
        let attack: Float = Float(skill.power)/100 * Float(attacker.getModifiedBase().attack) * 16
        let defense: Float = max(Float(defender.getModifiedBase().defense), 1.0) //prevent division by zero
        
        var dmg: Float = attack/defense
        dmg *= getElementalModifier(attacker: attacker, defender: defender, skillElement: element)
        
        let chance: Int = Int.random(in: 0 ..< 100)
        if chance < attacker.getModifiedBase().precision/10 {
            dmg *= 1.5
            text = "It's a critical hit."
        }
        
        let damage: Int = Int(round(dmg))
        
        if damage >= defender.currhp {
            print(damage)
            return (damage: defender.currhp, text: "\n")
        }
        
        print(damage)
        return (damage: damage, text: text + "\n")
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
