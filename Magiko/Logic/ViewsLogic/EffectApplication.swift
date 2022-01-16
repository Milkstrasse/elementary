//
//  EffectApplication.swift
//  Magiko
//
//  Created by Janice Hablützel on 10.01.22.
//

struct EffectApplication {
    static let shared: EffectApplication = EffectApplication()
    
    /// Tries to apply an effect on the targeted fighter.
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be attacked
    ///   - skill: The skill used to make the attack
    /// - Returns: Returns a description of what occured during the application of the effect
    func applyEffect(attacker: Fighter, defender: Fighter, skill: SubSkill) -> String {
        let chance: Int = Int.random(in: 0 ..< 100)
        if chance > skill.chance {
            return Localization.shared.getTranslation(key: "effectFailed") + "\n"
        }
        
        var effect: String? = skill.effect
        
        //determine actual target
        var target: Fighter = defender
        if skill.range == 0 {
            target = attacker
        }
        
        if target.ability.name == Abilities.contrarian.rawValue { //get opposite effect
            if effect != nil {
                effect = Effects(rawValue: effect!)?.getEffect().opposite?.rawValue
                if effect == nil {
                    effect = skill.effect
                }
            }
        }
        
        //try to apply effect
        switch effect {
            case Effects.attackBoost.rawValue:
                if target.applyEffect(effect: Effects.attackBoost.getEffect()) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "attack"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "effectFailed") + "\n"
                }
            case Effects.attackDrop.rawValue:
                if target.applyEffect(effect: Effects.attackDrop.getEffect()) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "attack"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "effectFailed") + "\n"
                }
            case Effects.defenseBoost.rawValue:
                if target.applyEffect(effect: Effects.defenseBoost.getEffect()) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "defense"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "effectFailed") + "\n"
                }
            case Effects.defenseDrop.rawValue:
                if target.applyEffect(effect: Effects.defenseDrop.getEffect()) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "defense"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "effectFailed") + "\n"
                }
            case Effects.agilityBoost.rawValue:
                if target.applyEffect(effect: Effects.agilityBoost.getEffect()) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "agility"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "effectFailed") + "\n"
                }
            case Effects.agilityDrop.rawValue:
                if target.applyEffect(effect: Effects.agilityDrop.getEffect()) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "agility"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "effectFailed") + "\n"
                }
            case Effects.precisionBoost.rawValue:
                if target.applyEffect(effect: Effects.precisionBoost.getEffect()) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "precision"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "effectFailed") + "\n"
                }
            case Effects.precisionDrop.rawValue:
                if target.applyEffect(effect: Effects.precisionDrop.getEffect()) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "precision"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "effectFailed") + "\n"
                }
            default: //non stat effects or unknown effect
                if let appliedEffect = Effects(rawValue: effect!)?.getEffect() {
                    if target.applyEffect(effect: appliedEffect) {
                        return Localization.shared.getTranslation(key: "becameEffect", params: [target.name, appliedEffect.name]) + "\n"
                    } else {
                        return Localization.shared.getTranslation(key: "effectFailed") + "\n"
                    }
                } else {
                    return Localization.shared.getTranslation(key: "effectFailed") + "\n"
                }
        }
    }
}
