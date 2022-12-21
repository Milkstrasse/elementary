//
//  HexApplication.swift
//  Elementary
//
//  Created by Janice Hablützel on 10.01.22.
//

import SwiftUI

/// Tries to apply hex of a spell to the targeted fighter.
struct HexApplication {
    static let shared: HexApplication = HexApplication()
    
    /// Tries to apply an hex on the targeted fighter.
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - spell: The spell used to make the attack
    ///   - weather: The current weather of the fight
    /// - Returns: Returns a description of what occured during the application of the hex
    func applyHex(attacker: Fighter, defender: Fighter, spell: SubSpell, weather: Hex?) -> String {
        var hex: String? = spell.hex
        
        if hex != Hexes.taunted.rawValue {
            let chance: Int = Int.random(in: 0 ..< 100 + 100 - spell.chance)
            if chance >= (18 + attacker.getModifiedBase().precision) * (100/spell.chance) {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        }
        
        //determine actual target
        var target: Fighter = defender
        if spell.range == 0 || (defender.getArtifact().name == Artifacts.talisman.rawValue && weather?.name != Weather.volcanicStorm.rawValue) {
            target = attacker
        }
        
        if target.currhp == 0 {
            AudioPlayer.shared.playCancelSound()
            return Localization.shared.getTranslation(key: "hexFailed")
        }
        
        if target.getArtifact().name == Artifacts.amulet.rawValue && weather?.name != Weather.volcanicStorm.rawValue { //get opposite hex
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
                AudioPlayer.shared.playConfirmSound()
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
                
                return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "attack"])
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        case Hexes.attackDrop.rawValue:
            if target.applyHex(hex: Hexes.attackDrop.getHex(), resistable: spell.range == 0 ? false : true) {
                AudioPlayer.shared.playConfirmSound()
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
                
                return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "attack"])
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        case Hexes.defenseBoost.rawValue:
            if target.applyHex(hex: Hexes.defenseBoost.getHex(), resistable: spell.range == 0 ? false : true) {
                AudioPlayer.shared.playConfirmSound()
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
                
                return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "defense"])
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        case Hexes.defenseDrop.rawValue:
            if target.applyHex(hex: Hexes.defenseDrop.getHex(), resistable: spell.range == 0 ? false : true) {
                AudioPlayer.shared.playConfirmSound()
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
                
                return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "defense"])
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        case Hexes.agilityBoost.rawValue:
            if target.applyHex(hex: Hexes.agilityBoost.getHex(), resistable: spell.range == 0 ? false : true) {
                AudioPlayer.shared.playConfirmSound()
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
                
                return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "agility"])
            } else {
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        case Hexes.agilityDrop.rawValue:
            if target.applyHex(hex: Hexes.agilityDrop.getHex(), resistable: spell.range == 0 ? false : true) {
                AudioPlayer.shared.playConfirmSound()
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
                
                return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "agility"])
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        case Hexes.precisionBoost.rawValue:
            if target.applyHex(hex: Hexes.precisionBoost.getHex(), resistable: spell.range == 0 ? false : true) {
                AudioPlayer.shared.playConfirmSound()
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
                
                return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "precision"])
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        case Hexes.precisionDrop.rawValue:
            if target.applyHex(hex: Hexes.precisionDrop.getHex(), resistable: spell.range == 0 ? false : true) {
                AudioPlayer.shared.playConfirmSound()
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
                
                return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "precision"])
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        case Hexes.resistanceBoost.rawValue:
            if target.applyHex(hex: Hexes.resistanceBoost.getHex(), resistable: spell.range == 0 ? false : true) {
                AudioPlayer.shared.playConfirmSound()
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
                
                return Localization.shared.getTranslation(key: "statIncreased", params: [target.name, "resistance"])
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        case Hexes.resistanceDrop.rawValue:
            if target.applyHex(hex: Hexes.resistanceDrop.getHex(), resistable: spell.range == 0 ? false : true) {
                AudioPlayer.shared.playConfirmSound()
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
                
                return Localization.shared.getTranslation(key: "statDecreased", params: [target.name, "resistance"])
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        case Hexes.taunted.rawValue:
            if target.applyHex(hex: Hexes.taunted.getHex(), resistable: false) {
                AudioPlayer.shared.playConfirmSound()
                return Localization.shared.getTranslation(key: "nameProvoked", params: [target.name])
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        default: //non stat hexes or unknown hex
            if let appliedHex = Hexes(rawValue: hex!)?.getHex() {
                if target.applyHex(hex: appliedHex, resistable: spell.range == 0 ? false : true) {
                    AudioPlayer.shared.playConfirmSound()
                    if AudioPlayer.shared.hapticToggle {
                        let haptic = UIImpactFeedbackGenerator(style: .medium)
                        haptic.impactOccurred()
                    }
                    
                    return Localization.shared.getTranslation(key: "becameHex", params: [target.name, appliedHex.name])
                } else {
                    AudioPlayer.shared.playCancelSound()
                    return Localization.shared.getTranslation(key: "hexFailed")
                }
            } else {
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "hexFailed")
            }
        }
    }
}
