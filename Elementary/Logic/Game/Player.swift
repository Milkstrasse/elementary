//
//  Player.swift
//  Elementary
//
//  Created by Janice Hablützel on 30.01.22.
//

import Foundation
import SwiftUI

/// Contains all the important data of a player during a fight: their current team, the current fighter and all the used spells.
class Player: ObservableObject {
    let id: Int
    
    @Published var fighters: [Fighter]
    @Published var currentFighterId: Int
    
    var hasToSwap: Bool
    var wishActivated: Bool
    
    @Published var state: PlayerState
    
    /// Creates a player with all the information to start a fight.
    /// - Parameters:
    ///   - id: The id determines if they are on the left or right
    ///   - fighters: The player's selected team of fighters
    init(id: Int, fighters: [Fighter]) {
        self.id = id
        self.fighters = fighters
        currentFighterId = 0
        
        hasToSwap = false
        wishActivated = false
        
        state = PlayerState.neutral
    }
    
    /// Returns the fighter currently fighting.
    /// - Returns: Returns the fighter currently fighting
    func getCurrentFighter() -> Fighter {
        return fighters[currentFighterId]
    }
    
    /// Changes the state of the player which will be reflected by the current fighter with different images.
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
    
    /// Checks if fighter can swap within their team.
    /// - Parameter player: The player
    /// - Returns: Returns whether the fighter can swap in their team
    func isAbleToSwap() -> Bool {
        if getCurrentFighter().hasHex(hexName: Hexes.chained.rawValue) {
            return false
        }
        
        var counter: Int = 0
        for fighter in fighters {
            if fighter.currhp > 0 {
                counter += 1
            }
        }
        
        if counter >= 2 { //enough fighters are alive to make a swap
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
