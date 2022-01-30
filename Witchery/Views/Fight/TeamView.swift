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
    @ObservedObject var player: Player
    
    let geoHeight: CGFloat
    
    func generateDescription(witch: Witch) -> String {
        var text: String = "\(witch.currhp)/\(witch.getModifiedBase().health)HP - "
        
        var oppositePlayer: Player = fightLogic.players[0]
        if player.id == 0 {
            oppositePlayer = fightLogic.players[1]
        }
        
        if witch.element.hasAdvantage(element: oppositePlayer.getCurrentWitch().element) {
            text += Localization.shared.getTranslation(key: "veryEffective")
        } else if witch.element.hasDisadvantage(element: oppositePlayer.getCurrentWitch().element) {
            text += Localization.shared.getTranslation(key: "notVeryEffective")
        } else {
            text += Localization.shared.getTranslation(key: "effective")
        }
        
        return text
    }
    
    var body: some View {
        ScrollViewReader { value in
            HStack(spacing: 5) {
                DetailedActionView(title: player.getCurrentWitch().name, description: generateDescription(witch: player.getCurrentWitch()), symbol: player.getCurrentWitch().element.symbol, width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30).padding(.trailing, 5).id(0)
                ForEach(player.witches.indices) { index in
                    if index != player.currentWitchId {
                        Button(action: {
                            if fightLogic.makeMove(player: player, move: Move(source: player.getCurrentWitch(), target: index, spell: Spell())) {
                                AudioPlayer.shared.playConfirmSound()
                                currentSection = .waiting
                            } else {
                                AudioPlayer.shared.playStandardSound()
                                currentSection = .options
                            }
                        }) {
                            DetailedActionView(title: player.witches[index].name, description: generateDescription(witch: player.witches[index]), symbol: player.witches[index].element.symbol, width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                        }
                        .id(index + 1).opacity(player.witches[index].currhp == 0 ? 0.7 : 1.0).disabled(player.witches[index].currhp == 0)
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
        TeamView(currentSection: .constant(.team), fightLogic: FightLogic(players: [Player(id: 0, witches: [exampleWitch]), Player(id: 1, witches: [exampleWitch])]), player: Player(id: 0, witches: [exampleWitch]), geoHeight: 375)
    }
}
