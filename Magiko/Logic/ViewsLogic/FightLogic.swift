//
//  FightLogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

class FightLogic: ObservableObject {
    @Published var currentLeftFighter: Int = 0
    @Published var currentRightFighter: Int = 0
    var hasToSwitch: [Bool] = [false, false]
    
    @Published var leftFighters: [Fighter]
    @Published var rightFighters: [Fighter]
    
    var gameLogic: GameLogic = GameLogic()
    
    var usedMoves: [[Move]] = [[], []]
    var playerStack: [(player: Int, index: Int)] = []
    
    @Published var battling: Bool = false
    @Published var battleLog: String = "let the fight begin"
    @Published var gameOver: Bool = false
    
    @Published var weather: Effect?
    
    init(leftFighters: [Fighter], rightFighters: [Fighter]) {
        self.leftFighters = leftFighters
        self.rightFighters = rightFighters
    }
    
    func getFighter(player: Int) -> Fighter {
        if player == 0 {
            return leftFighters[currentLeftFighter]
        } else {
            return rightFighters[currentRightFighter]
        }
    }
    
    func isValid() -> Bool {
        return (leftFighters.count > 0 && leftFighters.count <= 4) && (rightFighters.count > 0 && rightFighters.count <= 4)
    }
    
    func makeMove(player: Int, move: Move) -> Bool {
        if gameLogic.readyPlayers[player] || move.skill.useCounter + getFighter(player: player).staminaUse > move.skill.getUses(fighter: getFighter(player: player)) {
            return false
        } else if move.target > -1 {
            if player == 0 && leftFighters[move.target].currhp == 0 {
                return false
            } else if player == 1 && rightFighters[move.target].currhp == 0 {
                return false
            }
        }
        
        if hasToSwitch[player] {
            if !getFighter(player: player).hasEffect(effectName: Effects.chained.rawValue) || getFighter(player: player).currhp == 0 {
                if move.target > -1 {
                    swapFighters(player: player, target: move.target)
                }
                
                return false
            }
        }
        
        gameLogic.setReady(player: player, ready: true)
        
        if move.target < 0 {
            if getFighter(player: player).hasEffect(effectName: Effects.confused.rawValue) {
                let randomMove: Move = Move(source: move.source, skill: getFighter(player: player).skills[Int.random(in: 0 ..< getFighter(player: player).skills.count)])
                usedMoves[player].insert(randomMove, at: 0)
            } else if usedMoves[player].count > 0 && getFighter(player: player).hasEffect(effectName: Effects.locked.rawValue) {
                if usedMoves[player][0].target < 0 {
                    usedMoves[player].insert(usedMoves[player][0], at: 0)
                } else {
                    usedMoves[player].insert(move, at: 0)
                }
            } else {
                usedMoves[player].insert(move, at: 0)
            }
        } else {
            usedMoves[player].insert(move, at: 0)
        }
        
        if gameLogic.areBothReady() {
            battling = true
            battleLog = "Loading..."
            
            usedMoves[0][0].useSkill(amount: getFighter(player: 0).staminaUse)
            usedMoves[1][0].useSkill(amount: getFighter(player: 1).staminaUse)
            
            hasToSwitch[0] = false
            hasToSwitch[1] = false
            
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
            
            addMoves(player: getFasterPlayer())
            
            var endRound: Bool = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                let firstTurns: Int = playerStack.count
                var turns: Int = 0
                
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    let currentPlayer: Int = playerStack[0].player;
                    turns += 1
                    
                    if turns == 1 {
                        battleLog = ""
                    }
                    
                    processTurn(player: currentPlayer)
                    playerStack.removeFirst()
                    
                    if playerStack.isEmpty && !endRound {
                        endRound = addTurns(currentPlayer: currentPlayer, turns: turns, firstTurns: firstTurns)
                    }
                    
                    if playerStack.isEmpty {
                        timer.invalidate()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            gameLogic.setReady(player: 0, ready: false)
                            gameLogic.setReady(player: 1, ready: false)
                            
                            print(battleLog)
                            
                            battling = false
                        }
                    }
                }
            }
            //fasterPlayer = get faster player
            //playerTurn of fasterPlayer
            //playerTurn of other player
            //some status effects
        }
        
        return true
    }
    
    func addTurns(currentPlayer: Int, turns: Int, firstTurns: Int) -> Bool {
        if getFighter(player: 1).currhp == 0 {
            playerStack.insert((player: 1, index: 0), at: 0)
            
            if getFighter(player: 0).currhp == 0 {
                playerStack.insert((player: 0, index: 0), at: 0)
                return true
            }
            
            if currentPlayer == 0 {
                addEffects(player: 0)
            } else {
                if turns == firstTurns {
                    addMoves(player: 0)
                } else {
                    addEffects(player: 0)
                }
            }
            
            return true
        } else if getFighter(player: 0).currhp == 0 {
            playerStack.insert((player: 0, index: 0), at: 0)
            
            if getFighter(player: 1).currhp == 0 {
                playerStack.insert((player: 1, index: 0), at: 0)
                return true
            }
            
            if currentPlayer == 1 {
                addEffects(player: 1)
            } else {
                if turns == firstTurns {
                    addMoves(player: 1)
                } else {
                    addEffects(player: 1)
                }
            }
            
            return true
        }
        
        if turns == firstTurns {
            if currentPlayer == 0 {
                addMoves(player: 1)
            } else {
                addMoves(player: 0)
            }
            
            return false
        } else {
            addEffects(player: 0)
            addEffects(player: 1)
        }
        
        return true
    }
    
    func addMoves(player: Int) {
        if usedMoves[player][0].skill.skills.count > 0 {
            for index in usedMoves[player][0].skill.skills.indices.reversed() {
                playerStack.insert((player: player, index: index), at: 0)
            }
        } else {
            playerStack.insert((player: player, index: 0), at: 0)
        }
    }
    
    func addEffects(player: Int) {
        if getFighter(player: player).effects.count > 0 {
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
    
    func getFasterPlayer() -> Int {
        //target -> player wants to switch -> priority
        if usedMoves[0][0].target > -1 {
            return 0
        } else if usedMoves[1][0].target > -1 {
            return 1
        }
        
        if usedMoves[0][0].skill.type == "shield" {
            return 0
        } else if usedMoves[1][0].skill.type == "shield" {
            return 1
        }
        
        var fasterPlayer: Int
        
        if getFighter(player: 0).base.agility > getFighter(player: 1).base.agility {
            fasterPlayer = 0
        } else if getFighter(player: 1).base.agility > getFighter(player: 0).base.agility {
            fasterPlayer = 1
        } else if Bool.random() {
            fasterPlayer = 0
        } else {
            fasterPlayer = 1
        }
        
        return fasterPlayer
    }
    
    func processTurn(player: Int) {
        let attacker: Fighter = getFighter(player: player)
        
        if usedMoves[player][0].target > -1 {
            if attacker.hasEffect(effectName: Effects.chained.rawValue) {
                battleLog += Localization.shared.getTranslation(key: "swapFailed", params: [attacker.name]) + "\n"
                return
            }
            
            battleLog += Localization.shared.getTranslation(key: "swapWith", params: [attacker.name, leftFighters[usedMoves[player][0].target].name]) + "\n"
            
            var addEffect: Bool = false
            if attacker.ability.name == Abilities.lastWill.rawValue {
                addEffect = true
            }
            
            swapFighters(player: player, target: usedMoves[player][0].target)
            
            if addEffect {
                if getFighter(player: player).applyEffect(effect: Effects.blessed.getEffect()) {
                    battleLog += Localization.shared.getTranslation(key: "becameEffect", params: [getFighter(player: player).name, Effects.blessed.rawValue]) + "\n"
                }
            }
        } else {
            battleLog += TurnLogic.shared.startTurn(player: player, fightLogic: self)
        }
    }
    
    func swapFighters(player: Int, target: Int) {
        hasToSwitch[player] = false
        
        if player == 0 {
            currentLeftFighter = target
        } else {
            currentRightFighter = target
        }
    }
    
    func undoMove(player: Int) {
        gameLogic.setReady(player: player, ready: false)
        usedMoves[player].removeFirst()
    }
    
    func isGameOver() -> Bool {
        var counter: Int = 0
        for fighter in leftFighters {
            if fighter.currhp > 0 {
                counter += 1
            }
        }
        
        if counter == 0 {
            return true
        }
        
        for fighter in rightFighters {
            if fighter.currhp > 0 {
                return false
            }
        }
        
        return true
    }
    
    func forfeit(player: Int) {
        gameLogic.forfeit(player: player)
    }
    
    func getWinner() -> Int {
        if gameLogic.forfeited[0] {
            return 1
        } else if gameLogic.forfeited[1] {
            return 0
        }
        
        for fighter in leftFighters {
            if fighter.currhp > 0 {
                return 0
            }
        }
        
        return 1
    }
}
