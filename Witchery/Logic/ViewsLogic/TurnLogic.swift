//
//  TurnLogic.swift
//  Witchery
//
//  Created by Janice Hablützel on 14.01.22.
//

import SwiftUI

/// This is the main logic for a player's turn.  It determines whether witch uses their spell or an other action.
class TurnLogic {
    static let shared: TurnLogic = TurnLogic()
    
    var fightLogic: FightLogic?
    
    /// Starts the turn of the player. Determines whether witch uses their spell or an other action.
    /// - Parameters:
    ///   - player: The player
    ///   - fightLogic: Access to witch info
    /// - Returns: Returns a description of what occured during the player's turn
    func startTurn(player: Player, fightLogic: FightLogic) -> String {
        self.fightLogic = fightLogic
        var battleLog: String
        
        let attacker: Witch = player.getCurrentWitch()
        
        //witch faints and certain artifacts activate
        if attacker.currhp == 0 {
            if attacker.getArtifact().name == Artifacts.book.rawValue {
                if player.id == 0 {
                    if fightLogic.players[1].getCurrentWitch().applyHex(hex: Hexes.getNegativeHex()) {
                        battleLog = attacker.name + " fainted and cursed " + fightLogic.players[1].getCurrentWitch().name + ".\n"
                    } else {
                        battleLog = Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name]) + "\n"
                    }
                } else {
                    if fightLogic.players[0].getCurrentWitch().applyHex(hex: Hexes.haunted.getHex()) {
                        battleLog = attacker.name + " fainted and cursed " + fightLogic.players[0].getCurrentWitch().name + ".\n"
                    } else {
                        battleLog = Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name]) + "\n"
                    }
                }
            } else {
                battleLog = Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name]) + "\n"
            }
            
            player.hasToSwap = true
            
            return battleLog
        }
        
        //apply damage or healing of hexes
        if fightLogic.playerStack[0].index < 0 && fightLogic.playerStack[0].index > -10 {
            let damage: Int = attacker.getModifiedBase().health/(100/attacker.hexes[abs(fightLogic.playerStack[0].index) - 1].damageAmount)
            //damage can be positive or negative!
            
            if damage >= attacker.currhp {
                attacker.currhp = 0
                player.setState(state: PlayerState.hurting)
                player.hasToSwap = true
                
                return Localization.shared.getTranslation(key: "namePerished", params: [attacker.name]) + "\n"
            } else if damage > 0 {
                attacker.currhp -= damage
                player.setState(state: PlayerState.hurting)
                
                return Localization.shared.getTranslation(key: "lostHP", params: [attacker.name]) + "\n"
            } else if damage < attacker.getModifiedBase().health - attacker.currhp {
                attacker.currhp = attacker.getModifiedBase().health
                player.setState(state: PlayerState.healing)
                
                return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name]) + "\n"
            } else {
                attacker.currhp -= damage
                player.setState(state: PlayerState.healing)
                
                return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name]) + "\n"
            }
        } else if fightLogic.playerStack[0].index < 0 {
            if attacker.getModifiedBase().health - attacker.currhp <= attacker.getModifiedBase().health/16 {
                attacker.currhp = attacker.getModifiedBase().health
            } else {
                attacker.currhp += attacker.getModifiedBase().health/16
            }
            
            player.setState(state: PlayerState.healing)
            
            return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name]) + "\n"
        }
        
        let spell: Spell = player.usedMoves[0].spell
        
        if fightLogic.playerStack[0].index == 0 {
            player.setState(state: PlayerState.attacking)
            return Localization.shared.getTranslation(key: "usedSpell", params: [attacker.name, spell.name]) + "\n"
        }
        
        //if witch has restriction hex and was forced to use spells with no uses
        if spell.useCounter >= spell.uses {
            return Localization.shared.getTranslation(key: "fail") + "\n"
        }
        
        //checks if shielding spell is used or another spell
        if spell.typeID == 10 {
            let usedMoves: [Move] = player.usedMoves
            var text: String
        
            //shield can't be used twice in a row -> failure
            if usedMoves.count > 1 && usedMoves[0].spell.name == usedMoves[1].spell.name {
                text = Localization.shared.getTranslation(key: "fail") + "\n"
            } else {
                text = Localization.shared.getTranslation(key: "nameProtected", params: [attacker.name]) + "\n"
            }
            
            return text
        } else {
            return attack(player: player, spell: spell)
        }
    }
    
    /// Witch uses their spell to attack, heal or to do another action.
    /// - Parameters:
    ///   - player: The player
    ///   - spell: The spell used to make the attack
    /// - Returns: Returns a description of what occured during the player's attack
    private func attack(player: Player, spell: Spell) -> String {
        //determine actual target
        var oppositePlayer: Player = fightLogic!.players[0]
        if player.id == 0 {
            oppositePlayer = fightLogic!.players[1]
        }
        
        //checks if targeted user is successfully shielded or not
        var usedShield: Bool = false
        if spell.spells[fightLogic!.playerStack[0].index - 1].range > 0 {
            if oppositePlayer.usedMoves[0].spell.typeID == 10 {
                if oppositePlayer.usedMoves.count == 1 || oppositePlayer.usedMoves[0].spell.name != oppositePlayer.usedMoves[1].spell.name { //shield was successful
                    if player.usedMoves[0].spell.typeID != 2 {
                        return Localization.shared.getTranslation(key: "fail") + "\n"
                    } else {
                        usedShield = true
                    }
                }
            }
        }
        
        let usedSpell: SubSpell = spell.spells[fightLogic!.playerStack[0].index - 1]
        
        //determine what kind of attack this is
        if usedSpell.power > 0 { //damaging attack
            if usedSpell.range == 1 {
                oppositePlayer.setState(state: PlayerState.hurting)
                
                if oppositePlayer.getCurrentWitch().getArtifact().name == Artifacts.talaria.rawValue && fightLogic!.isAbleToSwap(player: oppositePlayer) {
                    oppositePlayer.hasToSwap = true
                }
            } else {
                player.setState(state: PlayerState.hurting)
            }
            
            return DamageCalculator.shared.applyDamage(attacker: player.getCurrentWitch(), defender: oppositePlayer.getCurrentWitch(), spell: spell, subSpell: usedSpell, spellElement: spell.element, weather: fightLogic!.weather, usedShield: usedShield, usedEndure: oppositePlayer.usedMoves[0].spell.typeID == 16)
        } else if usedSpell.hex != nil { //hex adding spell
            return HexApplication.shared.applyHex(attacker: player.getCurrentWitch(), defender: oppositePlayer.getCurrentWitch(), spell: usedSpell)
        } else if usedSpell.healAmount > 0 {
            if usedSpell.range == 0 {
                player.setState(state: PlayerState.healing)
            } else {
                oppositePlayer.setState(state: PlayerState.healing)
            }
            
            return applyHealing(attacker: player.getCurrentWitch(), defender: oppositePlayer.getCurrentWitch(), spell: usedSpell)
        } else if usedSpell.weather != nil { //weather adding spell
            let newWeather: String? = Weather(rawValue: usedSpell.weather ?? "")?.rawValue
            
            if newWeather != nil && fightLogic?.weather?.name != newWeather {
                if player.getCurrentWitch().getArtifact().name == Artifacts.crystal.rawValue {
                    fightLogic!.weather = Weather(rawValue: usedSpell.weather!)?.getHex(duration: 5)
                } else {
                    fightLogic!.weather = Weather(rawValue: usedSpell.weather!)?.getHex(duration: 3)
                }
                
                return Localization.shared.getTranslation(key: "weatherChanged", params: [fightLogic!.weather!.name]) + "\n"
            } else { //weather already active or invalid weather
                return Localization.shared.getTranslation(key: "weatherFailed") + "\n"
            }
        } else {
            switch player.usedMoves[0].spell.typeID {
                case 6:
                    if fightLogic!.isAbleToSwap(player: player) {
                        player.hasToSwap = true
                        return player.getCurrentWitch().name +  " flEes tHe sceNe.\n"
                    }
                case 7:
                    player.getCurrentWitch().overrideElement(newElement: Element())
                    return player.getCurrentWitch().name +  "'s elEment Was reMoved.\n"
                case 12:
                    if fightLogic!.isAbleToSwap(player: oppositePlayer) {
                        oppositePlayer.hasToSwap = true
                        return oppositePlayer.getCurrentWitch().name +  " is fOrced oUt.\n"
                    }
                case 13:
                    let hexes: [Hex] = player.getCurrentWitch().hexes
                    player.getCurrentWitch().removeAllHexes()
                    for hex in oppositePlayer.getCurrentWitch().hexes {
                        player.getCurrentWitch().applyHex(hex: hex)
                    }
                
                    oppositePlayer.getCurrentWitch().removeAllHexes()
                    for hex in hexes {
                        oppositePlayer.getCurrentWitch().applyHex(hex: hex)
                    }
                
                    return "sWappEd heXes.\n"
                case 14:
                    oppositePlayer.getCurrentWitch().overrideArtifact(artifact: Artifacts.noArtifact.getArtifact())
                    return oppositePlayer.getCurrentWitch().name +  "'s artiFact Was stoLen.\n"
                case 15:
                    oppositePlayer.getCurrentWitch().overrideElement(newElement: player.getCurrentWitch().getElement())
                    return oppositePlayer.getCurrentWitch().name +  "'s elEment Was cHanged.\n"
                case 16:
                    return player.getCurrentWitch().name +  " wilL enDure.\n"
                case 17:
                    player.getCurrentWitch().removeAllHexes()
                    oppositePlayer.getCurrentWitch().removeAllHexes()
                    fightLogic?.weather = nil
                
                    return player.getCurrentWitch().name +  " clEared eVeryThing.\n"
                case 18:
                    player.wishActivated = true
                    player.getCurrentWitch().currhp = 0
                    player.hasToSwap = true
                    return player.getCurrentWitch().name +  "'s faInted.\n"
                case 19:
                    let hexes: [Hex] = oppositePlayer.getCurrentWitch().hexes
                    oppositePlayer.getCurrentWitch().removeAllHexes()
                    for hex in hexes {
                        if hex.opposite != nil {
                            oppositePlayer.getCurrentWitch().applyHex(hex: hex.opposite!.getHex())
                        }
                    }
                
                    return oppositePlayer.getCurrentWitch().name +  "'s hExes inVertEd.\n"
                default:
                    break
            }
            
            return Localization.shared.getTranslation(key: "fail") + "\n"
        }
    }
    
    /// Restores hitpoints of targeted witch.
    /// - Parameters:
    ///   - attacker: The witch that attacks
    ///   - defender: The witch to be targeted
    ///   - spell: The spell used to make the attack
    /// - Returns: Returns a description of what occured during healing
    func applyHealing(attacker: Witch, defender: Witch, spell: SubSpell) -> String {
        var newHealth: Int
        
        //determine actual target
        var target: Witch = defender
        if spell.range == 0 {
            target = attacker
        }
        
        if !target.hasHex(hexName: Hexes.haunted.rawValue) {
            newHealth = target.getModifiedBase().health/(100/spell.healAmount)
            if newHealth >= (target.getModifiedBase().health - target.currhp) {
                target.currhp = target.getModifiedBase().health
            } else {
                target.currhp += newHealth
            }
            
            return Localization.shared.getTranslation(key: "gainedHP", params: [target.name]) + "\n"
        }
        
        return Localization.shared.getTranslation(key: "healFailed") + "\n"
    }
}
