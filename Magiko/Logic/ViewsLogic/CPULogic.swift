//
//  CPULogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 15.01.22.
//

struct CPULogic {
    static let shared: CPULogic = CPULogic()
    
    func getMove(fighter: Fighter, enemyElement: Element) -> Move {
        for index in fighter.skills.indices {
            let skillElement: Element = GlobalData.shared.elements[fighter.skills[index].element] ?? Element()
            
            if skillElement.hasAdvantage(element: enemyElement) {
                return Move(source: fighter, target: -1, skill: fighter.skills[index])
            }
        }
        
        for index in fighter.skills.indices {
            let skillElement: Element = GlobalData.shared.elements[fighter.skills[index].element] ?? Element()
            
            if !skillElement.hasDisadvantage(element: enemyElement) {
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
