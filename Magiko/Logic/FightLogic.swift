//
//  FightLogic.swift
//  Magiko
//
//  Created by Janice Hablützel on 06.01.22.
//

import Foundation

class FightLogic: ObservableObject {
    var currentLeftFighter: Int = 0
    var currentRightFighter: Int = 0
    
    @Published var leftFighters: [Fighter]
    @Published var rightFighters: [Fighter]
    
    var gameLogic: GameLogic = GameLogic()
    
    var usedMoves: [[Move]] = [[], []]
    
    @Published var battling: Bool = false
    
    @Published var publishedText: String = ""
    
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
        
        gameLogic.setReady(player: player, ready: true)
        usedMoves[player].insert(move, at: 0)
        
        if gameLogic.areBothReady() {
            print("START FIGHTING")
            battling = true
            
            DispatchQueue.main.async { [self] in
                publishedText = "Loading..."
                let fasterPlayer: Int = getFasterPlayer()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    publishedText = ""
                    processTurn(player: fasterPlayer)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if fasterPlayer == 0 {
                            processTurn(player: 1)
                        } else {
                            processTurn(player: 0)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
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
        if usedMoves[player][0].target > -1 {
            if player == 0 {
                publishedText += getFighter(player: player).name + " swapped with " + leftFighters[usedMoves[player][0].target].name + "\n"
                
                currentLeftFighter = usedMoves[player][0].target
            } else {
                publishedText += getFighter(player: player).name + " swapped with " + rightFighters[usedMoves[player][0].target].name + "\n"
                
                currentRightFighter = usedMoves[player][0].target
            }
        } else {
            attack(player: player, skill: usedMoves[player][0].skill)
        }
    }
    
    func undoMove(player: Int) {
        gameLogic.setReady(player: player, ready: false)
        usedMoves[player].removeFirst()
    }
    
    func attack(player: Int, skill: Skill) {
        if player == 0 {
            rightFighters[currentRightFighter].currhp -= DamageCalculator.shared.calcDamage(attacker: leftFighters[currentLeftFighter], defender: rightFighters[currentRightFighter], skill: skill.skills[0])
        } else {
            leftFighters[currentLeftFighter].currhp -= DamageCalculator.shared.calcDamage(attacker: rightFighters[currentRightFighter], defender: rightFighters[currentRightFighter], skill: skill.skills[0])
        }
        
        publishedText += getFighter(player: 0).name + " used " + usedMoves[player][0].skill.name + "\n"
    }
}
