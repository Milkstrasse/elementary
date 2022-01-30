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
    
    @Published var state: PlayerState
    
    init(id: Int, witches: [Witch]) {
        self.id = id
        self.witches = witches
        currentWitchId = 0
        
        usedMoves = []
        hasToSwap = false
        
        state = PlayerState.neutral
    }
    
    func getCurrentWitch() -> Witch {
        return witches[currentWitchId]
    }
    
    func setState(state: PlayerState) {
        self.state = state
        
        switch state {
            case .neutral:
                break
            case .attacking:
                AudioPlayer.shared.playAttackSound()
            case .hurting:
                AudioPlayer.shared.playHurtSound()
            case .healing:
                AudioPlayer.shared.playHealSound()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.state = .neutral
        }
    }
}

enum PlayerState {
    case neutral
    case attacking
    case hurting
    case healing
}
