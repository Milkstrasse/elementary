//
//  HexApplication.swift
//  Witchery
//
//  Created by Janice Hablützel on 10.01.22.
//

/// Tries to apply hex of a spell to the targeted witch.
struct HexApplication {
    static let shared: HexApplication = HexApplication()
    
    /// Tries to apply an hex on the targeted witch.
    /// - Parameters:
    ///   - attacker: The witch that attacks
    ///   - defender: The witch to be targeted
    ///   - spell: The spell used to make the attack
    /// - Returns: Returns a description of what occured during the application of the hex
    func applyHex(attacker: Witch, defender: Witch, spell: SubSpell) -> String {
        let chance: Int = Int.random(in: 0 ..< 100)
        if chance > spell.chance {
            return Localization.shared.getTranslation(key: "hexFailed") + "\n"
        }
        
        var hex: String? = spell.hex
        
        //determine actual target
        var target: Witch = defender
        if spell.range == 0 {
            target = attacker
        }
        
        if target.ability.name == Abilities.contrarian.rawValue { //get opposite hex
            if hex != nil {
                hex = Hexes(rawValue: hex!)?.getHex().opposite?.rawValue
                if hex == nil {
                    hex = spell.hex
                }
            }
        }
        
        //try to apply hex
        switch hex {
            case Hexes.attackBoost.rawValue:
                if target.applyHex(hex: Hexes.attackBoost.getHex()) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "attack"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.attackDrop.rawValue:
                if target.applyHex(hex: Hexes.attackDrop.getHex()) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "attack"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.defenseBoost.rawValue:
                if target.applyHex(hex: Hexes.defenseBoost.getHex()) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "defense"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.defenseDrop.rawValue:
                if target.applyHex(hex: Hexes.defenseDrop.getHex()) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "defense"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.agilityBoost.rawValue:
                if target.applyHex(hex: Hexes.agilityBoost.getHex()) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "agility"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.agilityDrop.rawValue:
                if target.applyHex(hex: Hexes.agilityDrop.getHex()) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "agility"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.precisionBoost.rawValue:
                if target.applyHex(hex: Hexes.precisionBoost.getHex()) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "precision"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.precisionDrop.rawValue:
                if target.applyHex(hex: Hexes.precisionDrop.getHex()) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "precision"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            default: //non stat hexes or unknown hex
                if let appliedHex = Hexes(rawValue: hex!)?.getHex() {
                    if target.applyHex(hex: appliedHex) {
                        return Localization.shared.getTranslation(key: "becameHex", params: [target.name, appliedHex.name]) + "\n"
                    } else {
                        return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                    }
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
        }
    }
}
