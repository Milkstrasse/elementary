//
//  EffectApplication.swift
//  Magiko
//
//  Created by Janice Hablützel on 10.01.22.
//

struct EffectApplication {
    static let shared: EffectApplication = EffectApplication()
    
    func applyEffect(attacker: Fighter, defender: Fighter, skill: SubSkill, skillName: String?) -> String {
        var text: String = ""
        
        if skill.range == 0 {
            text = applyStats(attacker: attacker, target: attacker, skill: skill)
        } else {
            text = applyStats(attacker: attacker, target: defender, skill: skill)
        }
        
        if skillName != nil {
            text = attacker.name + " used " + skillName! + ".\n" + text
        }
        
        return text
    }
    
    func applyStats(attacker: Fighter, target: Fighter, skill: SubSkill) -> String {
        let chance: Int = Int.random(in: 0 ..< 100)
        if chance > skill.chance + attacker.getModifiedBase().precision/100 {
            return "The effect failed.\n"
        }
        
        var text: String = ""
        
        switch skill.effect {
            case Effects.attackBoost.rawValue:
                if target.applyEffect(effect: Effects.attackBoost.getEffect()) {
                    text = target.name + "'s attack increased.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.attackDrop.rawValue:
                if target.applyEffect(effect: Effects.attackDrop.getEffect()) {
                    text = target.name + "'s attack decreased.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.defenseBoost.rawValue:
                if target.applyEffect(effect: Effects.defenseBoost.getEffect()) {
                    text = target.name + "'s defense increased.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.defenseDrop.rawValue:
                if target.applyEffect(effect: Effects.defenseDrop.getEffect()) {
                    text = target.name + "'s defense decreased.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.agilityBoost.rawValue:
                if target.applyEffect(effect: Effects.agilityBoost.getEffect()) {
                    text = target.name + "'s agility increased.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.agilityDrop.rawValue:
                if target.applyEffect(effect: Effects.agilityDrop.getEffect()) {
                    text = target.name + "'s agility decreased.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.precisionBoost.rawValue:
                if target.applyEffect(effect: Effects.precisionBoost.getEffect()) {
                    text = target.name + "'s precision increased.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.precisionDrop.rawValue:
                if target.applyEffect(effect: Effects.precisionDrop.getEffect()) {
                    text = target.name + "'s precision decreased.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.poison.rawValue:
                if target.applyEffect(effect: Effects.poison.getEffect()) {
                    text = target.name + " was poisoned.\n"
                }
            case Effects.healing.rawValue:
                if target.applyEffect(effect: Effects.healing.getEffect()) {
                    text = target.name + "was healed.\n"
                }
            case Effects.curse.rawValue:
                if target.applyEffect(effect: Effects.curse.getEffect()) {
                    text = target.name + "was cursed.\n"
                }
            default:
                text = "The effect failed.\n"
        }
        
        return text
    }
}
