//
//  GameLogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

struct GameLogic {
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
}
