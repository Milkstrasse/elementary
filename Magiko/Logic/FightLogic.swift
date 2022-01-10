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
    
    @Published var leftFighters: [Fighter]
    @Published var rightFighters: [Fighter]
    
    var gameLogic: GameLogic = GameLogic()
    
    var usedMoves: [[Move]] = [[], []]
    var playerStack: [(player: Int, index: Int)] = []
    
    @Published var battling: Bool = false
    @Published var publishedText: String = "let the fight begin"
    @Published var gameOver: Bool = false
    
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
        if gameLogic.readyPlayers[player] {
            return false
        }
        
        if getFighter(player: player).currhp == 0 {
            if move.target > -1 {
                swapFighters(player: player, target: move.target)
            }
            
            return false
        }
        
        gameLogic.setReady(player: player, ready: true)
        usedMoves[player].insert(move, at: 0)
        
        if gameLogic.areBothReady() {
            battling = true
            publishedText = "Loading..."
            
            if getFasterPlayer() == 0 {
                for index in usedMoves[1][0].skill.skills.indices.reversed() {
                    playerStack.insert((player: 1, index: index), at: 0)
                }
                for index in usedMoves[0][0].skill.skills.indices.reversed() {
                    playerStack.insert((player: 0, index: index), at: 0)
                }
            } else {
                for index in usedMoves[0][0].skill.skills.indices.reversed() {
                    playerStack.insert((player: 0, index: index), at: 0)
                }
                for index in usedMoves[1][0].skill.skills.indices.reversed() {
                    playerStack.insert((player: 1, index: index), at: 0)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                var turns: Int = 0
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    let currentPlayer: Int = playerStack[0].player;
                    turns += 1
                    
                    if turns == 1 {
                        publishedText = ""
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
                        playerStack.removeFirst()
                    }
                    
                    if playerStack.isEmpty {
                        timer.invalidate()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            gameLogic.setReady(player: 0, ready: false)
                            gameLogic.setReady(player: 1, ready: false)
                            
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
        //target -> player wants to switch
        if usedMoves[0][0].target > -1 {
            return 0
        } else if usedMoves[1][0].target > -1 {
            return 1
        }
        
        if getFighter(player: 0).base.agility > getFighter(player: 1).base.agility {
            return 0
        } else if getFighter(player: 1).base.agility > getFighter(player: 0).base.agility {
            return 1
        } else if Bool.random() {
            return 0
        } else {
            return 1
        }
    }
    
    func processTurn(player: Int) {
        if getFighter(player: player).currhp == 0 {
            publishedText += getFighter(player: player).name + " fainted.\n"
            return
        }
        
        if usedMoves[player][0].target > -1 {
            if player == 0 {
                publishedText += getFighter(player: player).name + " swapped with " + leftFighters[usedMoves[player][0].target].name + ".\n"
                
                swapFighters(player: player, target: usedMoves[player][0].target)
            } else {
                publishedText += getFighter(player: player).name + " swapped with " + rightFighters[usedMoves[player][0].target].name + ".\n"
                
                swapFighters(player: player, target: usedMoves[player][0].target)
            }
        } else {
            attack(player: player, skill: usedMoves[player][0].skill)
        }
    }
    
    func swapFighters(player: Int, target: Int) {
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
    
    func attack(player: Int, skill: Skill) {
        if skill.skills[playerStack[0].index].power > 0 {
            var calculated: (damage: UInt, text: String)
            
            if player == 0 {
                calculated = DamageCalculator.shared.calcDamage(attacker: leftFighters[currentLeftFighter], defender: rightFighters[currentRightFighter], skill: skill.skills[playerStack[0].index], skillElement: skill.element)
                rightFighters[currentRightFighter].currhp -= calculated.damage
            } else {
                calculated = DamageCalculator.shared.calcDamage(attacker: rightFighters[currentRightFighter], defender: leftFighters[currentLeftFighter], skill: skill.skills[playerStack[0].index], skillElement: skill.element)
                leftFighters[currentLeftFighter].currhp -= calculated.damage
            }
            
            publishedText += getFighter(player: player).name + " used " + skill.name + ". " + calculated.text
        } else {
            if player == 0 {
                publishedText += StatModifier.shared.modifyStats(attacker: leftFighters[currentLeftFighter], defender: rightFighters[currentRightFighter], skill: skill.skills[playerStack[0].index], skillName: playerStack[0].index == 0 ? skill.name : nil)
            } else {
                publishedText += StatModifier.shared.modifyStats(attacker: rightFighters[currentRightFighter], defender: leftFighters[currentLeftFighter], skill: skill.skills[playerStack[0].index], skillName: playerStack[0].index == 0 ? skill.name : nil)
            }
        }
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
