//
//  Player.swift
//  Witchery
//
//  Created by Janice Hablützel on 30.01.22.
//

import Foundation
import SwiftUI

/// Contains all the important data of a player during a fight: their current team, the current witch and all the used moves.
class Player: ObservableObject {
    let id: Int
    
    @Published var witches: [Witch]
    @Published var currentWitchId: Int
    
    var usedMoves: [Move]
    var hasToSwap: Bool
    var wishActivated: Bool
    
    @Published var state: PlayerState
    
    /// Creates a player with all the information to start a fight.
    /// - Parameters:
    ///   - id: The id determines if they are on the left or right
    ///   - witches: The player's selected team of witches
    init(id: Int, witches: [Witch]) {
        self.id = id
        self.witches = witches
        currentWitchId = 0
        
        usedMoves = []
        hasToSwap = false
        wishActivated = false
        
        state = PlayerState.neutral
    }
    
    /// Returns the witch currently fighting.
    /// - Returns: Returns the witch currently fighting
    func getCurrentWitch() -> Witch {
        return witches[currentWitchId]
    }
    
    /// Changes the state of the player which will be reflected by the current witch with different images.
    /// - Parameter state: The state the player will enter
    func setState(state: PlayerState) {
        self.state = state
        
        switch state {
            case .neutral:
                break
            case .attacking:
                AudioPlayer.shared.playAttackSound()
            case .hurting:
                if AudioPlayer.shared.hapticToggle {
                    let haptic = UIImpactFeedbackGenerator(style: .medium)
                    haptic.impactOccurred()
                }
            
                AudioPlayer.shared.playHurtSound()
            case .healing:
                AudioPlayer.shared.playHealSound()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + GlobalData.shared.getTextSpeed()/2) {
            self.state = .neutral
        }
    }
    
    /// Checks if witch can swap within their team.
    /// - Parameter player: The player
    /// - Returns: Returns whether the witch can swap in their team
    func isAbleToSwap() -> Bool {
        if getCurrentWitch().hasHex(hexName: Hexes.chained.rawValue) {
            return false
        }
        
        var counter: Int = 0
        for witch in witches {
            if witch.currhp > 0 {
                counter += 1
            }
        }
        
        if counter >= 2 { //enough witches are alive to make a swap
            return true
        } else {
            return false
        }
    }
}

/// The different states a player can enter.
enum PlayerState {
    case neutral
    case attacking
    case hurting
    case healing
}
