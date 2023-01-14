//
//  OptionsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 23.08.22.
//

import SwiftUI

struct OptionsView: View {
    @Binding var currentSection: Section
    @Binding var gameOver: Bool
    
    let fightLogic: FightLogic
    let player: Player
    
    var body: some View {
        ScrollViewReader { value in
            VStack(spacing: innerPadding/2) {
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    currentSection = Section.spells
                }) {
                    ActionView(titleKey: "spells", description: Localization.shared.getTranslation(key: "spellsDescr"), symbol: "0xf6de", color: Color("Positive"))
                }
                .id(0).opacity(player.hasToSwap ? 0.5 : 1.0).disabled(player.hasToSwap)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    currentSection = Section.team
                }) {
                    ActionView(titleKey: "team", description: Localization.shared.getTranslation(key: "teamDescr"), symbol: "0xf500", color: Color("Positive"))
                }
                .id(1)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    currentSection = Section.info
                }) {
                    ActionView(titleKey: "information", description: Localization.shared.getTranslation(key: "informationDescr"), symbol: "0xf02d", color: Color("Border"))
                }
                .id(2)
                Button(action: {
                    AudioPlayer.shared.playCancelSound()
                    
                    fightLogic.forfeit(player: player.id)
                    gameOver = true
                }) {
                    ActionView(titleKey: "forfeit", description: Localization.shared.getTranslation(key: "forfeitDescr"), symbol: "0xf70c", color: Color("Negative"))
                }
                .id(3)
            }
            .onAppear {
                value.scrollTo(0)
            }
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView(currentSection: Binding.constant(Section.options), gameOver:Binding.constant(false), fightLogic: FightLogic(players: [Player(id: 0, fighters: [GlobalData.shared.fighters[0]]), Player(id: 1, fighters: [GlobalData.shared.fighters[0]])], hasCPUPlayer: false, singleMode: true), player: Player(id: 1, fighters: [GlobalData.shared.fighters[0]]))
    }
}
