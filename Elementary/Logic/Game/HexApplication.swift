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
    ///   - player: The player of the fighter using the spell
    ///   - oppositePlayer: The opposing player regardless of actual spell target
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - spell: The part of the spell used to make the attack
    ///   - weather: The current weather of the fight
    ///   - resistable: Indicates wether the hex can be resisted or not
    /// - Returns: Returns a description of what occured during the application of the hex
    func applyHex(player: Player, oppositePlayer: Player, attacker: Fighter, defender: Fighter, spell: SubSpell, weather: Hex?, resistable: Bool) -> String {
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
        var targetPlayer: Player = oppositePlayer
        if defender.getArtifact().name == Artifacts.mirror.rawValue && weather?.name != Weather.volcanicStorm.rawValue {
            target = attacker
            targetPlayer = player
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
        if hex != nil {
            if let appliedHex: Hex = Hexes(rawValue: hex!)?.getHex() {
                switch target.applyHex(hex: appliedHex, resistable: resistable) {
                case 1:
                    AudioPlayer.shared.playCancelSound()
                    return Localization.shared.getTranslation(key: "hexFailed")
                case 2:
                    AudioPlayer.shared.playCancelSound()
                    return Localization.shared.getTranslation(key: "hexResisted", params: [target.name])
                default:
                    AudioPlayer.shared.playConfirmSound()
                    if AudioPlayer.shared.hapticToggle {
                        let haptic: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                        haptic.impactOccurred()
                    }
                    
                    if appliedHex.positive {
                        targetPlayer.setState(state: PlayerState.hexPositive, fighter: target)
                    } else {
                        targetPlayer.setState(state: PlayerState.hexNegative, fighter: target)
                    }
                    
                    return Localization.shared.getTranslation(key: hex!, params: [target.name])
                    
                }
            }
        }
        
        AudioPlayer.shared.playCancelSound()
        return Localization.shared.getTranslation(key: "hexFailed")
    }
}
