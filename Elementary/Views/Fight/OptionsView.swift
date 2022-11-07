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
                    currentSection = .spells
                }) {
                    ActionView(titleKey: "spells", description: Localization.shared.getTranslation(key: "spellsDescr"), symbol: "0xf6de", color: Color("Positive"))
                }
                .id(0).opacity(player.hasToSwap ? 0.5 : 1.0).disabled(player.hasToSwap)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    currentSection = .team
                }) {
                    ActionView(titleKey: "team", description: Localization.shared.getTranslation(key: "teamDescr"), symbol: "0xf500", color: Color("Positive"))
                }
                .id(1)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    currentSection = .info
                }) {
                    ActionView(titleKey: "info", description: Localization.shared.getTranslation(key: "infoDescr"), symbol: "0xf02d", color: Color("Border"))
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
        OptionsView(currentSection:Binding.constant(.options), gameOver:Binding.constant(false), fightLogic: FightLogic(players: [Player(id: 0, fighters: [exampleFighter]), Player(id: 1, fighters: [exampleFighter])]), player: Player(id: 1, fighters: [exampleFighter]))
    }
}
