//
//  CPULogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 15.01.22.
//

/// This is the logic that determines the best possible move or target for a swap.
struct CPULogic {
    static let shared: CPULogic = CPULogic()
    
    /// Determines the best move for the CPU.
    /// - Parameters:
    ///   - fighter: The current fighter
    ///   - enemy: The current fighter of the player
    ///   - weather: The current weather of the fight
    ///   - isAbleToSwitch: Wether the fighter can swap or not
    /// - Returns: Returns the best move
    func getMove(fighter: Fighter, enemy: Fighter, weather: Effect?, isAbleToSwitch: Bool) -> Move? {
        //avoid fighting against enemy with advantage
        if fighter.element.hasDisadvantage(element: enemy.element) && isAbleToSwitch {
            if !fighter.hasEffect(effectName: Effects.chained.rawValue) {
                return nil
            }
        }
        
        //collect all useable skills
        var availableSkills: [Int] = []
        
        for index in fighter.skills.indices {
            if fighter.skills[index].useCounter + fighter.staminaUse <= fighter.skills[index].getUses(fighter: fighter) {
                availableSkills.append(index)
            }
        }
        
        //have control over weather since the weather boosts certain attacks
        if weather == nil || weather?.duration == 1 {
            for index in availableSkills.indices {
                for skill in fighter.skills[availableSkills[index]].skills {
                    if skill.weatherEffect != nil {
                        return Move(source: fighter, target: -1, skill: fighter.skills[availableSkills[index]])
                    }
                }
            }
        }
        
        //top priority: find move that defeats the enemy fighter!
        for index in availableSkills.indices {
            if fighter.skills[availableSkills[index]].type == "attack" {
                if DamageCalculator.shared.willDefeatFighter(attacker: fighter, defender: enemy, skill: fighter.skills[availableSkills[index]].skills[0], skillElement: fighter.skills[availableSkills[index]].element, weather: weather) {
                    return Move(source: fighter, target: -1, skill: fighter.skills[availableSkills[index]])
                }
            }
        }
        
        //low health -> should heal
        if fighter.currhp <= fighter.getModifiedBase().health/2 && !fighter.hasEffect(effectName: Effects.blocked.rawValue) {
            for index in availableSkills.indices {
                if fighter.skills[availableSkills[index]].type == "heal" {
                    return Move(source: fighter, target: -1, skill: fighter.skills[availableSkills[index]])
                }
            }
        }
        
        //main goal is to do damage
        for index in availableSkills.indices {
            let skillElement: Element = fighter.skills[availableSkills[index]].element
            
            if fighter.skills[availableSkills[index]].type == "attack" {
                if skillElement.hasAdvantage(element: enemy.element) {
                    return Move(source: fighter, target: -1, skill: fighter.skills[availableSkills[index]])
                }
            }
        }
        
        for index in availableSkills.indices {
            let skillElement: Element = fighter.skills[availableSkills[index]].element
            
            if fighter.skills[availableSkills[index]].type == "attack" {
                if !skillElement.hasDisadvantage(element: enemy.element) {
                    return Move(source: fighter, target: -1, skill: fighter.skills[availableSkills[index]])
                }
            }
        }
        
        //no good move has been found
        return Move(source: fighter, target: -1, skill: fighter.skills[0])
    }
    
    /// Determines the best fighter to swap to for the CPU.
    /// - Parameters:
    ///   - currentFighter: The current fighter
    ///   - fighters: The current team
    ///   - enemyElement: The element of the enemy fighter
    /// - Returns: Returns the index of the best fighter to swap to
    func getTarget(currentFighter: Int, fighters: [Fighter], enemyElement: Element) -> Int {
        for index in fighters.indices {
            if fighters[index].element.hasAdvantage(element: enemyElement) && index != currentFighter {
                if fighters[index].currhp > 0 {
                    return index
                }
            }
        }
        
        for index in fighters.indices {
            if !fighters[index].element.hasDisadvantage(element: enemyElement) && index != currentFighter {
                if fighters[index].currhp > 0 {
                    return index
                }
            }
        }
        
        //no good fighter was found, find any fighter who hasn't fainted
        for index in fighters.indices {
            if index != currentFighter && fighters[index].currhp > 0 {
                return index
            }
        }
        
        return currentFighter + 1 //should be impossible to reach if everything works correctly
    }
}
