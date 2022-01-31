//
//  OptionsView.swift
//  Witchery
//
//  Created by Janice Hablützel on 07.01.22.
//

import SwiftUI

struct OptionsView: View {
    @Binding var currentSection: Section
    @Binding var gameOver: Bool
    
    let fightLogic: FightLogic
    let player: Player
    
    var tutorialCounter: Int = -1
    
    let geoHeight: CGFloat
    
    var body: some View {
        ScrollViewReader { value in
            HStack(spacing: 5) {
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    currentSection = .spells
                }) {
                    DetailedActionView(title: "spells", description: "spellsDescr", symbol: "0xf6de", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                }
                .id(0).opacity(player.hasToSwap ? 0.7 : 1.0).disabled(tutorialCounter == 1 || tutorialCounter > 2)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    currentSection = .team
                }) {
                    DetailedActionView(title: "coven", description: "covenDescr", symbol: "0xf500", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                }
                .id(1).disabled(tutorialCounter%2 == 0 || tutorialCounter > 2)
                Button(action: {
                    AudioPlayer.shared.playCancelSound()
                    fightLogic.forfeit(player: player.id)
                    gameOver = true
                }) {
                    DetailedActionView(title: "forfeit", description: "forfeitDescr", symbol: "0xf70c", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                }
                .id(2).disabled(tutorialCounter >= 0 && tutorialCounter != 3)
            }
            .onAppear {
                value.scrollTo(0)
            }
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView(currentSection: .constant(.options), gameOver: .constant(false), fightLogic: FightLogic(players: [Player(id: 0, witches: [exampleWitch]), Player(id: 1, witches: [exampleWitch])]), player: Player(id: 1, witches: [exampleWitch]), geoHeight: 375)
    }
}
