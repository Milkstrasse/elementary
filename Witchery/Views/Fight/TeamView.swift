//
//  TeamView.swift
//  Witchery
//
//  Created by Janice Hablützel on 07.01.22.
//

import SwiftUI

struct TeamView: View {
    @Binding var currentSection: Section
    
    @ObservedObject var fightLogic: FightLogic
    let player: Int
    
    let geoHeight: CGFloat
    
    func generateDescription(witch: Witch) -> String {
        var text: String = "\(witch.currhp)/\(witch.getModifiedBase().health)HP - "
        
        var oppositePlayer: Int = 0
        if player == 0 {
            oppositePlayer = 1
        }
        
        if witch.element.hasAdvantage(element: fightLogic.getWitch(player: oppositePlayer).element) {
            text += Localization.shared.getTranslation(key: "veryEffective")
        } else if witch.element.hasDisadvantage(element: fightLogic.getWitch(player: oppositePlayer).element) {
            text += Localization.shared.getTranslation(key: "notVeryEffective")
        } else {
            text += Localization.shared.getTranslation(key: "effective")
        }
        
        return text
    }
    
    var body: some View {
        ScrollViewReader { value in
            HStack(spacing: 5) {
                DetailedActionView(title: fightLogic.getWitch(player: player).name, description: generateDescription(witch: fightLogic.getWitch(player: player)), symbol: fightLogic.getWitch(player: player).element.symbol, width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30).padding(.trailing, 5).id(0)
                ForEach(fightLogic.witches[player].indices) { index in
                    if index != fightLogic.currentWitch[player] {
                        Button(action: {
                            if fightLogic.makeMove(player: player, move: Move(source: fightLogic.getWitch(player: player), target: index, spell: Spell())) {
                                AudioPlayer.shared.playConfirmSound()
                                currentSection = .waiting
                            } else {
                                AudioPlayer.shared.playStandardSound()
                                currentSection = .options
                            }
                        }) {
                            DetailedActionView(title: fightLogic.witches[player][index].name, description: generateDescription(witch: fightLogic.witches[player][index]), symbol: fightLogic.witches[player][index].element.symbol, width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                        }
                        .id(index + 1).opacity(fightLogic.witches[player][index].currhp == 0 ? 0.7 : 1.0).disabled(fightLogic.witches[player][index].currhp == 0)
                    }
                }
            }
            .onAppear {
                value.scrollTo(0)
            }
        }
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView(currentSection: .constant(.team), fightLogic: FightLogic(leftWitches: [exampleWitch], rightWitches: [exampleWitch]), player: 0, geoHeight: 375)
    }
}
