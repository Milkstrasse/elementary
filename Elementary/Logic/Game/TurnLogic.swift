//
//  TurnLogic.swift
//  Elementary
//
//  Created by Janice Hablützel on 14.01.22.
//

import SwiftUI

/// This is the main logic for a player's turn.  It determines whether fighter uses their spell or an other action.
class TurnLogic {
    static let shared: TurnLogic = TurnLogic()
    
    private var fightLogic: FightLogic?
    
    /// Starts the turn of the player. Determines whether fighter uses their spell or an other action.
    /// - Parameters:
    ///   - player: The player
    ///   - fightLogic: Access to fighter info
    /// - Returns: Returns a description of what occured during the player's turn
    func startTurn(player: Player, fightLogic: FightLogic) -> String {
        self.fightLogic = fightLogic
        
        let attacker: Fighter = player.getCurrentFighter()
        let move: Move = fightLogic.playerQueue[0].move
        
        switch move.type {
        case .special:
            if attacker.currhp == 0 { //fighter faints
                return Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name])
            } else { //fighter leaves
                return Localization.shared.getTranslation(key: "nameRetreated", params: [attacker.name])
            }
        case .hex:
            let damage: Int = attacker.getModifiedBase().health/(100/attacker.hexes[move.index].damageAmount)
            
            if damage >= attacker.currhp {
                attacker.currhp = 0
                player.setState(state: PlayerState.hurting)
                player.hasToSwap = true
                
                return Localization.shared.getTranslation(key: "namePerished", params: [attacker.name])
            } else if damage > 0 {
                attacker.currhp -= damage
                player.setState(state: PlayerState.hurting)
                
                return Localization.shared.getTranslation(key: "lostHP", params: [attacker.name])
            } else if damage < attacker.currhp - attacker.getModifiedBase().health {
                attacker.currhp = attacker.getModifiedBase().health
                player.setState(state: PlayerState.healing)
                
                return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name])
            } else {
                attacker.currhp -= damage
                player.setState(state: PlayerState.healing)
                
                return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name])
            }
        case .artifact:
            if move.index < 0 {
                if attacker.getArtifact().name == Artifacts.cornucopia.rawValue {
                    if attacker.getModifiedBase().health - attacker.currhp <= attacker.getModifiedBase().health/16 {
                        attacker.currhp = attacker.getModifiedBase().health
                    } else {
                        attacker.currhp += attacker.getModifiedBase().health/16
                    }
                } else if attacker.getArtifact().name == Artifacts.potion.rawValue {
                    if attacker.getModifiedBase().health - attacker.currhp <= attacker.getModifiedBase().health/4 {
                        attacker.currhp = attacker.getModifiedBase().health
                    } else {
                        attacker.currhp += attacker.getModifiedBase().health/4
                    }
                    
                    player.getCurrentFighter().overrideArtifact(artifact: Artifacts.noArtifact.getArtifact())
                }
                
                player.setState(state: PlayerState.healing)
            } else if move.index >= 0 { //recoil damage from artifact
                player.setState(state: PlayerState.hurting)
                let target: Fighter = player.getCurrentFighter()
                let damage: Int = target.getModifiedBase().health/10
                
                if damage >= target.currhp { //prevent hp below 0
                    target.currhp = 0
                } else {
                    target.currhp -= damage
                }
                
                print(target.name + " lost \(damage)DMG.\n")
                
                return Localization.shared.getTranslation(key: "hit")
            }
            
            return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name])
        default: //spell move
            if move.index == -1 {
                player.setState(state: PlayerState.attacking)
                return Localization.shared.getTranslation(key: "usedSpell", params: [attacker.name, move.spell.name])
            }
            
            //if fighter was forced to use spells with no uses
            if move.spell.useCounter - attacker.manaUse > move.spell.uses {
                return Localization.shared.getTranslation(key: "fail")
            }
            
            return attack(player: player, move: move)
        }
    }
    
    /// Fighter uses their spell to attack, heal or to do another action.
    /// - Parameters:
    ///   - player: The player
    ///   - move: The move used to make the attack
    /// - Returns: Returns a description of what occured during the player's attack
    private func attack(player: Player, move: Move) -> String {
        var spell: Spell = move.spell
        
        //determine actual target
        var oppositePlayer: Player = fightLogic!.players[0]
        if player.id == 0 {
            oppositePlayer = fightLogic!.players[1]
        }
        
        //checks if targeted user is successfully shielded or not
        var usedShield: Bool = false
        if spell.spells[move.index].range > 0 {
            if oppositePlayer.getCurrentFighter().lastSpell?.typeID == 13 {
                if spell.typeID != 2 {
                    return Localization.shared.getTranslation(key: "fail")
                } else {
                    usedShield = true
                }
            }
        }
        
        if player.getCurrentFighter().hasHex(hexName: Hexes.taunted.rawValue) && spell.spells[move.index].power <= 0 {
            return Localization.shared.getTranslation(key: "fail")
        }
        
        let usedSpell: SubSpell = spell.spells[move.index]
        
        //determine what kind of attack this is
        if usedSpell.power > 0 { //damaging attack
            if usedSpell.range == 1 {
                if oppositePlayer.getCurrentFighter().currhp == 0 || oppositePlayer.hasToSwap { //target no longer fighting
                    return Localization.shared.getTranslation(key: "fail")
                }
                
                oppositePlayer.setState(state: PlayerState.hurting)
                
                if oppositePlayer.getCurrentFighter().getArtifact().name == Artifacts.talaria.rawValue && oppositePlayer.isAbleToSwap() && fightLogic?.weather?.name != Weather.volcanicStorm.rawValue {
                    oppositePlayer.hasToSwap = true
                }
            } else {
                player.setState(state: PlayerState.hurting)
            }
            
            return DamageCalculator.shared.applyDamage(attacker: player.getCurrentFighter(), defender: oppositePlayer.getCurrentFighter(), spell: &spell, subSpell: usedSpell, spellElement: spell.element, weather: fightLogic!.weather, usedShield: usedShield)
        } else if usedSpell.hex != nil { //hex adding spell
            if fightLogic?.weather?.name == Weather.springWeather.rawValue {
                return Localization.shared.getTranslation(key: "hexFailed")
            } else {
                return HexApplication.shared.applyHex(attacker: player.getCurrentFighter(), defender: oppositePlayer.getCurrentFighter(), spell: usedSpell, weather: fightLogic?.weather)
            }
        } else if usedSpell.healAmount > 0 {
            if usedSpell.range == 0 {
                player.setState(state: PlayerState.healing)
            } else {
                oppositePlayer.setState(state: PlayerState.healing)
            }
            
            return applyHealing(attacker: player.getCurrentFighter(), defender: oppositePlayer.getCurrentFighter(), spell: usedSpell)
        } else if usedSpell.weather != nil { //weather adding spell
            let newWeather: String? = Weather(rawValue: usedSpell.weather ?? "")?.rawValue
            
            if newWeather != nil && fightLogic?.weather?.name != newWeather {
                if player.getCurrentFighter().getArtifact().name == Artifacts.crystal.rawValue {
                    fightLogic!.weather = Weather(rawValue: usedSpell.weather!)?.getHex(duration: 7)
                } else {
                    fightLogic!.weather = Weather(rawValue: usedSpell.weather!)?.getHex(duration: 5)
                }
                
                AudioPlayer.shared.playConfirmSound()
                return Localization.shared.getTranslation(key: "weatherChanged", params: [fightLogic!.weather!.name])
            } else { //weather already active or invalid weather
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "weatherFailed")
            }
        } else {
            switch spell.typeID {
            case 6:
                if player.isAbleToSwap() {
                    player.hasToSwap = true
                    return Localization.shared.getTranslation(key: "retreated", params: [player.getCurrentFighter().name])
                }
            case 13:
                //shield can't be used twice in a row -> failure
                if player.getCurrentFighter().lastSpell?.name == "shieldFail" {
                    return Localization.shared.getTranslation(key: "fail")
                } else {
                    return Localization.shared.getTranslation(key: "nameProtected", params: [player.getCurrentFighter().name])
                }
            case 15:
                if oppositePlayer.isAbleToSwap() {
                    oppositePlayer.hasToSwap = true
                    return Localization.shared.getTranslation(key: "forcedOut", params: [oppositePlayer.getCurrentFighter().name])
                }
            case 16:
                let hexes: [Hex] = player.getCurrentFighter().hexes
                
                player.getCurrentFighter().removeAllHexes()
                for hex in oppositePlayer.getCurrentFighter().hexes {
                    player.getCurrentFighter().applyHex(hex: hex, resistable: false)
                }
                
                oppositePlayer.getCurrentFighter().removeAllHexes()
                for hex in hexes {
                    oppositePlayer.getCurrentFighter().applyHex(hex: hex, resistable: false)
                }
                
                return Localization.shared.getTranslation(key: "swappedHexes")
            case 17:
                player.getCurrentFighter().removeAllHexes()
                oppositePlayer.getCurrentFighter().removeAllHexes()
                
                return Localization.shared.getTranslation(key: "clearedHexes")
            case 18:
                oppositePlayer.getCurrentFighter().overrideElement(newElement: player.getCurrentFighter().getElement())
                return Localization.shared.getTranslation(key: "elementChanged", params: [oppositePlayer.getCurrentFighter().name, player.getCurrentFighter().getElement().name])
            case 19:
                player.wishActivated = true
                player.getCurrentFighter().currhp = 0
                player.hasToSwap = true
                
                return Localization.shared.getTranslation(key: "nameFainted", params: [player.getCurrentFighter().name])
            case 20:
                let artifact: Artifact = player.getCurrentFighter().getArtifact()
                player.getCurrentFighter().overrideArtifact(artifact: oppositePlayer.getCurrentFighter().getArtifact())
                oppositePlayer.getCurrentFighter().overrideArtifact(artifact: artifact)
                
                return Localization.shared.getTranslation(key: "swappedArtifacts")
            default:
                break
            }
            
            return Localization.shared.getTranslation(key: "fail")
        }
    }
    
    /// Restores hitpoints of targeted fighter.
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - spell: The spell used to make the attack
    /// - Returns: Returns a description of what occured during healing
    private func applyHealing(attacker: Fighter, defender: Fighter, spell: SubSpell) -> String {
        var newHealth: Int
        
        //determine actual target
        var target: Fighter = defender
        if spell.range == 0 {
            target = attacker
        }
        
        if !target.hasHex(hexName: Hexes.blocked.rawValue) {
            newHealth = target.getModifiedBase().health/(100/spell.healAmount)
            if newHealth >= (target.getModifiedBase().health - target.currhp) {
                target.currhp = target.getModifiedBase().health
            } else {
                target.currhp += newHealth
            }
            
            return Localization.shared.getTranslation(key: "gainedHP", params: [target.name])
        }
        
        return Localization.shared.getTranslation(key: "healFailed")
    }
}
