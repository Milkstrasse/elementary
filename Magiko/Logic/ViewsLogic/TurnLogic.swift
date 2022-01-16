//
//  TurnLogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 14.01.22.
//

import SwiftUI

class TurnLogic {
    static let shared: TurnLogic = TurnLogic()
    
    var fightLogic: FightLogic?
    
    func startTurn(player: Int, fightLogic: FightLogic) -> String {
        self.fightLogic = fightLogic
        var battleLog: String = ""
        
        let attacker: Fighter = fightLogic.getFighter(player: player)
        
        if attacker.currhp == 0 && !attacker.hasEffect(effectName: Effects.enlightened.rawValue) {
            if attacker.ability.name == Abilities.retaliator.rawValue {
                if player == 0 {
                    if fightLogic.getFighter(player: 1).applyEffect(effect: Effects.getNegativeEffect()) {
                        battleLog += attacker.name + " fainted and cursed " + fightLogic.getFighter(player: 1).name + ".\n"
                    } else {
                        battleLog += Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name]) + "\n"
                    }
                } else {
                    if fightLogic.getFighter(player: 0).applyEffect(effect: Effects.blocked.getEffect()) {
                        battleLog += attacker.name + " fainted and cursed " + fightLogic.getFighter(player: 0).name + ".\n"
                    } else {
                        battleLog += Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name]) + "\n"
                    }
                }
            } else {
                battleLog += Localization.shared.getTranslation(key: "nameFainted", params: [attacker.name]) + "\n"
            }
            
            fightLogic.hasToSwitch[player] = true
            
            return battleLog
        } else if attacker.currhp == 0 {
            attacker.revive()
            battleLog += attacker.name + " fainted but was reborn.\n"
            
            return battleLog
        } else if fightLogic.usedMoves[player][0].skill.useCounter > fightLogic.usedMoves[player][0].skill.getUses(fighter: attacker) {
            battleLog += Localization.shared.getTranslation(key: "usedSkill", params: [attacker.name, fightLogic.usedMoves[player][0].skill.name]) + " " + Localization.shared.getTranslation(key: "fail") + "\n"
            return battleLog
        }
        
        if fightLogic.playerStack[0].index < 0 {
            let damage: Int = attacker.getModifiedBase().health/(100/attacker.effects[abs(fightLogic.playerStack[0].index) - 1].damageAmount)
            
            if damage >= attacker.currhp {
                if attacker.hasEffect(effectName: Effects.enlightened.rawValue){
                    attacker.reset()
                    battleLog += attacker.name + " perished but was reborn.\n"
                } else {
                    attacker.currhp = 0
                    battleLog += Localization.shared.getTranslation(key: "namePerished", params: [attacker.name]) + "\n"
                    fightLogic.hasToSwitch[player] = true
                }
            } else if damage > 0 {
                attacker.currhp -= damage
                battleLog += Localization.shared.getTranslation(key: "lostHP", params: [attacker.name]) + "\n"
            } else if damage < attacker.getModifiedBase().health - attacker.currhp {
                attacker.currhp = attacker.getModifiedBase().health
                battleLog += Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name]) + "\n"
            } else {
                attacker.currhp -= damage
                battleLog += Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name]) + "\n"
            }
            
            return battleLog
        }
        
        if fightLogic.usedMoves[player][0].skill.type == "shield" {
            let usedMoves: [Move] = fightLogic.usedMoves[player]
            var text: String = "\n"
        
            if usedMoves.count > 1 && usedMoves[0].skill.name == usedMoves[1].skill.name {
                text = "\n" + Localization.shared.getTranslation(key: "fail") + "\n"
            }
            
            battleLog += Localization.shared.getTranslation(key: "usedSkill", params: [attacker.name, usedMoves[0].skill.name]) + " " + text
        } else {
            battleLog += attack(player: player, skill: fightLogic.usedMoves[player][0].skill)
        }
        
        return battleLog
    }
    
    private func attack(player: Int, skill: Skill) -> String {
        var battleLog: String = ""
        
        if skill.skills[fightLogic!.playerStack[0].index].range > 0 {
            if player == 0 {
                if fightLogic!.usedMoves[1][0].skill.type == "shield" {
                    if fightLogic!.usedMoves[1].count == 1 || fightLogic!.usedMoves[1][0].skill.name != fightLogic!.usedMoves[1][1].skill.name {
                        battleLog += Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.leftFighters[fightLogic!.currentLeftFighter].name, skill.name]) + "\n" + Localization.shared.getTranslation(key: "fail") + "\n"
                        
                        return battleLog
                    }
                }
            } else {
                if fightLogic!.usedMoves[0][0].skill.type == "shield" {
                    if fightLogic!.usedMoves[0].count == 1 || fightLogic!.usedMoves[0][0].skill.name != fightLogic!.usedMoves[0][1].skill.name {
                        battleLog += Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.rightFighters[fightLogic!.currentRightFighter].name, skill.name]) + "\n" + Localization.shared.getTranslation(key: "fail") + "\n"
                        
                        return battleLog
                    }
                }
            }
        }
        
        if skill.skills[fightLogic!.playerStack[0].index].power > 0 {
            let text: String
            
            if player == 0 {
                if skill.skills[fightLogic!.playerStack[0].index].range > 0 {
                    text = DamageCalculator.shared.applyDamage(attacker: fightLogic!.leftFighters[fightLogic!.currentLeftFighter], defender: fightLogic!.rightFighters[fightLogic!.currentRightFighter], skill: skill.skills[fightLogic!.playerStack[0].index], skillElement: skill.element, weather: fightLogic!.weather)
                } else {
                    text = DamageCalculator.shared.applyDamage(attacker: fightLogic!.rightFighters[fightLogic!.currentRightFighter], defender: fightLogic!.leftFighters[fightLogic!.currentLeftFighter], skill: skill.skills[fightLogic!.playerStack[0].index], skillElement: skill.element, weather: fightLogic!.weather)
                }
            } else {
                if skill.skills[fightLogic!.playerStack[0].index].range > 0 {
                    text = DamageCalculator.shared.applyDamage(attacker: fightLogic!.rightFighters[fightLogic!.currentRightFighter], defender: fightLogic!.leftFighters[fightLogic!.currentLeftFighter], skill: skill.skills[fightLogic!.playerStack[0].index], skillElement: skill.element, weather: fightLogic!.weather)
                } else {
                    text = DamageCalculator.shared.applyDamage(attacker: fightLogic!.leftFighters[fightLogic!.currentLeftFighter], defender: fightLogic!.rightFighters[fightLogic!.currentRightFighter], skill: skill.skills[fightLogic!.playerStack[0].index], skillElement: skill.element, weather: fightLogic!.weather)
                }
            }
            
            if fightLogic!.getFighter(player: player).ability.name == Abilities.coward.rawValue && fightLogic!.isAbleToSwitch(player: player) {
                fightLogic!.hasToSwitch[player] = true
            }
            
            battleLog += Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.getFighter(player: player).name, skill.name]) + " " + text
        } else if skill.skills[fightLogic!.playerStack[0].index].effect != nil {
            if player == 0 {
                battleLog += EffectApplication.shared.applyEffect(attacker: fightLogic!.leftFighters[fightLogic!.currentLeftFighter], defender: fightLogic!.rightFighters[fightLogic!.currentRightFighter], skill: skill.skills[fightLogic!.playerStack[0].index], skillName: skill.name)
            } else {
                battleLog += EffectApplication.shared.applyEffect(attacker: fightLogic!.rightFighters[fightLogic!.currentRightFighter], defender: fightLogic!.leftFighters[fightLogic!.currentLeftFighter], skill: skill.skills[fightLogic!.playerStack[0].index], skillName: skill.name)
            }
        } else if skill.skills[fightLogic!.playerStack[0].index].healAmount > 0 {
            var text: String
            
            if player == 0 {
                text = applyHealing(attacker: fightLogic!.leftFighters[fightLogic!.currentLeftFighter], defender: fightLogic!.rightFighters[fightLogic!.currentRightFighter], skill: skill.skills[fightLogic!.playerStack[0].index])
            } else {
                text = applyHealing(attacker: fightLogic!.rightFighters[fightLogic!.currentRightFighter], defender: fightLogic!.leftFighters[fightLogic!.currentLeftFighter], skill: skill.skills[fightLogic!.playerStack[0].index])
            }
            
            battleLog += Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.getFighter(player: player).name, skill.name]) + "\n" + text
        } else if skill.skills[fightLogic!.playerStack[0].index].weatherEffect != nil {
            var text: String = ""
            
            if fightLogic!.weather == nil {
                if fightLogic!.getFighter(player: player).ability.name == Abilities.weatherFrog.rawValue {
                    fightLogic!.weather = WeatherEffects(rawValue: skill.skills[fightLogic!.playerStack[0].index].weatherEffect!)?.getEffect(duration: 5)
                } else {
                    fightLogic!.weather = WeatherEffects(rawValue: skill.skills[fightLogic!.playerStack[0].index].weatherEffect!)?.getEffect(duration: 3)
                }
                
                if fightLogic!.weather != nil {
                    text = Localization.shared.getTranslation(key: "weatherChanged", params: [fightLogic!.weather!.name]) + "\n"
                } else {
                    text = Localization.shared.getTranslation(key: "weatherFailed") + "\n"
                }
            } else {
                text = Localization.shared.getTranslation(key: "weatherFailed") + "\n"
            }
            
            battleLog += Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.getFighter(player: player).name, skill.name]) + " \n" + text
        } else {
            battleLog += Localization.shared.getTranslation(key: "usedSkill", params: [fightLogic!.getFighter(player: player).name, skill.name]) + " It does nothing.\n"
        }
        
        return battleLog
    }
    
    func applyHealing(attacker: Fighter, defender: Fighter, skill: SubSkill) -> String {
        var newHealth: Int
        if skill.range == 0 && !attacker.hasEffect(effectName: Effects.blocked.rawValue) {
            newHealth = attacker.getModifiedBase().health/(100/skill.healAmount)
            if newHealth >= (attacker.getModifiedBase().health - attacker.currhp) {
                attacker.currhp = attacker.getModifiedBase().health
            } else {
                attacker.currhp += newHealth
            }
            
            return Localization.shared.getTranslation(key: "gainedHP", params: [attacker.name]) + "\n"
        } else if !defender.hasEffect(effectName: Effects.blocked.rawValue) {
            newHealth = defender.getModifiedBase().health/(100/skill.healAmount)
            if newHealth >= (defender.getModifiedBase().health - defender.currhp) {
                defender.currhp = defender.getModifiedBase().health
            } else {
                defender.currhp += newHealth
            }
            
            return Localization.shared.getTranslation(key: "gainedHP", params: [defender.name]) + "\n"
        }
        
        return Localization.shared.getTranslation(key: "healFailed") + "\n"
    }
}
