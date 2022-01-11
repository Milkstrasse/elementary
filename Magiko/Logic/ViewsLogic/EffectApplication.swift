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
            text = applyStats(target: attacker, skill: skill)
        } else {
            text = applyStats(target: defender, skill: skill)
        }
        
        if skillName != nil {
            text = attacker.name + " used " + skillName! + ".\n" + text
        }
        
        return text
    }
    
    func applyStats(target: Fighter, skill: SubSkill) -> String {
        var text: String = ""
        
        switch skill.effect {
            case "attackBoost":
                if target.applyEffect(effect: Effects.attackBoost.getEffect()) {
                    text += target.name + "'s attack increased.\n"
                } else {
                    text += "The effect failed.\n"
                }
            case "attackDrop":
                if target.applyEffect(effect: Effects.attackDrop.getEffect()) {
                    text += target.name + "'s attack decreased.\n"
                } else {
                    text += "The effect failed.\n"
                }
            case "defenseBoost":
                if target.applyEffect(effect: Effects.defenseBoost.getEffect()) {
                    text += target.name + "'s defense increased.\n"
                } else {
                    text += "The effect failed.\n"
                }
            case "defenseDrop":
                if target.applyEffect(effect: Effects.defenseDrop.getEffect()) {
                    text += target.name + "'s defense decreased.\n"
                } else {
                    text += "The effect failed.\n"
                }
            case "agilityBoost":
                if target.applyEffect(effect: Effects.agilityBoost.getEffect()) {
                    text += target.name + "'s agility increased.\n"
                } else {
                    text += "The effect failed.\n"
                }
            case "agilityDrop":
                if target.applyEffect(effect: Effects.agilityDrop.getEffect()) {
                    text += target.name + "'s agility decreased.\n"
                } else {
                    text += "The effect failed.\n"
                }
            case "precisionBoost":
                if target.applyEffect(effect: Effects.precisionBoost.getEffect()) {
                    text += target.name + "'s precision increased.\n"
                } else {
                    
                }
            case "precisionDrop":
                if target.applyEffect(effect: Effects.precisionDrop.getEffect()) {
                    text += target.name + "'s precision decreased.\n"
                } else {
                    text += "The effect failed.\n"
                }
            default:
                text += "The effect failed.\n"
        }
        
        return text
    }
}
