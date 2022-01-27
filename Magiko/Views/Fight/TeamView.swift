//
//  TeamView.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import SwiftUI

struct TeamView: View {
    @Binding var currentSection: Section
    
    @ObservedObject var fightLogic: FightLogic
    let player: Int
    
    let geoHeight: CGFloat
    
    func generateDescription(fighter: Fighter) -> String {
        var text: String = "\(fighter.currhp)/\(fighter.getModifiedBase().health)HP - "
        
        var oppositePlayer: Int = 0
        if player == 0 {
            oppositePlayer = 1
        }
        
        if fighter.element.hasAdvantage(element: fightLogic.getFighter(player: oppositePlayer).element) {
            text += "Very Effective"
        } else if fighter.element.hasDisadvantage(element: fightLogic.getFighter(player: oppositePlayer).element) {
            text += "Not Very Effective"
        } else {
            text += "Effective"
        }
        
        return text
    }
    
    var body: some View {
        HStack(spacing: 5) {
            DetailedActionView(title: fightLogic.getFighter(player: player).name, description: generateDescription(fighter: fightLogic.getFighter(player: player)), width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
            ForEach(fightLogic.fighters[player].indices) { index in
                if index != fightLogic.currentFighter[player] {
                    Button(action: {
                        if fightLogic.makeMove(player: player, move: Move(source: fightLogic.getFighter(player: player), target: index, skill: Skill())) {
                            AudioPlayer.shared.playConfirmSound()
                            currentSection = .waiting
                        } else {
                            AudioPlayer.shared.playStandardSound()
                            currentSection = .options
                        }
                    }) {
                        DetailedActionView(title: fightLogic.fighters[player][index].name, description: generateDescription(fighter: fightLogic.fighters[player][index]), width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                    }
                }
            }
        }
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView(currentSection: .constant(.team), fightLogic: FightLogic(leftFighters: [exampleFighter], rightFighters: [exampleFighter]), player: 0, geoHeight: 375)
    }
}
