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
        if chance >= spell.chance + attacker.getModifiedBase().precision/8 {
            return Localization.shared.getTranslation(key: "hexFailed") + "\n"
        }
        
        var hex: String? = spell.hex
        
        //determine actual target
        var target: Witch = defender
        if spell.range == 0 {
            target = attacker
        }
        
        if target.getArtifact().name == Artifacts.amulet.rawValue { //get opposite hex
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
                if target.applyHex(hex: Hexes.attackBoost.getHex(), resistable: spell.range == 0 ? false : true) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "attack"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.attackDrop.rawValue:
                if target.applyHex(hex: Hexes.attackDrop.getHex(), resistable: spell.range == 0 ? false : true) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "attack"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.defenseBoost.rawValue:
                if target.applyHex(hex: Hexes.defenseBoost.getHex(), resistable: spell.range == 0 ? false : true) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "defense"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.defenseDrop.rawValue:
                if target.applyHex(hex: Hexes.defenseDrop.getHex(), resistable: spell.range == 0 ? false : true) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "defense"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.agilityBoost.rawValue:
                if target.applyHex(hex: Hexes.agilityBoost.getHex(), resistable: spell.range == 0 ? false : true) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "agility"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.agilityDrop.rawValue:
                if target.applyHex(hex: Hexes.agilityDrop.getHex(), resistable: spell.range == 0 ? false : true) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "agility"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.precisionBoost.rawValue:
                if target.applyHex(hex: Hexes.precisionBoost.getHex(), resistable: spell.range == 0 ? false : true) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "precision"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.precisionDrop.rawValue:
                if target.applyHex(hex: Hexes.precisionDrop.getHex(), resistable: spell.range == 0 ? false : true) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "precision"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.resistanceBoost.rawValue:
                if target.applyHex(hex: Hexes.precisionBoost.getHex(), resistable: spell.range == 0 ? false : true) {
                    return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "resistance"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            case Hexes.resistanceDrop.rawValue:
                if target.applyHex(hex: Hexes.precisionDrop.getHex(), resistable: spell.range == 0 ? false : true) {
                    return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "resistance"]) + "\n"
                } else {
                    return Localization.shared.getTranslation(key: "hexFailed") + "\n"
                }
            default: //non stat hexes or unknown hex
                if let appliedHex = Hexes(rawValue: hex!)?.getHex() {
                    if target.applyHex(hex: appliedHex, resistable: spell.range == 0 ? false : true) {
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
