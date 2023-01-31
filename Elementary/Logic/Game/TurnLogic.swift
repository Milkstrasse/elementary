//
//  TurnLogic.swift
//  Elementary
//
//  Created by Janice Hablützel on 14.01.22.
//

import SwiftUI

/// This is the main logic for a player's turn.  It determines whether fighter uses their spell or an other action.
class TurnLogic {
    var fightLogic: FightLogic
    
    init(fightLogic: FightLogic) {
        self.fightLogic = fightLogic
    }
    
    /// Executes a move from the queue and skips unneccessary moves.
    /// - Parameters:
    ///   - player: The player that makes the move
    ///   - move: The move the player wants to make
    /// - Returns: Returns wether the move gets skipped or not
    func startTurn(player: Player, move: Move) -> Bool {
        let attacker: Fighter = player.getFighter(index: move.source)
        
        //check if move is skippable
        switch move.type {
        case .spell:
            if player.hasToSwap || attacker.currhp == 0 { //fighter is unable to use spells
                return true
            }
        case .special:
            if attacker.hasSwapped {
                return true
            } else if !player.hasToSwap && attacker.currhp > 0 { //fighter is still able to fight
                return true
            }
        case .hex:
            if player.hasToSwap || attacker.currhp == 0 { //fighter is no longer present
                return true
            } else if move.index >= attacker.hexes.count { //fighter has not enough hexes
                return true
            }
            
            let hex: Hex = attacker.hexes[move.index]
            
            if hex.damageAmount == 0 { //hex has no effect
                return true
            } else if hex.name == Hexes.bombed.rawValue && hex.duration != 1 { //hex has no effect yet
                return true
            } else if hex.name == Hexes.doomed.rawValue && hex.duration != 1 { //hex has no effect yet
                return true
            }
        case .artifact:
            if player.hasToSwap || attacker.currhp == 0 { //fighter is no longer present
                return true
            }
            
            let target: Fighter = fightLogic.players[move.targetedPlayer].getFighter(index: move.target)
            
            if fightLogic.weather?.name != Weather.volcanicStorm.rawValue {
                switch move.index {
                case 0:
                    if fightLogic.singleMode {
                        if attacker.getArtifact().name != Artifacts.sword.rawValue || attacker.singleSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    } else {
                        if attacker.getArtifact().name != Artifacts.sword.rawValue || attacker.multiSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    }
                case 1:
                    if fightLogic.singleMode {
                        if target.getArtifact().name != Artifacts.helmet.rawValue || attacker.singleSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    } else {
                        if target.getArtifact().name != Artifacts.helmet.rawValue || attacker.multiSpells[move.spell].subSpells[0].power == 0 {
                            return true
                        }
                    }
                case 2:
                    if (target.getArtifact().name != Artifacts.thread.rawValue && attacker.getArtifact().name != Artifacts.thread.rawValue) || target.currhp > 0 {
                        return true
                    }
                default:
                    if attacker.getArtifact().name != Artifacts.cornucopia.rawValue { //artifact has no effect
                        return true
                    } else if attacker.getArtifact().name == Artifacts.potion.rawValue && attacker.currhp > attacker.getModifiedBase().health/2 { //artifact has no effect yet
                        return true
                    }
                }
            } else { //weather makes artifacts useless
                return true
            }
        default:
            break
        }
        
        //execute move
        if move.type == MoveType.swap { //check if swap possible
            if attacker.hasHex(hexName: Hexes.chained.rawValue) {
                fightLogic.fightLog.append(Localization.shared.getTranslation(key: "swapFailed", params: [attacker.name]))
            } else {
                fightLogic.fightLog.append(player.swapFighters(target: move.index, fightLogic: fightLogic))
            }
        } else {
            fightLogic.fightLog.append(startMove(player: player))
        }
        
        return false
    }
    
    /// Executes a player move. Determines whether fighter uses their spell or an other action.
    /// - Parameters:
    ///   - player: The player
    ///   - fightLogic: Access to fighter info
    /// - Returns: Returns a description of what occured during the player's turn
    private func startMove(player: Player) -> String {
        let move: Move = fightLogic.playerQueue.queue[0].move
        let attacker: Fighter = player.getFighter(index: move.source)
        
        //determine targeted fighter
        let defender: Fighter = fightLogic.players[move.targetedPlayer].getFighter(index: move.target)
        
        switch move.type {
        case .special:
            if fightLogic.singleMode {
                player.hasToSwap = true
            }
            defender.hasSwapped = true
            
            if defender.currhp == 0 { //fighter faints
                return Localization.shared.getTranslation(key: "nameFainted", params: [defender.name])
            } else { //fighter leaves
                return Localization.shared.getTranslation(key: "nameRetreated", params: [defender.name])
            }
        case .hex:
            let damage: Int = defender.getModifiedBase().health/(100/defender.hexes[move.index].damageAmount)
            
            if damage >= defender.currhp { //prevent hp below 0
                defender.currhp = 0
                player.setState(state: PlayerState.hurting, index:  move.target)
                if fightLogic.singleMode {
                    player.hasToSwap = true
                }
                
                return Localization.shared.getTranslation(key: "namePerished", params: [defender.name])
            } else if damage > 0 {
                defender.currhp -= damage
                player.setState(state: PlayerState.hurting, index: move.target)
                
                return Localization.shared.getTranslation(key: "lostHP", params: [defender.name])
            } else if damage < defender.currhp - defender.getModifiedBase().health {
                defender.currhp = defender.getModifiedBase().health
                player.setState(state: PlayerState.healing, index:  move.target)
                
                return Localization.shared.getTranslation(key: "gainedHP", params: [defender.name])
            } else {
                defender.currhp -= damage
                player.setState(state: PlayerState.healing, index:  move.target)
                
                print(defender.name + " gained \(-damage)HP")
                
                return Localization.shared.getTranslation(key: "gainedHP", params: [defender.name])
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
                
                player.setState(state: PlayerState.healing, index:  move.source)
                
                return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name])
            } else {
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
                
                player.setState(state: PlayerState.hurting, index: move.source)
                
                print(attacker.name + " lost \(damage)DMG.")
                
                return Localization.shared.getTranslation(key: "lostHP", params: [attacker.name])
            }
        default: //spell move
            let spell: Spell
            if fightLogic.singleMode {
                spell = attacker.singleSpells[move.spell]
            } else {
                spell = attacker.multiSpells[move.spell]
            }
            
            if move.index == -1 {
                if move.targetedPlayer != player.id {
                    let oppositePlayer: Player = fightLogic.players[player.getOppositePlayerId()]
                    oppositePlayer.setState(state: PlayerState.neutral, index: move.target)
                }
                
                player.setState(state: PlayerState.attacking, index: move.source)
                return Localization.shared.getTranslation(key: "usedSpell", params: [attacker.name, spell.name])
            }
            
            //if fighter was forced to use spells with no uses
            if spell.useCounter - attacker.manaUse > spell.uses {
                return Localization.shared.getTranslation(key: "spellFailed")
            }
            
            return startSpellTurn(player: player, move: move, attacker: attacker, defender: defender)
        }
    }
    
    /// Fighter uses their spell to attack, heal or to do another action.
    /// - Parameters:
    ///   - player: The player
    ///   - move: The move used to make the spell
    ///   - attacker: The fighter using the spell
    ///   - defender: The fighter being targeted
    /// - Returns: Returns a description of what occured with the player's spell
    private func startSpellTurn(player: Player, move: Move, attacker: Fighter, defender: Fighter) -> String {
        let spell: Spell
        if fightLogic.singleMode {
            spell = attacker.singleSpells[move.spell]
        } else {
            spell = attacker.multiSpells[move.spell]
        }
        
        let oppositePlayer: Player = fightLogic.players[move.targetedPlayer]
        
        let usedSpell: SubSpell = spell.subSpells[move.index]
        
        //checks if targeted user is successfully shielded or not
        var usedShield: Bool = false
        if usedSpell.range == 1 {
            if fightLogic.singleMode {
                if defender.lastSpell >= 0 && defender.singleSpells[defender.lastSpell].typeID == 13 {
                    if spell.typeID != 2 { //attack can't go through shield
                        return Localization.shared.getTranslation(key: "spellFailed") + " " + Localization.shared.getTranslation(key: "spellProtected", params: [defender.name])
                    } else {
                        usedShield = true
                    }
                }
            } else {
                if defender.lastSpell >= 0 && defender.multiSpells[defender.lastSpell].typeID == 13 {
                    if spell.typeID != 2 { //attack can't go through shield
                        return Localization.shared.getTranslation(key: "spellFailed") + " " + Localization.shared.getTranslation(key: "spellProtected", params: [defender.name])
                    } else {
                        usedShield = true
                    }
                }
            }
        }
        
        if attacker.hasHex(hexName: Hexes.taunted.rawValue) && usedSpell.power <= 0 { //taunted -> has to attack
            return Localization.shared.getTranslation(key: "spellFailed")
        }
        
        //determine what kind of attack this is
        if usedSpell.power > 0 { //damaging attack
            if defender.currhp == 0 || oppositePlayer.hasToSwap { //target no longer fighting
                return Localization.shared.getTranslation(key: "spellFailed")
            } else if move.index > 0 && defender.getArtifact().name == Artifacts.shield.rawValue && fightLogic.weather?.name != Weather.volcanicStorm.rawValue { //protection from seconary effects
                return Localization.shared.getTranslation(key: "spellFailed")
            } else if spell.typeID == 10 && (attacker.lastSpell >= 0 || attacker.lastSpell == -2) {
                return Localization.shared.getTranslation(key: "spellFailed")
            }
            
            if usedSpell.range == 1 {
                if spell.range < 3 {
                    player.setState(state: PlayerState.hurting, index: move.target)
                } else if spell.range < 5 {
                    oppositePlayer.setState(state: PlayerState.hurting, index: move.target)
                } else {
                    if move.target >= fightLogic.gameLogic.fighterCounts[0] {
                        player.setState(state: PlayerState.hurting, index: move.target)
                    } else {
                        oppositePlayer.setState(state: PlayerState.hurting, index: move.target)
                    }
                }
                
                if defender.getArtifact().name == Artifacts.talaria.rawValue && oppositePlayer.isAbleToSwap(singleMode: fightLogic.singleMode) && fightLogic.weather?.name != Weather.volcanicStorm.rawValue {
                    oppositePlayer.hasToSwap = true
                }
            } else {
                player.setState(state: PlayerState.hurting, index: move.target)
            }
            
            return DamageCalculator.shared.applyDamage(attacker: attacker, defender: defender, spell: move.spell, spellIndex: move.index, spellElement: spell.element, weather: fightLogic.weather, usedShield: usedShield, singleMode: fightLogic.singleMode)
        } else if usedSpell.hex != nil { //hex adding spell
            if player.id == 1 && fightLogic.hasCPUPlayer {
                for (index, currHex) in Hexes.allCases.enumerated() {
                    if currHex.rawValue == usedSpell.hex {
                        GlobalData.shared.userProgress.hexUses[index] = true
                        break
                    }
                }
            }
            
            if fightLogic.weather?.name == Weather.springWeather.rawValue {
                return Localization.shared.getTranslation(key: "hexFailed")
            } else {
                if move.index > 0 && defender.getArtifact().name == Artifacts.shield.rawValue && fightLogic.weather?.name != Weather.volcanicStorm.rawValue { //protection from seconary effects
                    return Localization.shared.getTranslation(key: "hexResisted")
                }
                
                if move.targetedPlayer == player.id {
                    return HexApplication.shared.applyHex(player: oppositePlayer, oppositePlayer: player, attacker: attacker, defender: defender, spell: usedSpell, weather: fightLogic.weather, resistable: false)
                } else {
                    return HexApplication.shared.applyHex(player: player, oppositePlayer: oppositePlayer, attacker: attacker, defender: defender, spell: usedSpell, weather: fightLogic.weather, resistable: true)
                }
            }
        } else if usedSpell.healAmount > 0 {
            if move.index > 0 && defender.getArtifact().name == Artifacts.shield.rawValue && fightLogic.weather?.name != Weather.volcanicStorm.rawValue { //protection from seconary effects
                return Localization.shared.getTranslation(key: "healFailed")
            }
            
            oppositePlayer.setState(state: PlayerState.healing, index: move.target)
            
            return applyHealing(defender: defender, spell: usedSpell)
        } else if usedSpell.weather != nil { //weather adding spell
            if player.id == 1 && fightLogic.hasCPUPlayer {
                for (index, currWeather) in Weather.allCases.enumerated() {
                    if currWeather.rawValue == usedSpell.weather {
                        GlobalData.shared.userProgress.weatherUses[index] = true
                        break
                    }
                }
            }
            
            let newWeather: String? = Weather(rawValue: usedSpell.weather ?? "")?.rawValue
            
            if newWeather != nil && fightLogic.weather?.name != newWeather {
                if attacker.getArtifact().name == Artifacts.crystal.rawValue {
                    fightLogic.weather = Weather(rawValue: usedSpell.weather!)?.getHex(duration: 7)
                } else {
                    fightLogic.weather = Weather(rawValue: usedSpell.weather!)?.getHex(duration: 5)
                }
                
                AudioPlayer.shared.playConfirmSound()
                return Localization.shared.getTranslation(key: "weatherChanged", params: [fightLogic.weather!.name])
            } else { //weather already active or invalid weather
                AudioPlayer.shared.playCancelSound()
                return Localization.shared.getTranslation(key: "weatherFailed")
            }
        } else {
            if move.index > 0 && defender.getArtifact().name == Artifacts.shield.rawValue && fightLogic.weather?.name != Weather.volcanicStorm.rawValue { //protection from seconary effects
                return Localization.shared.getTranslation(key: "spellFailed")
            }
            
            switch spell.typeID {
            case 6:
                if player.isAbleToSwap(singleMode: fightLogic.singleMode) {
                    player.hasToSwap = true
                    defender.hasSwapped = true
                    return Localization.shared.getTranslation(key: "nameRetreated", params: [defender.name])
                }
            case 13:
                //shield can't be used twice in a row -> failure
                if attacker.lastSpell == -2 {
                    return Localization.shared.getTranslation(key: "spellFailed")
                } else {
                    return Localization.shared.getTranslation(key: "nameProtected", params: [attacker.name])
                }
            case 15:
                if oppositePlayer.isAbleToSwap(singleMode: fightLogic.singleMode) {
                    oppositePlayer.hasToSwap = true
                    defender.hasSwapped = true
                    return Localization.shared.getTranslation(key: "forcedOut", params: [defender.name])
                }
            case 16:
                let hexes: [Hex] = attacker.hexes
                
                attacker.removeAllHexes()
                for hex in defender.hexes {
                    attacker.applyHex(hex: hex, resistable: false)
                }
                
                defender.removeAllHexes()
                for hex in hexes {
                    defender.applyHex(hex: hex, resistable: false)
                }
                
                return Localization.shared.getTranslation(key: "swappedHexes")
            case 17:
                if fightLogic.singleMode {
                    attacker.removeAllHexes()
                    defender.removeAllHexes()
                } else {
                    for fighter in fightLogic.players[0].fighters {
                        fighter.removeAllHexes()
                    }
                    for fighter in fightLogic.players[1].fighters {
                        fighter.removeAllHexes()
                    }
                }
                
                return Localization.shared.getTranslation(key: "clearedHexes")
            case 18:
                defender.overrideElement(newElement: attacker.getElement())
                return Localization.shared.getTranslation(key: "elementChanged", params: [defender.name, attacker.getElement().name])
            case 19:
                player.wishActivated = true
                defender.currhp = 0
                player.setState(state: PlayerState.hurting, index: move.target)
                
                if fightLogic.singleMode {
                    player.hasToSwap = true
                }
                defender.hasSwapped = true
                
                return Localization.shared.getTranslation(key: "nameFainted", params: [defender.name])
            case 20:
                let artifact: Artifact = attacker.getArtifact()
                attacker.overrideArtifact(artifact: defender.getArtifact())
                defender.overrideArtifact(artifact: artifact)
                
                return Localization.shared.getTranslation(key: "swappedArtifacts")
            case 21:
                return Localization.shared.getTranslation(key: "nameTargeted", params: [defender.name])
            default:
                break
            }
            
            return Localization.shared.getTranslation(key: "spellFailed")
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
            
            print(defender.name + " gained \(newHealth)HP")
            return Localization.shared.getTranslation(key: "gainedHP", params: [defender.name])
        }
        
        return Localization.shared.getTranslation(key: "healFailed")
    }
}
