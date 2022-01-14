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
            } else if rightFighters[move.target].currhp == 0 {
                return false
            }
        }
        
        if hasToSwitch[player] {
            if !getFighter(player: player).hasEffect(effectName: Effects.chain.rawValue) || getFighter(player: player).currhp == 0 {
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
            
            if getFasterPlayer() == 0 {
                if usedMoves[1][0].skill.skills.count > 0 {
                    for index in usedMoves[1][0].skill.skills.indices.reversed() {
                        playerStack.insert((player: 1, index: index), at: 0)
                    }
                } else {
                    playerStack.insert((player: 1, index: 0), at: 0)
                }
                
                if usedMoves[0][0].skill.skills.count > 0 {
                    for index in usedMoves[0][0].skill.skills.indices.reversed() {
                        playerStack.insert((player: 0, index: index), at: 0)
                    }
                } else {
                    playerStack.insert((player: 0, index: 0), at: 0)
                }
            } else {
                if usedMoves[0][0].skill.skills.count > 0 {
                    for index in usedMoves[0][0].skill.skills.indices.reversed() {
                        playerStack.insert((player: 0, index: index), at: 0)
                    }
                } else {
                    playerStack.insert((player: 0, index: 0), at: 0)
                }
                
                if usedMoves[1][0].skill.skills.count > 0 {
                    for index in usedMoves[1][0].skill.skills.indices.reversed() {
                        playerStack.insert((player: 1, index: index), at: 0)
                    }
                } else {
                    playerStack.insert((player: 1, index: 0), at: 0)
                }
            }
            
            var endRound: Bool = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                var turns: Int = 0
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    let currentPlayer: Int = playerStack[0].player;
                    turns += 1
                    
                    if turns == 1 {
                        battleLog = ""
                    }
                    
                    processTurn(player: currentPlayer)
                    playerStack.removeFirst()
                    
                    if turns > 1 && playerStack.isEmpty {
                        if currentPlayer == 0 && getFighter(player: 1).currhp == 0 {
                            playerStack.insert((player: 1, index: 0), at: 0)
                        } else if currentPlayer == 1 && getFighter(player: 0).currhp == 0 {
                            playerStack.insert((player: 0, index: 0), at: 0)
                        }
                    } else if getFighter(player: currentPlayer).currhp == 0 {
                        playerStack.removeFirst() //TODO does it really work?
                    }
                    
                    if playerStack.isEmpty && !endRound {
                        if getFighter(player: 1).effects.count > 0 {
                            for index in getFighter(player: 1).effects.indices {
                                let effect: Effect = getFighter(player: 1).effects[index]
                                
                                if effect.damageAmount != 0 && effect.name != Effects.bomb.rawValue {
                                    playerStack.insert((player: 1, index: -1 - index), at: 0)
                                } else if effect.name == Effects.bomb.rawValue && effect.duration == 1 {
                                    playerStack.insert((player: 1, index: -1 - index), at: 0)
                                }
                            }
                        }
                        if getFighter(player: 0).effects.count > 0 {
                            for index in getFighter(player: 0).effects.indices {
                                let effect: Effect = getFighter(player: 0).effects[index]
                                
                                if effect.damageAmount != 0 && effect.name != Effects.bomb.rawValue {
                                    playerStack.insert((player: 0, index: -1 - index), at: 0)
                                } else if effect.name == Effects.bomb.rawValue && effect.duration == 1 {
                                    playerStack.insert((player: 0, index: -1 - index), at: 0)
                                }
                            }
                        }
                        
                        endRound = true
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
            if attacker.hasEffect(effectName: Effects.chain.rawValue) {
                battleLog += attacker.name + " failed to swap.\n"
                return
            }
            
            if player == 0 {
                battleLog += attacker.name + " swapped with " + leftFighters[usedMoves[player][0].target].name + ".\n"
                
                swapFighters(player: player, target: usedMoves[player][0].target)
            } else {
                battleLog += attacker.name + " swapped with " + rightFighters[usedMoves[player][0].target].name + ".\n"
                
                swapFighters(player: player, target: usedMoves[player][0].target)
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
