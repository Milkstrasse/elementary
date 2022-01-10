//
//  TeamView.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import SwiftUI

struct TeamView: View {
    @Binding var currentSection: Section
    
    @ObservedObject var fightLogic: FightLogic
    let player: Int
    
    let geoHeight: CGFloat
    
    var body: some View {
        HStack(spacing: 5) {
            if player == 0 {
                DetailedActionView(title: fightLogic.leftFighters[fightLogic.currentLeftFighter].name, description: "50/50HP - No Status", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                ForEach(fightLogic.leftFighters.indices) { index in
                    if index != fightLogic.currentLeftFighter {
                        Button(action: {
                            if fightLogic.makeMove(player: player, move: Move(source: fightLogic.getFighter(player: player), target: index, skill: Skill())) {
                                currentSection = .waiting
                            }
                        }) {
                            DetailedActionView(title: fightLogic.leftFighters[index].name, description: "50/50HP - No Status", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                        }
                    }
                }
            } else {
                DetailedActionView(title: fightLogic.rightFighters[fightLogic.currentRightFighter].name, description: "50/50HP - No Status", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                ForEach(fightLogic.rightFighters.indices) { index in
                    if index != fightLogic.currentRightFighter {
                        Button(action: {
                            if fightLogic.makeMove(player: player, move: Move(source: fightLogic.getFighter(player: player), target: index, skill: Skill())) {
                                currentSection = .waiting
                            }
                        }) {
                            DetailedActionView(title: fightLogic.rightFighters[index].name, description: "50/50HP - No Status", width: geoHeight - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                        }
                    }
                }
            }
        }
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView(currentSection: .constant(.team), fightLogic: FightLogic(leftFighters: [exampleFighter], rightFighters: [exampleFighter]), player: 0, geoHeight: 375)
    }
}
