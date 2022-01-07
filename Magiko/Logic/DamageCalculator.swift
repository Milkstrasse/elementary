//
//  DamageCalculator.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import Foundation

struct DamageCalculator {
    static let shared = DamageCalculator()
    
    func calcDamage(attacker: Fighter, defender: Fighter, skill: SubSkill) -> UInt {
        let attack: Float = Float(skill.power)/100 * Float(attacker.getModifiedBase().attack) * 16
        let defense: Float = Float(defender.getModifiedBase().defense)
        
        let dmg: UInt = UInt(round(attack/defense))
        if dmg > defender.currhp {
            return defender.currhp
        }
        
        print(Int(dmg))
        
        return dmg
    }
}
