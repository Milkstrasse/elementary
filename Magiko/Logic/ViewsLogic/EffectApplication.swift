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
            text = Localization.shared.getTranslation(key: "usedSkill", params: [attacker.name, skillName!]) + "\n" + text
        }
        
        return text
    }
    
    func applyStats(attacker: Fighter, target: Fighter, skill: SubSkill) -> String {
        let chance: Int = Int.random(in: 0 ..< 100)
        if chance > skill.chance {
            return "The effect failed.\n"
        }
        
        var text: String = ""
        var effect: String? = skill.effect
        
        if target.ability.name == Abilities.contrarian.rawValue {
            if effect != nil {
                effect = Effects(rawValue: effect!)?.getEffect().opposite?.rawValue
                if effect == nil {
                    effect = skill.effect
                }
            }
        }
        
        switch effect {
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
            default:
                if let appliedEffect = Effects(rawValue: effect!)?.getEffect() {
                    if target.applyEffect(effect: appliedEffect) {
                        text = Localization.shared.getTranslation(key: "becameEffect", params: [target.name, appliedEffect.name]) + "\n"
                    } else {
                        text = "The effect failed.\n"
                    }
                } else {
                    text = "The effect failed.\n"
                }
        }
        
        return text
    }
}
