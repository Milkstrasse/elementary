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
    
    @State var gestureStates: [Bool] = []
    @GestureState var isDetectingPress = false
    
    /// Generates and returns info on a witch.
    /// - Parameter witch: The current witch
    /// - Returns: Returns generated info on a witch
    func generateInfo(witch: Witch) -> String {
        var text: String = Localization.shared.getTranslation(key: "hpBar", params: ["\(witch.currhp)", "\(witch.getModifiedBase().health)"]) + " - "
        
        if isDetectingPress {
            text += Localization.shared.getTranslation(key: witch.getArtifact().name)
        } else {
            var oppositePlayer: Player = fightLogic.players[0]
            if player.id == 0 {
                oppositePlayer = fightLogic.players[1]
            }
            
            if witch.getElement().hasAdvantage(element: oppositePlayer.getCurrentWitch().getElement()) {
                text += Localization.shared.getTranslation(key: "veryEffective")
            } else if witch.getElement().hasDisadvantage(element: oppositePlayer.getCurrentWitch().getElement()) {
                text += Localization.shared.getTranslation(key: "notVeryEffective")
            } else {
                text += Localization.shared.getTranslation(key: "effective")
            }
        }
        
        return text
    }
    
    var body: some View {
        ScrollViewReader { value in
            VStack(spacing: 5) {
                DetailedActionView(title: player.getCurrentWitch().name, description: generateInfo(witch: player.getCurrentWitch()), symbol: player.getCurrentWitch().getElement().symbol).padding(.bottom, 5).id(0)
                    .onTapGesture {}
                    .gesture(
                        LongPressGesture(minimumDuration: .infinity)
                            .updating($isDetectingPress) { value, state, _ in state = value }
                    )
                ForEach(player.witches.indices, id: \.self) { index in
                    if index != player.currentWitchId {
                        Button(action: {
                        }) {
                            DetailedActionView(title: player.witches[index].name, description: generateInfo(witch: player.witches[index]), symbol: player.witches[index].getElement().symbol)
                        }
                        .id(index + 1).opacity(player.witches[index].currhp == 0 ? 0.7 : 1.0).disabled(player.witches[index].currhp == 0)
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: .infinity)
                                .updating($isDetectingPress) { value, state, _ in state = value }
                        )
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded { _ in
                                    if fightLogic.makeMove(player: player, move: Move(source: player.getCurrentWitch(), target: index, spell: Spell())) {
                                        AudioPlayer.shared.playConfirmSound()
                                        currentSection = .waiting
                                    } else {
                                        AudioPlayer.shared.playStandardSound()
                                        currentSection = .options
                                    }
                        })
                    }
                }
            }
            .padding(.horizontal, 15)
            .onAppear {
                value.scrollTo(0)
            }
        }
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView(currentSection:Binding.constant(.team), fightLogic: FightLogic(players: [Player(id: 0, witches: [exampleWitch]), Player(id: 1, witches: [exampleWitch])]), player: Player(id: 0, witches: [exampleWitch]))
    }
}
