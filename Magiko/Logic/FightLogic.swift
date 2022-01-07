//
//  FightLogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

class FightLogic: ObservableObject {
    var currentLeftFighter: Int = 0
    var currentRightFighter: Int = 0
    
    @Published var leftFighters: [Fighter]
    @Published var rightFighters: [Fighter]
    
    init(leftFighters: [Fighter], rightFighters: [Fighter]) {
        self.leftFighters = leftFighters
        self.rightFighters = rightFighters
    }
    
    func getLeftFighter() -> Fighter {
        return leftFighters[currentLeftFighter]
    }
    
    func getRightFighter() -> Fighter {
        return rightFighters[currentRightFighter]
    }
    
    func isValid() -> Bool {
        return (leftFighters.count > 0 && leftFighters.count <= 4) && (rightFighters.count > 0 && rightFighters.count <= 4)
    }
    
    func attack(player: Int) {
        if player == 0 {
            if rightFighters[currentRightFighter].currhp >= 10 {
                rightFighters[currentRightFighter].currhp -= 10
            } else {
                rightFighters[currentRightFighter].currhp = 0
            }
        } else {
            if leftFighters[currentLeftFighter].currhp >= 10 {
                leftFighters[currentLeftFighter].currhp -= 10
            } else {
                leftFighters[currentLeftFighter].currhp = 0
            }
        }
        
        print("attacked")
    }
}
