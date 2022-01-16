//
//  CPULogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 15.01.22.
//

struct CPULogic {
    static let shared: CPULogic = CPULogic()
    
    func getMove(fighter: Fighter, enemyElement: Element, weather: Effect?, isAbleToSwitch: Bool) -> Move? {
        if fighter.element.hasDisadvantage(element: enemyElement) && isAbleToSwitch {
            return nil
        }

        if weather == nil || weather?.duration == 1 {
            for index in fighter.skills.indices {
                if fighter.skills[index].useCounter + fighter.staminaUse <= fighter.skills[index].getUses(fighter: fighter) {
                    for skill in fighter.skills[index].skills {
                        if skill.weatherEffect != nil {
                            return Move(source: fighter, target: -1, skill: fighter.skills[index])
                        }
                    }
                }
            }
        }
        
        for index in fighter.skills.indices {
            let skillElement: Element = GlobalData.shared.elements[fighter.skills[index].element] ?? Element()
            
            if skillElement.hasAdvantage(element: enemyElement) && fighter.skills[index].useCounter + fighter.staminaUse <= fighter.skills[index].getUses(fighter: fighter) {
                return Move(source: fighter, target: -1, skill: fighter.skills[index])
            }
        }
        
        for index in fighter.skills.indices {
            let skillElement: Element = GlobalData.shared.elements[fighter.skills[index].element] ?? Element()
            
            if !skillElement.hasDisadvantage(element: enemyElement) && fighter.skills[index].useCounter + fighter.staminaUse <= fighter.skills[index].getUses(fighter: fighter) {
                return Move(source: fighter, target: -1, skill: fighter.skills[index])
            }
        }
        
        return Move(source: fighter, target: -1, skill: fighter.skills[0])
    }
    
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
        
        for index in fighters.indices {
            if index != currentFighter && fighters[index].currhp > 0 {
                return index
            }
        }
        
        return currentFighter + 1
    }
}
