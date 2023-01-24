//
//  TeamView.swift
//  Elementary
//
//  Created by Janice Hablützel on 24.08.22.
//

import SwiftUI

struct TeamView: View {
    @Binding var currentSection: Section
    
    var fightLogic: FightLogic
    var player: Player
    
    @State var isDetectingPress: Bool = false
    @State var selectIndex: Int = -1
    
    /// Generates and returns info on a fighter.
    /// - Parameter fighter: The current fighter
    /// - Returns: Returns generated info on a fighter
    func generateInfo(fighter: Fighter, index: Int) -> String {
        var text: String = Localization.shared.getTranslation(key: "hpBar", params: ["\(fighter.currhp)", "\(fighter.getModifiedBase().health)"]) + " - "
        
        if isDetectingPress && selectIndex == index {
            text += Localization.shared.getTranslation(key: fighter.getArtifact().name)
        } else {
            let oppositePlayer: Player = fightLogic.players[player.getOppositePlayerId()]
            
            if fighter.getElement().hasAdvantage(element: oppositePlayer.getCurrentFighter().getElement(), weather: fightLogic.weather) {
                text += Localization.shared.getTranslation(key: "veryEffective")
            } else if fighter.getElement().hasDisadvantage(element: oppositePlayer.getCurrentFighter().getElement(), weather: fightLogic.weather) {
                text += Localization.shared.getTranslation(key: "notVeryEffective")
            } else {
                text += Localization.shared.getTranslation(key: "effective")
            }
        }
        
        return text
    }
    
    var body: some View {
        ScrollViewReader { value in
            VStack(spacing: innerPadding/2) {
                ActionView(titleKey: player.getCurrentFighter().name, description: generateInfo(fighter: player.getCurrentFighter(), index: 0), symbol: player.getCurrentFighter().getElement().symbol, color: Color(hex: player.getCurrentFighter().getElement().color)).id(0)
                    .onTapGesture {}
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if selectIndex < 0 {
                                    selectIndex = 0
                                }
                                
                                isDetectingPress = true
                            }
                            .onEnded({ _ in
                                selectIndex = -1
                                
                                isDetectingPress = false
                            })
                    )
                ForEach(player.fighters.indices, id: \.self) { index in
                    if index != player.currentFighterId {
                        Group {
                            if fightLogic.singleMode {
                                Button(action: {
                                }) {
                                    ActionView(titleKey: player.getFighter(index: index).name, description: generateInfo(fighter: player.getFighter(index: index), index: index), symbol: player.getFighter(index: index).getElement().symbol, color: Color(hex: player.getFighter(index: index).getElement().color))
                                }
                            } else {
                                ActionView(titleKey: player.getFighter(index: index).name, description: generateInfo(fighter: player.getFighter(index: index), index: index), symbol: player.getFighter(index: index).getElement().symbol, color: Color(hex: player.getFighter(index: index).getElement().color))
                            }
                        }
                        .opacity(player.getFighter(index: index).currhp == 0 ? 0.5 : 1.0).disabled(player.getFighter(index: index).currhp == 0)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if selectIndex < 0 {
                                        selectIndex = index
                                    }
                                    
                                    isDetectingPress = true
                                }
                                .onEnded({ _ in
                                    selectIndex = -1
                                    
                                    isDetectingPress = false
                                })
                        )
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded { _ in
                                    if fightLogic.makeMove(player: player, move: Move(source: player.currentFighterId, index: index, target: index, targetedPlayer: player.id, spell: -1, type: MoveType.swap)) {
                                        AudioPlayer.shared.playConfirmSound()
                                        currentSection = Section.waiting
                                    } else {
                                        AudioPlayer.shared.playStandardSound()
                                        currentSection = Section.options
                                    }
                                })
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
        TeamView(currentSection: Binding.constant(Section.team), fightLogic: FightLogic(players: [Player(id: 0, fighters: [GlobalData.shared.fighters[0]]), Player(id: 1, fighters: [GlobalData.shared.fighters[0]])], hasCPUPlayer: false, singleMode: true), player: Player(id: 0, fighters: [GlobalData.shared.fighters[0]]))
    }
}
