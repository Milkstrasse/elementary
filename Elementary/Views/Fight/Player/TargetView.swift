//
//  TargetView.swift
//  Elementary
//
//  Created by Janice Hablützel on 06.01.23.
//

import SwiftUI

struct TargetView: View {
    @Binding var currentSection: Section
    
    var fightLogic: FightLogic
    var player: Player
    
    @State var target: Int = 0
    
    /// Generates and returns info on a fighter.
    /// - Parameter fighter: The current fighter
    /// - Returns: Returns generated info on a fighter
    func generateInfo(fighter: Fighter, index: Int) -> String {
        var text: String = Localization.shared.getTranslation(key: "hpBar", params: ["\(fighter.currhp)", "\(fighter.getModifiedBase().health)"]) + " - "
        
        var oppositePlayer: Player = fightLogic.players[0]
        if player.id == 0 {
            oppositePlayer = fightLogic.players[1]
        }
        
        if fighter.getElement().hasAdvantage(element: oppositePlayer.getCurrentFighter().getElement(), weather: fightLogic.weather) {
            text += Localization.shared.getTranslation(key: "veryEffective")
        } else if fighter.getElement().hasDisadvantage(element: oppositePlayer.getCurrentFighter().getElement(), weather: fightLogic.weather) {
            text += Localization.shared.getTranslation(key: "notVeryEffective")
        } else {
            text += Localization.shared.getTranslation(key: "effective")
        }
        
        return text
    }
    
    var body: some View {
        ScrollViewReader { value in
            VStack(spacing: innerPadding/2) {
                ForEach(fightLogic.players[target].fighters.indices, id: \.self) { index in
                    Button(action: {
                        if fightLogic.makeMove(player: player, move: Move(source: player.getCurrentFighter(), index: -1, target: fightLogic.players[target].fighters[index], spell: fightLogic.gameLogic.tempSpells[player.currentFighterId + player.id * fightLogic.gameLogic.fullAmount/2], type: MoveType.spell)) {
                            if fightLogic.gameLogic.isPlayerReady(player: player) {
                                AudioPlayer.shared.playConfirmSound()
                                currentSection = Section.waiting
                            } else {
                                player.goToNextFighter()
                                
                                AudioPlayer.shared.playStandardSound()
                                currentSection = Section.options
                            }
                        } else {
                            AudioPlayer.shared.playStandardSound()
                            currentSection = Section.options
                        }
                    }) {
                        ActionView(titleKey: fightLogic.players[target].fighters[index].name, description: generateInfo(fighter: fightLogic.players[target].fighters[index], index: index), symbol: fightLogic.players[target].fighters[index].getElement().symbol, color: Color(hex: fightLogic.players[target].fighters[index].getElement().color))
                    }
                    .id(index + 1).opacity(fightLogic.players[target].fighters[index].currhp == 0 ? 0.5 : 1.0).disabled(fightLogic.players[target].fighters[index].currhp == 0)
                }
            }
            .onAppear {
                if player.getCurrentFighter().multiSpells[fightLogic.gameLogic.tempSpells[player.currentFighterId + player.id * fightLogic.gameLogic.fullAmount/2]].subSpells[0].range < 1 {
                    target = player.id
                } else if player.id == 0 {
                    target = 1
                }
                
                value.scrollTo(0)
            }
        }
    }
}

struct TargetView_Previews: PreviewProvider {
    static var previews: some View {
        TargetView(currentSection: Binding.constant(Section.team), fightLogic: FightLogic(players: [Player(id: 0, fighters: [GlobalData.shared.fighters[0]]), Player(id: 1, fighters: [GlobalData.shared.fighters[0]])], hasCPUPlayer: false, singleMode: true), player: Player(id: 0, fighters: [GlobalData.shared.fighters[0]]))
    }
}
