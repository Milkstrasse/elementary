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
    ///   - player: The id of the player
    ///   - fightLogic: Access to witch info
    /// - Returns: Returns a description of what occured during the player's turn
    func startTurn(player: Int, fightLogic: FightLogic) -> String {
        self.fightLogic = fightLogic
        var battleLog: String
        
        let attacker: Witch = fightLogic.getWitch(player: player)
        
        //witch faints and certain abilities activate
        if attacker.currhp == 0 && !attacker.hasHex(hexName: Hexes.enlightened.rawValue) {
            if attacker.ability.name == Abilities.retaliation.rawValue {
                if player == 0 {
                    if fightLogic.getWitch(player: 1).applyHex(hex: Hexes.getNegativeHex()) {
                        battleLog = attacker.name + " fainted and cursed " + fightLogic.getWitch(player: 1).name + ".\n"
                    } else {
                        battleLog = Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name]) + "\n"
                    }
                } else {
                    if fightLogic.getWitch(player: 0).applyHex(hex: Hexes.haunted.getHex()) {
                        battleLog = attacker.name + " fainted and cursed " + fightLogic.getWitch(player: 0).name + ".\n"
                    } else {
                        battleLog = Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name]) + "\n"
                    }
                }
            } else {
                battleLog = Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name]) + "\n"
            }
            
            fightLogic.hasToSwap[player] = true
            
            return battleLog
        } else if attacker.currhp == 0 {
            attacker.revive()
            return attacker.name + " fainted but was reborn.\n"
        }
        
        //apply damage or healing of hexes
        if fightLogic.playerStack[0].index < 0 {
            let damage: Int = attacker.getModifiedBase().health/(100/attacker.hexes[abs(fightLogic.playerStack[0].index) - 1].damageAmount)
            //damage can be positive or negative!
            
            if damage >= attacker.currhp {
                if attacker.hasHex(hexName: Hexes.enlightened.rawValue){
                    attacker.reset()
                    return attacker.name + " perished but was reborn.\n"
                } else {
                    attacker.currhp = 0
                    battleLog = Localization.shared.getTranslation(key: "namePerished", params: [attacker.name]) + "\n"
                    fightLogic.hasToSwap[player] = true
                    
                    return battleLog
                }
            } else if damage > 0 {
                attacker.currhp -= damage
                return Localization.shared.getTranslation(key: "lostHP", params: [attacker.name]) + "\n"
            } else if damage < attacker.getModifiedBase().health - attacker.currhp {
                attacker.currhp = attacker.getModifiedBase().health
                return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name]) + "\n"
            } else {
                attacker.currhp -= damage
                return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name]) + "\n"
            }
        }
        
        if fightLogic.playerStack[0].index == 0 {
            return Localization.shared.getTranslation(key: "usedSpell", params: [attacker.name, fightLogic.usedMoves[player][0].spell.name]) + "\n"
        }
        
        //checks if shielding spell is used or another spell
        if fightLogic.usedMoves[player][0].spell.type == "shield" {
            let usedMoves: [Move] = fightLogic.usedMoves[player]
            var text: String
        
            //shield can't be used twice in a row -> failure
            if usedMoves.count > 1 && usedMoves[0].spell.name == usedMoves[1].spell.name {
                text = Localization.shared.getTranslation(key: "fail") + "\n"
            } else {
                text = attacker.name + "is now protected, lmao.\n"
            }
            
            return text
        } else {
            return attack(player: player, spell: fightLogic.usedMoves[player][0].spell)
        }
    }
    
    /// Witch uses their spell to attack, heal or to do another action.
    /// - Parameters:
    ///   - player: The id of the player
    ///   - spell: The spell used to make the attack
    /// - Returns: Returns a description of what occured during the player's attack
    private func attack(player: Int, spell: Spell) -> String {
        //determine actual target
        var oppositePlayer: Int = 0
        if player == 0 {
            oppositePlayer = 1
        }
        
        //checks if targeted user is successfully shielded or not
        if spell.spells[fightLogic!.playerStack[0].index - 1].range > 0 {
            if fightLogic!.usedMoves[oppositePlayer][0].spell.type == "shield" {
                if fightLogic!.usedMoves[oppositePlayer].count == 1 || fightLogic!.usedMoves[oppositePlayer][0].spell.name != fightLogic!.usedMoves[oppositePlayer][1].spell.name { //attack was successfully blocked
                    return Localization.shared.getTranslation(key: "fail") + "\n"
                }
            }
        }
        
        let usedSpell: SubSpell = spell.spells[fightLogic!.playerStack[0].index - 1]
        
        //determine what kind of attack this is
        if usedSpell.power > 0 { //damaging attack
            return DamageCalculator.shared.applyDamage(attacker: fightLogic!.getWitch(player: player), defender: fightLogic!.getWitch(player: oppositePlayer), spell: usedSpell, spellElement: spell.element, weather: fightLogic!.weather)
        } else if usedSpell.hex != nil { //hex adding spell
            return HexApplication.shared.applyHex(attacker: fightLogic!.getWitch(player: player), defender: fightLogic!.getWitch(player: oppositePlayer), spell: usedSpell)
        } else if usedSpell.healAmount > 0 {
            return applyHealing(attacker: fightLogic!.getWitch(player: player), defender: fightLogic!.getWitch(player: oppositePlayer), spell: usedSpell)
        } else if usedSpell.weather != nil { //weather adding spell
            var text: String
            
            if fightLogic!.weather == nil {
                if fightLogic!.getWitch(player: player).ability.name == Abilities.weatherFrog.rawValue {
                    fightLogic!.weather = Weather(rawValue: usedSpell.weather!)?.getHex(duration: 5)
                } else {
                    fightLogic!.weather = Weather(rawValue: usedSpell.weather!)?.getHex(duration: 3)
                }
                
                if fightLogic!.weather != nil {
                    text = Localization.shared.getTranslation(key: "weatherChanged", params: [fightLogic!.weather!.name]) + "\n"
                } else { //weather can only be applied when there's currently no weather active
                    text = Localization.shared.getTranslation(key: "weatherFailed") + "\n"
                }
            } else {
                text = Localization.shared.getTranslation(key: "weatherFailed") + "\n"
            }
            
            return text
        } else {
            return "It does nothing.\n"
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
