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
        
        let move: Move = fightLogic.playerQueue[0].move
        let attacker: Fighter = move.source
        
        switch move.type {
        case .special:
            if fightLogic.singleMode {
                player.hasToSwap = true
            }
            attacker.hasSwapped = true
            
            if attacker.currhp == 0 { //fighter faints
                return Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name])
            } else { //fighter leaves
                return Localization.shared.getTranslation(key: "nameRetreated", params: [attacker.name])
            }
        case .hex:
            let damage: Int = attacker.getModifiedBase().health/(100/attacker.hexes[move.index].damageAmount)
            
            if damage >= attacker.currhp { //prevent hp below 0
                attacker.currhp = 0
                player.setState(state: PlayerState.hurting, fighter: attacker)
                if fightLogic.singleMode {
                    player.hasToSwap = true
                }
                
                return Localization.shared.getTranslation(key: "namePerished", params: [attacker.name])
            } else if damage > 0 {
                attacker.currhp -= damage
                player.setState(state: PlayerState.hurting, fighter: attacker)
                
                return Localization.shared.getTranslation(key: "lostHP", params: [attacker.name])
            } else if damage < attacker.currhp - attacker.getModifiedBase().health {
                attacker.currhp = attacker.getModifiedBase().health
                player.setState(state: PlayerState.healing, fighter: attacker)
                
                return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name])
            } else {
                attacker.currhp -= damage
                player.setState(state: PlayerState.healing, fighter: attacker)
                
                print(attacker.name + "gained \(-damage)HP")
                
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
                    
                    attacker.overrideArtifact(artifact: Artifacts.noArtifact.getArtifact())
                }
                
                player.setState(state: PlayerState.healing, fighter: attacker)
            } else if move.index >= 0 {
                player.setState(state: PlayerState.hurting, fighter: attacker)
                let damage: Int
                
                if move.index == 2 {
                    damage = attacker.getModifiedBase().health
                } else { //recoil damage from sword or helmet artifact
                    damage = attacker.getModifiedBase().health/10
                }
                
                if damage >= attacker.currhp { //prevent hp below 0
                    if attacker.currhp == attacker.getModifiedBase().health && attacker.getArtifact().name == Artifacts.ring.rawValue {
                        attacker.currhp = 1
                        attacker.overrideArtifact(artifact: Artifacts.noArtifact.getArtifact())
                    } else {
                        attacker.currhp = 0
                    }
                } else {
                    attacker.currhp -= damage
                }
                
                print(attacker.name + " lost \(damage)DMG.")
                
                return Localization.shared.getTranslation(key: "lostHP", params: [attacker.name])
            }
            
            return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name])
        default: //spell move
            let spell: Spell
            if fightLogic.singleMode {
                spell = move.source.singleSpells[move.spell]
            } else {
                spell = move.source.multiSpells[move.spell]
            }
            
            if move.index == -1 {
                if spell.subSpells[0].range == 1 {
                    var oppositePlayer: Player = fightLogic.players[0]
                    if player.id == 0 {
                        oppositePlayer = fightLogic.players[1]
                    }
                    
                    oppositePlayer.setState(state: PlayerState.neutral, fighter: move.target)
                }
                
                player.setState(state: PlayerState.attacking, fighter: move.source)
                return Localization.shared.getTranslation(key: "usedSpell", params: [attacker.name, spell.name])
            }
            
            //if fighter was forced to use spells with no uses
            if spell.useCounter - attacker.manaUse > spell.uses {
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
        let spell: Spell
        if fightLogic!.singleMode {
            spell = move.source.singleSpells[move.spell]
        } else {
            spell = move.source.multiSpells[move.spell]
        }
        
        var oppositePlayer: Player = fightLogic!.players[0]
        if player.id == 0 {
            oppositePlayer = fightLogic!.players[1]
        }
        
        let usedSpell: SubSpell = spell.subSpells[move.index]
        
        //checks if targeted user is successfully shielded or not
        var usedShield: Bool = false
        if spell.subSpells[move.index].range == 1 {
            if fightLogic!.singleMode {
                if move.target.lastSpell >= 0 && move.target.singleSpells[move.target.lastSpell].typeID == 13 {
                    if spell.typeID != 2 {
                        return Localization.shared.getTranslation(key: "fail")
                    } else {
                        usedShield = true
                    }
                }
            } else {
                if move.target.lastSpell >= 0 && move.target.multiSpells[move.target.lastSpell].typeID == 13 {
                    if spell.typeID != 2 {
                        return Localization.shared.getTranslation(key: "fail")
                    } else {
                        usedShield = true
                    }
                }
            }
        }
        
        if move.source.hasHex(hexName: Hexes.taunted.rawValue) && spell.subSpells[move.index].power <= 0 {
            return Localization.shared.getTranslation(key: "fail")
        }
        
        //determine what kind of attack this is
        if usedSpell.power > 0 { //damaging attack
            if usedSpell.range == 1 {
                if move.target.currhp == 0 || oppositePlayer.hasToSwap { //target no longer fighting
                    return Localization.shared.getTranslation(key: "fail")
                }
                
                oppositePlayer.setState(state: PlayerState.hurting, fighter: move.target)
                
                if move.target.getArtifact().name == Artifacts.talaria.rawValue && oppositePlayer.isAbleToSwap(singleMode: fightLogic!.singleMode) && fightLogic?.weather?.name != Weather.volcanicStorm.rawValue {
                    oppositePlayer.hasToSwap = true
                }
            } else {
                player.setState(state: PlayerState.hurting, fighter: move.target)
            }
            
            return DamageCalculator.shared.applyDamage(attacker: move.source, defender: move.target, spell: move.spell, spellIndex: move.index, spellElement: spell.element, weather: fightLogic!.weather, usedShield: usedShield, singleMode: fightLogic!.singleMode)
        } else if usedSpell.hex != nil { //hex adding spell
            if player.id == 1 && fightLogic!.hasCPUPlayer {
                for (index, currHex) in Hexes.allCases.enumerated() {
                    if currHex.rawValue == usedSpell.hex {
                        GlobalData.shared.userProgress.hexUses[index] = true
                        break
                    }
                }
            }
            
            if fightLogic?.weather?.name == Weather.springWeather.rawValue {
                return Localization.shared.getTranslation(key: "hexFailed")
            } else {
                if usedSpell.range < 1 {
                    return HexApplication.shared.applyHex(player: oppositePlayer, oppositePlayer: player, attacker: move.source, defender: move.target, spell: usedSpell, weather: fightLogic?.weather)
                } else {
                    return HexApplication.shared.applyHex(player: player, oppositePlayer: oppositePlayer, attacker: move.source, defender: move.target, spell: usedSpell, weather: fightLogic?.weather)
                }
            }
        } else if usedSpell.healAmount > 0 {
            if usedSpell.range < 1 {
                player.setState(state: PlayerState.healing, fighter: move.target)
            } else {
                oppositePlayer.setState(state: PlayerState.healing, fighter: move.target)
            }
            
            return applyHealing(defender: move.target, spell: usedSpell)
        } else if usedSpell.weather != nil { //weather adding spell
            if player.id == 1 && fightLogic!.hasCPUPlayer {
                for (index, currWeather) in Weather.allCases.enumerated() {
                    if currWeather.rawValue == usedSpell.weather {
                        GlobalData.shared.userProgress.weatherUses[index] = true
                        break
                    }
                }
            }
            
            let newWeather: String? = Weather(rawValue: usedSpell.weather ?? "")?.rawValue
            
            if newWeather != nil && fightLogic?.weather?.name != newWeather {
                if move.source.getArtifact().name == Artifacts.crystal.rawValue {
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
                if player.isAbleToSwap(singleMode: fightLogic!.singleMode) {
                    player.hasToSwap = true
                    move.source.hasSwapped = true
                    return Localization.shared.getTranslation(key: "nameRetreated", params: [move.source.name])
                }
            case 13:
                //shield can't be used twice in a row -> failure
                if move.source.lastSpell == -2 {
                    return Localization.shared.getTranslation(key: "fail")
                } else {
                    return Localization.shared.getTranslation(key: "nameProtected", params: [move.source.name])
                }
            case 15:
                if oppositePlayer.isAbleToSwap(singleMode: fightLogic!.singleMode) {
                    oppositePlayer.hasToSwap = true
                    move.target.hasSwapped = true
                    return Localization.shared.getTranslation(key: "forcedOut", params: [move.target.name])
                }
            case 16:
                let hexes: [Hex] = move.source.hexes
                
                move.source.removeAllHexes()
                for hex in move.target.hexes {
                    move.source.applyHex(hex: hex, resistable: false)
                }
                
                move.target.removeAllHexes()
                for hex in hexes {
                    move.target.applyHex(hex: hex, resistable: false)
                }
                
                return Localization.shared.getTranslation(key: "swappedHexes")
            case 17:
                move.source.removeAllHexes()
                move.target.removeAllHexes()
                
                return Localization.shared.getTranslation(key: "clearedHexes")
            case 18:
                move.target.overrideElement(newElement: move.source.getElement())
                return Localization.shared.getTranslation(key: "elementChanged", params: [move.target.name, move.source.getElement().name])
            case 19:
                player.wishActivated = true
                move.source.currhp = 0
                player.setState(state: PlayerState.hurting, fighter: move.source)
                
                if fightLogic!.singleMode {
                    player.hasToSwap = true
                }
                move.target.hasSwapped = true
                
                return Localization.shared.getTranslation(key: "nameFainted", params: [move.target.name])
            case 20:
                let artifact: Artifact = move.source.getArtifact()
                move.source.overrideArtifact(artifact: move.target.getArtifact())
                move.target.overrideArtifact(artifact: artifact)
                
                return Localization.shared.getTranslation(key: "swappedArtifacts")
            default:
                break
            }
            
            return Localization.shared.getTranslation(key: "fail")
        }
    }
    
    /// Restores hitpoints of targeted fighter.
    /// - Parameters:
    ///   - defender: The fighter to be targeted
    ///   - spell: The part of the spell used to make the attack
    /// - Returns: Returns a description of what occured during healing
    private func applyHealing(defender: Fighter, spell: SubSpell) -> String {
        var newHealth: Int
        
        if !defender.hasHex(hexName: Hexes.blocked.rawValue) {
            newHealth = defender.getModifiedBase().health/(100/spell.healAmount)
            if newHealth >= (defender.getModifiedBase().health - defender.currhp) {
                defender.currhp = defender.getModifiedBase().health
            } else {
                defender.currhp += newHealth
            }
            
            print(defender.name + "gained \(newHealth)HP")
            return Localization.shared.getTranslation(key: "gainedHP", params: [defender.name])
        }
        
        return Localization.shared.getTranslation(key: "healFailed")
    }
}
