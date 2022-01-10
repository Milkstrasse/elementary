//
//  StatModifier.swift
//  Magiko
//
//  Created by Janice Hablützel on 10.01.22.
//

struct StatModifier {
    static let shared: StatModifier = StatModifier()
    
    func modifyStats(attacker: Fighter, defender: Fighter, skill: SubSkill, skillName: String?) -> String {
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
        
        target.attackMod += skill.attackMod
        
        if skill.attackMod > 0 {
            text += target.name + "'s attack increased.\n"
        } else if skill.attackMod < 0 {
            text += target.name + "'s attack decreased.\n"
        }
        
        target.defenseMod += skill.defenseMod
        
        if skill.defenseMod > 0 {
            text += target.name + "'s defense increased.\n"
        } else if skill.defenseMod < 0 {
            text += target.name + "'s defense decreased.\n"
        }
        
        target.agilityMod += skill.agilityMod
        
        if skill.agilityMod > 0 {
            text += target.name + "'s agility increased.\n"
        } else if skill.agilityMod < 0 {
            text += target.name + "'s agility decreased.\n"
        }
        
        target.precisionMod += skill.precisionMod
        
        if skill.precisionMod > 0 {
            text += target.name + "'s precision increased.\n"
        } else if skill.precisionMod < 0 {
            text += target.name + "'s precision decreased.\n"
        }
        
        target.spAttackMod += skill.spAttackMod
        
        if skill.spAttackMod > 0 {
            text += target.name + "'s special attack increased.\n"
        } else if skill.spAttackMod < 0 {
            text += target.name + "'s special attack decreased.\n"
        }
        
        return text
    }
}
