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
    
    @State var isDetectingPress: Bool = false
    @State var selectIndex: Int = -1
    
    /// Generates and returns info on a witch.
    /// - Parameter witch: The current witch
    /// - Returns: Returns generated info on a witch
    func generateInfo(witch: Witch, index: Int) -> String {
        var text: String = Localization.shared.getTranslation(key: "hpBar", params: ["\(witch.currhp)", "\(witch.getModifiedBase().health)"]) + " - "
        
        if isDetectingPress && selectIndex == index {
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
            HStack(spacing: 5) {
                DetailedActionView(title: player.getCurrentWitch().name, description: generateInfo(witch: player.getCurrentWitch(), index: 0), symbol: player.getCurrentWitch().getElement().symbol, width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30).padding(.trailing, 5).id(0)
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
                ForEach(player.witches.indices, id: \.self) { index in
                    if index != player.currentWitchId {
                        Button(action: {
                        }) {
                            DetailedActionView(title: player.witches[index].name, description: generateInfo(witch: player.witches[index], index: index), symbol: player.witches[index].getElement().symbol, width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                        }
                        .id(index + 1).opacity(player.witches[index].currhp == 0 ? 0.7 : 1.0).disabled(player.witches[index].currhp == 0)
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
            .onAppear {
                value.scrollTo(0)
            }
        }
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView(currentSection:Binding.constant(.team), fightLogic: FightLogic(players: [Player(id: 0, witches: [exampleWitch]), Player(id: 1, witches: [exampleWitch])]), player: Player(id: 0, witches: [exampleWitch]), geoHeight: 375)
    }
}
