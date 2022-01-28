//
//  TurnLogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 14.01.22.
//

import SwiftUI

/// This is the main logic for a player's turn.  It determines whether fighter uses their skill or an other action.
class TurnLogic {
    static let shared: TurnLogic = TurnLogic()
    
    var fightLogic: FightLogic?
    
    /// Starts the turn of the player. Determines whether fighter uses their skill or an other action.
    /// - Parameters:
    ///   - player: The id of the player
    ///   - fightLogic: Access to fighter info
    /// - Returns: Returns a description of what occured during the player's turn
    func startTurn(player: Int, fightLogic: FightLogic) -> String {
        self.fightLogic = fightLogic
        var battleLog: String
        
        let attacker: Fighter = fightLogic.getFighter(player: player)
        
        //fighter faints and certain abilities activate
        if attacker.currhp == 0 && !attacker.hasEffect(effectName: Effects.enlightened.rawValue) {
            if attacker.ability.name == Abilities.retaliation.rawValue {
                if player == 0 {
                    if fightLogic.getFighter(player: 1).applyEffect(effect: Effects.getNegativeEffect()) {
                        battleLog = attacker.name + " fainted and cursed " + fightLogic.getFighter(player: 1).name + ".\n"
                    } else {
                        battleLog = Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name]) + "\n"
                    }
                } else {
                    if fightLogic.getFighter(player: 0).applyEffect(effect: Effects.haunted.getEffect()) {
                        battleLog = attacker.name + " fainted and cursed " + fightLogic.getFighter(player: 0).name + ".\n"
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
        } else if fightLogic.usedMoves[player][0].skill.useCounter > fightLogic.usedMoves[player][0].skill.getUses(fighter: attacker) {
            return Localization.shared.getTranslation(key: "usedSkill", params: [attacker.name, fightLogic.usedMoves[player][0].skill.name]) + " " + Localization.shared.getTranslation(key: "fail") + "\n"
        }
        
        //apply damage or healing of effects
        if fightLogic.playerStack[0].index < 0 {
            let damage: Int = attacker.getModifiedBase().health/(100/attacker.effects[abs(fightLogic.playerStack[0].index) - 1].damageAmount)
            //damage can be positive or negative!
            
            if damage >= attacker.currhp {
                if attacker.hasEffect(effectName: Effects.enlightened.rawValue){
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
        
        //checks if shielding skill is used or another skill
        if fightLogic.usedMoves[player][0].skill.type == "shield" {
            let usedMoves: [Move] = fightLogic.usedMoves[player]
            var text: String = "\n"
        
            //shield can't be used twice in a row -> failure
            if usedMoves.count > 1 && usedMoves[0].skill.name == usedMoves[1].skill.name {
                text = "\n" + Localization.shared.getTranslation(key: "fail") + "\n"
            }
            
            return Localization.shared.getTranslation(key: "usedSkill", params: [attacker.name, usedMoves[0].skill.name]) + " " + text
        } else {
            return attack(player: player, skill: fightLogic.usedMoves[player][0].skill)
        }
    }
    
    /// Fighter uses their skill to attack, heal or to do another action.
    /// - Parameters:
    ///   - player: The id of the player
    ///   - skill: The skill used to make the attack
    /// - Returns: Returns a description of what occured during the player's attack
    private func attack(player: Int, skill: Skill) -> String {
        //determine actual target
        var oppositePlayer: Int = 0
        if player == 0 {
            oppositePlayer = 1
        }
        
        //checks if targeted user is successfully shielded or not
        if skill.skills[fightLogic!.playerStack[0].index].range > 0 {
            if fightLogic!.usedMoves[oppositePlayer][0].skill.type == "shield" {
                if fightLogic!.usedMoves[oppositePlayer].count == 1 || fightLogic!.usedMoves[oppositePlayer][0].skill.name != fightLogic!.usedMoves[oppositePlayer][1].skill.name { //attack was successfully blocked
                    return Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.getFighter(player: player).name, skill.name]) + "\n" + Localization.shared.getTranslation(key: "fail") + "\n"
                }
            }
        }
        
        let text: String
        let usedSkill: SubSkill = skill.skills[fightLogic!.playerStack[0].index]
        
        //determine what kind of attack this is
        if usedSkill.power > 0 { //damaging attack
            text = DamageCalculator.shared.applyDamage(attacker: fightLogic!.getFighter(player: player), defender: fightLogic!.getFighter(player: oppositePlayer), skill: usedSkill, skillElement: skill.element, weather: fightLogic!.weather)
            
            return Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.getFighter(player: player).name, skill.name]) + " " + text
        } else if usedSkill.effect != nil { //effect adding skill
            text = EffectApplication.shared.applyEffect(attacker: fightLogic!.getFighter(player: player), defender: fightLogic!.getFighter(player: oppositePlayer), skill: usedSkill)
            
            return Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.getFighter(player: player).name, skill.name]) + "\n" + text
        } else if usedSkill.healAmount > 0 {
            text = applyHealing(attacker: fightLogic!.getFighter(player: player), defender: fightLogic!.getFighter(player: oppositePlayer), skill: usedSkill)
            
            return Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.getFighter(player: player).name, skill.name]) + "\n" + text
        } else if usedSkill.weatherEffect != nil { //weather adding skill
            if fightLogic!.weather == nil {
                if fightLogic!.getFighter(player: player).ability.name == Abilities.weatherFrog.rawValue {
                    fightLogic!.weather = WeatherEffects(rawValue: usedSkill.weatherEffect!)?.getEffect(duration: 5)
                } else {
                    fightLogic!.weather = WeatherEffects(rawValue: usedSkill.weatherEffect!)?.getEffect(duration: 3)
                }
                
                if fightLogic!.weather != nil {
                    text = Localization.shared.getTranslation(key: "weatherChanged", params: [fightLogic!.weather!.name]) + "\n"
                } else { //weather can only be applied when there's currently no weather active
                    text = Localization.shared.getTranslation(key: "weatherFailed") + "\n"
                }
            } else {
                text = Localization.shared.getTranslation(key: "weatherFailed") + "\n"
            }
            
            return Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.getFighter(player: player).name, skill.name]) + " \n" + text
        } else {
            return Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.getFighter(player: player).name, skill.name]) + " It does nothing.\n"
        }
    }
    
    /// Restores hitpoints of targeted fighter.
    /// - Parameters:
    ///   - attacker: The fighter that attacks
    ///   - defender: The fighter to be targeted
    ///   - skill: The skill used to make the attack
    /// - Returns: Returns a description of what occured during healing
    func applyHealing(attacker: Fighter, defender: Fighter, skill: SubSkill) -> String {
        var newHealth: Int
        
        //determine actual target
        var target: Fighter = defender
        if skill.range == 0 {
            target = attacker
        }
        
        if !target.hasEffect(effectName: Effects.haunted.rawValue) {
            newHealth = target.getModifiedBase().health/(100/skill.healAmount)
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
