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
            case Effects.poison.rawValue:
                if target.applyEffect(effect: Effects.poison.getEffect()) {
                    text = target.name + " was poisoned.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.healing.rawValue:
                if target.applyEffect(effect: Effects.healing.getEffect()) {
                    text = target.name + " was healed.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.confused.rawValue:
                if target.applyEffect(effect: Effects.confused.getEffect()) {
                    text = target.name + " became confused.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.bomb.rawValue:
                if target.applyEffect(effect: Effects.bomb.getEffect()) {
                    text = target.name + " is doomed.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.blessing.rawValue:
                if target.applyEffect(effect: Effects.blessing.getEffect()) {
                    text = target.name + " was blessed.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.block.rawValue:
                if target.applyEffect(effect: Effects.block.getEffect()) {
                    text = target.name + " was blocked.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.chain.rawValue:
                if target.applyEffect(effect: Effects.chain.getEffect()) {
                    text = target.name + " is chained.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.invigorated.rawValue:
                if target.applyEffect(effect: Effects.invigorated.getEffect()) {
                    text = target.name + " became invigorated.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.exhausted.rawValue:
                if target.applyEffect(effect: Effects.exhausted.getEffect()) {
                    text = target.name + " became exhausted.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.locked.rawValue:
                if target.applyEffect(effect: Effects.locked.getEffect()) {
                    text = target.name + " became locked.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.revive.rawValue:
                if target.applyEffect(effect: Effects.revive.getEffect()) {
                    text = target.name + " became enlightened.\n"
                } else {
                    text = "The effect failed.\n"
                }
            case Effects.alert.rawValue:
                if target.applyEffect(effect: Effects.alert.getEffect()) {
                    text = target.name + " is now alert.\n"
                } else {
                    text = "The effect failed.\n"
                }
            default:
                text = "The effect failed.\n"
        }
        
        return text
    }
}
