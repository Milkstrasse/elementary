//
//  FightLogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

/// This is the main logic of the game. Stores all participating fighters, determines the turn order and the amount of turns needed in each round, swaps fighters , determines when the game is over and who has won.
class FightLogic: ObservableObject {
    let hasCPUPlayer: Bool
    
    @Published var currentFighter: [Int] = [0, 0]
    var hasToSwap: [Bool] = [false, false]
    
    @Published var fighters: [[Fighter]] = [[], []]
    
    var gameLogic: GameLogic = GameLogic()
    
    var usedMoves: [[Move]] = [[], []]
    var playerStack: [(player: Int, index: Int)] = []
    
    @Published var battling: Bool = false
    @Published var battleLog: String = "let the fight begin"
    @Published var gameOver: Bool = false
    
    @Published var weather: Effect?
    
    init(leftFighters: [Fighter], rightFighters: [Fighter], hasCPUPlayer: Bool = false) {
        self.hasCPUPlayer = hasCPUPlayer
        
        fighters[0] = leftFighters
        fighters[1] = rightFighters
        
        if getFighter(player: 0).ability.name == Abilities.intimidate.rawValue {
            getFighter(player: 1).applyEffect(effect: Effects.attackDrop.getEffect())
        }
        if getFighter(player: 1).ability.name == Abilities.intimidate.rawValue {
            getFighter(player: 0).applyEffect(effect: Effects.attackDrop.getEffect())
        }
    }
    
    /// Checks if there are enough fighters on both sides.
    /// - Returns: Returns whether this fight has enough fighters on both sides
    func isValid() -> Bool {
        return (!fighters[0].isEmpty && fighters[0].count <= 4) && (!fighters[1].isEmpty && fighters[1].count <= 4)
    }
    
    /// Returns current fighter of player.
    /// - Parameter player: The index of the  player
    /// - Returns: The current fighter of the player
    func getFighter(player: Int) -> Fighter {
        return fighters[player][currentFighter[player]]
    }
    
    /// Player declares which move they want to make in the following round of the fight.
    /// - Parameters:
    ///   - player: The index of the player who makes the move
    ///   - move: The action the player wants to make
    /// - Returns: Returns whether a round of fighting will begin or the player has to or is able to do another action
    func makeMove(player: Int, move: Move) -> Bool {
        //CPU makes its move
        if hasCPUPlayer {
            if hasToSwap[0] {
                swapFighters(player: 0, target: CPULogic.shared.getTarget(currentFighter: currentFighter[0], fighters: fighters[0], enemyElement: getFighter(player: 1).element))
            }
            
            var rndmMove: Move? = CPULogic.shared.getMove(fighter: getFighter(player: 0), enemy: getFighter(player: 1), weather: weather, isAbleToSwitch: isAbleToSwap(player: 0))
            
            if rndmMove == nil { //CPU wants to switch
                rndmMove = Move(source: getFighter(player: 0), target: CPULogic.shared.getTarget(currentFighter: currentFighter[0], fighters: fighters[0], enemyElement: getFighter(player: 1).element), skill: Skill())
            }
            
            usedMoves[0].insert(rndmMove!, at: 0)
        }
        
        if move.skill.useCounter + getFighter(player: player).staminaUse > move.skill.getUses(fighter: getFighter(player: player)) {
            return false //skill cost is to high, fighter cannot use this skill
        } else if move.target > -1 {
            if fighters[player][move.target].currhp == 0 {
                return false //fighter cannot switch with fainted fighters
            }
        }
        
        if hasToSwap[player] { //fighter either fainted or has special ability to swap
            if !getFighter(player: player).hasEffect(effectName: Effects.chained.rawValue) || getFighter(player: player).currhp == 0 {
                if move.target > -1 {
                    swapFighters(player: player, target: move.target)
                }
                
                return false //action is free, new fighter can make a move
            }
        }
        
        //marks player as ready
        gameLogic.setReady(player: player, ready: true)
        
        //adds move into the used moves collection
        if move.target < 0 { //move can be influenced by move changing effects
            if getFighter(player: player).hasEffect(effectName: Effects.confused.rawValue) {
                let randomMove: Move = Move(source: move.source, skill: getFighter(player: player).skills[Int.random(in: 0 ..< getFighter(player: player).skills.count)])
                usedMoves[player].insert(randomMove, at: 0)
            } else if !usedMoves[player].isEmpty && getFighter(player: player).hasEffect(effectName: Effects.restricted.rawValue) {
                if usedMoves[player][0].target < 0 {
                    usedMoves[player].insert(usedMoves[player][0], at: 0)
                } else { //last move was a swap which can't be locked in
                    usedMoves[player].insert(move, at: 0)
                }
            } else { //no moves have been made yet to be locked in
                usedMoves[player].insert(move, at: 0)
            }
        } else { //swapping move, can't be influenced by move changing effects
            usedMoves[player].insert(move, at: 0)
        }
        
        //fight begins
        if gameLogic.areBothReady() || hasCPUPlayer {
            battling = true
            battleLog = Localization.shared.getTranslation(key: "loading")
            
            //increase useCounter of skills
            usedMoves[0][0].useSkill(amount: getFighter(player: 0).staminaUse)
            usedMoves[1][0].useSkill(amount: getFighter(player: 1).staminaUse)
            
            //reset hasToSwap marker to prevent free swaps
            hasToSwap[0] = false
            hasToSwap[1] = false
            
            //decrease counter of all effects and remove if duration reached 0
            if weather != nil {
                weather!.duration -= 1
                
                if weather!.duration == 0 {
                    weather = nil
                }
            }
            
            for effect in getFighter(player: 0).effects {
                effect.duration -= 1
                
                if effect.duration == 0 {
                    getFighter(player: 0).removeEffect(effect: effect)
                }
            }
            for effect in getFighter(player: 1).effects {
                effect.duration -= 1
                
                if effect.duration == 0 {
                    getFighter(player: 1).removeEffect(effect: effect)
                }
            }
            
            //adds faster player to playerStack
            addMoveTurn(player: getFasterPlayer())
            
            var endRound: Bool = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                var turns: Int = 0
                //amount of turns first player needs to do their action
                let firstTurns: Int = playerStack.count
                
                //processes all actions on playerStack
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    let currentPlayer: Int = playerStack[0].player;
                    turns += 1
                    
                    if turns == 1 {
                        battleLog = ""
                    }
                    
                    startTurn(player: currentPlayer)
                    playerStack.removeFirst()
                    
                    if playerStack.isEmpty && !endRound { //adds new action if neccessary during the fight
                        endRound = addTurns(currentPlayer: currentPlayer, turns: turns, firstTurns: firstTurns)
                    }
                    
                    if playerStack.isEmpty {
                        timer.invalidate()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            gameLogic.setReady(player: 0, ready: false)
                            gameLogic.setReady(player: 1, ready: false)
                            //players are now able to choose their moves again
                            
                            print(battleLog)
                            
                            battling = false
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    /// Retracts the move a player has made before a round of fighting starts.
    /// - Parameter player: The index of the player
    func undoMove(player: Int) {
        gameLogic.setReady(player: player, ready: false)
        usedMoves[player].removeFirst()
    }
    
    /// Determines which player has priority.
    /// - Returns: Returns the index of the player with priority
    func getFasterPlayer() -> Int {
        //move has a target -> player wants to switch whis is a priority move
        if usedMoves[0][0].target > -1 {
            return 0
        } else if usedMoves[1][0].target > -1 {
            return 1
        }
        
        //shielding moves have priority
        if usedMoves[0][0].skill.type == "shield" {
            return 0
        } else if usedMoves[1][0].skill.type == "shield" {
            return 1
        }
        
        var fasterPlayer: Int
        
        //determine priority with using the agility stat of the fighters
        if getFighter(player: 0).base.agility > getFighter(player: 1).base.agility {
            fasterPlayer = 0
        } else if getFighter(player: 1).base.agility > getFighter(player: 0).base.agility {
            fasterPlayer = 1
        } else if Bool.random() { //agility stat tie -> random player has priority
            fasterPlayer = 0
        } else {
            fasterPlayer = 1
        }
        
        return fasterPlayer
    }
    
    /// Adds turns to the current round of fighting.
    /// - Parameters:
    ///   - currentPlayer: The index of player whose turn it is
    ///   - turns: The amount of turns in the current round
    ///   - firstTurns: The amount of turn the first player needed
    /// - Returns: Returns wether all necessary turns were determined or a future analysis is needed
    func addTurns(currentPlayer: Int, turns: Int, firstTurns: Int) -> Bool {
        if getFighter(player: 1).currhp == 0 {
            playerStack.insert((player: 1, index: 0), at: 0) //add turn to display faint message
            
            if getFighter(player: 0).currhp == 0 {
                playerStack.insert((player: 0, index: 0), at: 0) //add turn to display faint message
                return true //both fighters have fainted, round is over
            }
            
            if currentPlayer == 0 { //fighter fainted before they made their move
                addEffectTurns(player: 0)
            } else {
                if turns != firstTurns { //both players made their move
                    addEffectTurns(player: 0)
                } else {
                    addMoveTurn(player: 0)
                }
            }
            
            return true //no further turns needed
        } else if getFighter(player: 0).currhp == 0 {
            playerStack.insert((player: 0, index: 0), at: 0) //add turn to display faint message
            
            if getFighter(player: 1).currhp == 0 {
                playerStack.insert((player: 1, index: 0), at: 0) //add turn to display faint message
                return true //both fighters have fainted, round is over
            }
            
            if currentPlayer == 1 { //fighter fainted before they made their move
                addEffectTurns(player: 1)
            } else {
                if turns != firstTurns { //both players made their move
                    addEffectTurns(player: 1)
                } else {
                    addMoveTurn(player: 1)
                }
            }
            
            return true //no further turns needed
        }
        
        if turns == firstTurns { //other player has not made their move yet
            var oppositePlayer: Int = 0
            if currentPlayer == 0 {
                oppositePlayer = 1
            }
            
            addMoveTurn(player: oppositePlayer)
            return false
        } else { //both players made their move
            addEffectTurns(player: 0)
            addEffectTurns(player: 1)
        }
        
        return true //no further turns needed
    }
    
    /// Adds turns depending on the move of the player to the current round of fighting.
    /// - Parameter player: The index of the player
    func addMoveTurn(player: Int) {
        if !usedMoves[player][0].skill.skills.isEmpty {
            for index in usedMoves[player][0].skill.skills.indices.reversed() {
                playerStack.insert((player: player, index: index), at: 0)
            }
        } else {
            playerStack.insert((player: player, index: 0), at: 0)
        }
    }
    
    /// Adds turns depending on the effects of the player to the current round of fighting.
    /// - Parameter player: The index of the player
    func addEffectTurns(player: Int) {
        if !getFighter(player: player).effects.isEmpty {
            for index in getFighter(player: player).effects.indices {
                let effect: Effect = getFighter(player: player).effects[index]
                
                if effect.damageAmount != 0 && effect.name != Effects.bombed.rawValue {
                    playerStack.insert((player: player, index: -1 - index), at: 0)
                } else if effect.name == Effects.bombed.rawValue && effect.duration == 1 {
                    playerStack.insert((player: player, index: -1 - index), at: 0)
                }
            }
        }
    }
    
    /// Starts the turn of a player.
    /// - Parameter player: The id of the player
    func startTurn(player: Int) {
        let attacker: Fighter = getFighter(player: player)
        
        if usedMoves[player][0].target > -1 {
            if attacker.hasEffect(effectName: Effects.chained.rawValue) {
                battleLog += Localization.shared.getTranslation(key: "swapFailed", params: [attacker.name]) + "\n"
                return
            }
            
            battleLog += swapFighters(player: player, target: usedMoves[player][0].target)
        } else {
            battleLog += TurnLogic.shared.startTurn(player: player, fightLogic: self)
        }
    }
    
    /// Swaps two fighters.
    /// - Parameters:
    ///   - player: The id of the player
    ///   - target: The index of the targeted fighter
    /// - Returns: Returns the description of what occured during the swap
    func swapFighters(player: Int, target: Int) -> String {
        hasToSwap[player] = false //flag no longer necessary
        
        var text: String
        var applyEffect: Bool = false
        
        if getFighter(player: player).ability.name == Abilities.lastWill.rawValue {
            applyEffect = true
        } else if getFighter(player: player).ability.name == Abilities.naturalCure.rawValue {
            for effect in getFighter(player: player).effects {
                getFighter(player: player).removeEffect(effect: effect)
            }
        }
        
        text = Localization.shared.getTranslation(key: "swapWith", params: [getFighter(player: player).name, fighters[player][target].name]) + "\n"
        currentFighter[player] = target
        
        if applyEffect {
            getFighter(player: player).applyEffect(effect: Effects.blessed.getEffect())
        }
        
        var oppositePlayer: Int = 0
        if player == 0 {
            oppositePlayer = 1
        }
        if getFighter(player: oppositePlayer).ability.name == Abilities.intimidate.rawValue {
            if getFighter(player: player).applyEffect(effect: Effects.attackDrop.getEffect()) {
                text += Localization.shared.getTranslation(key: "statDecreased", params: [getFighter(player: player).name, "attack"]) + "\n"
            }
        }
                                                                                
        return text
                                                                                
    }
    
    /// Checks if fighter can swap within their team.
    /// - Parameter player: The id of the player
    /// - Returns: Returns whether the fighter can swap in their team
    func isAbleToSwap(player: Int) -> Bool {
        var counter: Int = 0
        for fighter in fighters[player] {
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
    
    /// Checks if game is over.
    /// - Returns: Returns whether one of the teams only consists of fainted fighters
    func isGameOver() -> Bool {
        var counter: Int = 0
        for fighter in fighters[0] {
            if fighter.currhp > 0 {
                counter += 1
            }
        }
        
        if counter == 0 { //all fighters in team have fainted -> unable to fight
            return true
        }
        
        for fighter in fighters[1] {
            if fighter.currhp > 0 {
                return false //fighter able to fight was found, both teams are able to fight
            }
        }
        
        return true //all fighters in team have fainted -> unable to fight
    }
    
    /// Ends the game with a forfeit.
    /// - Parameter player: The id of the player
    func forfeit(player: Int) {
        gameLogic.forfeit(player: player)
    }
    
    /// Determines the winner of the game. Currently no draws possible.
    /// - Returns: Returns the id of the winning player
    func getWinner() -> Int {
        //player who has forfeited loses automatically
        if gameLogic.forfeited[0] {
            return 1
        } else if gameLogic.forfeited[1] {
            return 0
        }
        
        //if one player has alive fighters other autmatically loses
        for fighter in fighters[0] {
            if fighter.currhp > 0 {
                return 0
            }
        }
        
        return 1
    }
}
