//
//  Player.swift
//  Witchery
//
//  Created by Janice Hablützel on 30.01.22.
//

import Foundation

class Player: ObservableObject {
    let id: Int
    
    @Published var witches: [Witch]
    @Published var currentWitchId: Int
    
    var usedMoves: [Move]
    
    var hasToSwap: Bool
    
    init(id: Int, witches: [Witch]) {
        self.id = id
        self.witches = witches
        currentWitchId = 0
        
        usedMoves = []
         hasToSwap = false
    }
    
    func getCurrentWitch() -> Witch {
        return witches[currentWitchId]
    }
}
