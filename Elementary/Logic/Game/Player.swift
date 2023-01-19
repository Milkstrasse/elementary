//
//  Player.swift
//  Elementary
//
//  Created by Janice Hablützel on 30.01.22.
//

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
    
    /// Goes to the next alive fighter in the team.
    func goToNextFighter() {
        currentFighterId += 1
        while fighters[currentFighterId].currhp == 0 {
            currentFighterId += 1
        }
    }
    
    /// Goes to the previous alive fighter in the team.
    func goToPreviousFighter() {
        currentFighterId -= 1
        while fighters[currentFighterId].currhp == 0 {
            currentFighterId -= 1
        }
    }
    
    /// Changes the state of the player which will be reflected by the current fighter with different images. The current fighter will be changed to the selected fighter.
    /// - Parameters:
    ///   - state: The state the player will enter
    ///   - index: The index of the fighter
    private func setState(state: PlayerState, index: Int) {
        currentFighterId = index
        self.state = state
        
        switch state {
        case .neutral:
            break
        case .attacking:
            AudioPlayer.shared.playAttackSound()
        case .hurting:
            if AudioPlayer.shared.hapticToggle {
                let haptic = UIImpactFeedbackGenerator(style: .heavy)
                haptic.impactOccurred()
            }
            
            AudioPlayer.shared.playHurtSound()
        case .healing:
            AudioPlayer.shared.playHealSound()
        case .hexPositive:
            AudioPlayer.shared.playConfirmSound()
        case .hexNegative:
            AudioPlayer.shared.playConfirmSound()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + GlobalData.shared.getTextSpeed()/2) {
            self.state = PlayerState.neutral
        }
    }
    
    /// Changes the state of the player which will be reflected by the current fighter with different images. The current fighter will be changed to the selected fighter.
    /// - Parameters:
    ///   - state: The state the player will enter
    ///   - index: The selected fighter
    func setState(state: PlayerState, fighter: Fighter) {
        var index: Int = 0
        for n in fighters.indices {
            if fighters[n] == fighter {
                index = n
                break
            }
        }
        
        setState(state: state, index: index)
    }
    
    /// Checks if the player can swap within fighters.
    /// - Parameter singleMode: Indicates wether swaps are even possible
    /// - Returns: Returns whether the player can swap fighters
    func isAbleToSwap(singleMode: Bool = true) -> Bool {
        if !singleMode || getCurrentFighter().hasHex(hexName: Hexes.chained.rawValue) {
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
    
    /// Swaps two fighters.
    /// - Parameters:
    ///   - target: The index of the targeted fighter
    ///   - fightLogic: The information needed for the fight
    /// - Returns: Returns the description of what occured during the swap
    func swapFighters(target: Int, fightLogic: FightLogic) -> String {
        hasToSwap = false //flag no longer necessary
        
        var text: String
        
        if getCurrentFighter().getArtifact().name == Artifacts.grimoire.rawValue && fightLogic.weather?.name != Weather.volcanicStorm.rawValue {
            for hex in getCurrentFighter().hexes {
                getCurrentFighter().removeHex(hex: hex)
            }
        }
        
        text = Localization.shared.getTranslation(key: "swapWith", params: [getCurrentFighter().name, fighters[target].name]) + "\n"
        currentFighterId = target
        
        //heal new fighter after making a wish
        if wishActivated && getCurrentFighter().currhp < getCurrentFighter().getModifiedBase().health {
            getCurrentFighter().currhp = getCurrentFighter().getModifiedBase().health
            
            text += Localization.shared.getTranslation(key: "gainedHP", params: [getCurrentFighter().name]) + "\n"
            
            wishActivated = false
        }
        
        var oppositePlayer: Player = fightLogic.players[0]
        if id == 0 {
            oppositePlayer = fightLogic.players[1]
        }
        
        //apply artifact effect
        if fightLogic.weather?.name != Weather.volcanicStorm.rawValue && getCurrentFighter().getArtifact().name == Artifacts.mask.rawValue {
            if fightLogic.weather?.name != Weather.springWeather.rawValue && oppositePlayer.getCurrentFighter().applyHex(hex: Hexes.attackDrop.getHex(), resistable: false) {
                text += Localization.shared.getTranslation(key: "statDecreased", params: [oppositePlayer.getCurrentFighter().name, "attack"]) + "\n"
            } else {
                text += Localization.shared.getTranslation(key: "hexFailed")
            }
        }
        
        return String(text.dropLast())
    }
}

/// The different states a player can enter.
enum PlayerState {
    case neutral
    case attacking
    case hurting
    case healing
    case hexPositive
    case hexNegative
}
