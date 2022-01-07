//
//  SkillsView.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import SwiftUI

struct SkillsView: View {
    @Binding var currentSection: Section
    
    let fightLogic: FightLogic
    let player: Int
    
    let geoHeight: CGFloat
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(fightLogic.getFighter(player: player).skills, id: \.self) { skill in
                Button(action: {
                    if fightLogic.makeMove(player: player, move: Move(source: fightLogic.getFighter(player: player), skill: skill)) {
                        currentSection = .waiting
                    }
                }) {
                    DetailedActionView(title: skill.name, description: "Effective - 10/10PP", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                }
            }
        }
    }
}

struct SkillsView_Previews: PreviewProvider {
    static var previews: some View {
        SkillsView(currentSection: .constant(.skills), fightLogic: FightLogic(leftFighters: [exampleFighter], rightFighters: [exampleFighter]), player: 0, geoHeight: 375)
    }
}
