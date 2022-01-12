//
//  Healer.swift
//  Magiko
//
//  Created by Janice Hablützel on 12.01.22.
//

struct Healer {
    static let shared: Healer = Healer()
    
    func applyHealing(attacker: Fighter, defender: Fighter, skill: SubSkill) -> String {
        var newHealth: Int
        if skill.range == 0 && !attacker.hasEffect(effectName: Effects.block.rawValue) {
            newHealth = attacker.getModifiedBase().health/(100/skill.healAmount)
            if newHealth >= (attacker.getModifiedBase().health - attacker.currhp) {
                attacker.currhp = attacker.getModifiedBase().health
            } else {
                attacker.currhp += newHealth
            }
            
            return attacker.name + " recovered health.\n"
        } else if !defender.hasEffect(effectName: Effects.block.rawValue) {
            newHealth = defender.getModifiedBase().health/(100/skill.healAmount)
            if newHealth >= (defender.getModifiedBase().health - defender.currhp) {
                defender.currhp = defender.getModifiedBase().health
            } else {
                defender.currhp += newHealth
            }
            
            return defender.name + " recovered health.\n"
        }
        
        return "Healing failed.\n"
    }
}
