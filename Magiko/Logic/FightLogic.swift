//
//  FightLogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

struct FightLogic {
    var currentLeftFighter: Int = 0
    var currentRightFighter: Int = 0
    
    var leftFighters: [Fighter]
    var rightFighters: [Fighter]
    
    func getLeftFighter() -> Fighter {
        return leftFighters[currentLeftFighter]
    }
    
    func getRightFighter() -> Fighter {
        return rightFighters[currentRightFighter]
    }
    
    func isValid() -> Bool {
        return (leftFighters.count > 0 && leftFighters.count <= 4) && (rightFighters.count > 0 && rightFighters.count <= 4)
    }
}
