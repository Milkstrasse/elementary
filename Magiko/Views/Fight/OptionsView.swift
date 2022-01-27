//
//  OptionsView.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import SwiftUI

struct OptionsView: View {
    @Binding var currentSection: Section
    @Binding var gameOver: Bool
    
    let fightLogic: FightLogic
    let player: Int
    
    let geoHeight: CGFloat
    
    var body: some View {
        HStack(spacing: 5) {
            Button(action: {
                AudioPlayer.shared.playStandardSound()
                currentSection = .skills
            }) {
                DetailedActionView(title: "Fight", description: "Use your skills", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
            }
            .disabled(fightLogic.hasToSwap[player])
            Button(action: {
                AudioPlayer.shared.playStandardSound()
                currentSection = .team
            }) {
                DetailedActionView(title: "Team", description: "Switch out", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
            }
            Button(action: {
                AudioPlayer.shared.playCancelSound()
                fightLogic.forfeit(player: player)
                gameOver = true
            }) {
                DetailedActionView(title: "Forfeit", description: "End battle", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
            }
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView(currentSection: .constant(.options), gameOver: .constant(false), fightLogic: FightLogic(leftFighters: [exampleFighter], rightFighters: [exampleFighter]), player: 0, geoHeight: 375)
    }
}
