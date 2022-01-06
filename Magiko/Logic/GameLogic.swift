//
//  GameLogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

struct GameLogic {
    var readyPlayers: [Bool] = [false, false]
    
    mutating func setReady(player: Int, ready: Bool) {
        readyPlayers[player] = ready
    }
    
    func areBothReady() -> Bool {
        return readyPlayers[0] && readyPlayers[1]
    }
}
