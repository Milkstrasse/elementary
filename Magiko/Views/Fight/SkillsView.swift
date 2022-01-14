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
    
    @State var gestureStates: [Bool] = []
    @GestureState var isDetectingPress = false
    
    func getEffectiveness(skillElement: String) -> String {
        if fightLogic.getFighter(player: player).ability.name == Abilities.ethereal.rawValue {
            return "Effective"
        }
        
        var modifier: Float
        let element: Element = GlobalData.shared.elements[skillElement] ?? Element()
        
        if player == 0 {
            modifier = DamageCalculator.shared.getElementalModifier(attacker: fightLogic.getFighter(player: 0), defender: fightLogic.getFighter(player: 1), skillElement: element)
        } else {
            modifier = DamageCalculator.shared.getElementalModifier(attacker: fightLogic.getFighter(player: 1), defender: fightLogic.getFighter(player: 0), skillElement: element)
        }
        
        switch modifier {
        case 4.0:
            return "Super Effective"
        case 2.0:
            return "Very Effective"
        case 0.5:
            return "Not Very Effective"
        case 0.25:
            return "Not Effective"
        default:
            return "Effective"
        }
    }
    
    func generateDescription(skill: Skill, fighter: Fighter) -> String {
        return getEffectiveness(skillElement: skill.element) + " - \(skill.getUses(fighter: fighter) - skill.useCounter)/\(skill.getUses(fighter: fighter))PP"
    }
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(fightLogic.getFighter(player: player).skills, id: \.self) { skill in
                Button(action: {
                }) {
                    ZStack {
                        if isDetectingPress {
                            DetailedSkillView(skill: skill, width: geoHeight - 30)
                        } else {
                            DetailedActionView(title: skill.name, description: generateDescription(skill: skill, fighter: fightLogic.getFighter(player: player)), width: geoHeight - 30)
                        }
                    }
                    .rotationEffect(.degrees(-90)).frame(width: 60, height: geoHeight - 30)
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: .infinity)
                            .updating($isDetectingPress) { value, state, _ in state = value }
                    )
                    .highPriorityGesture(
                        TapGesture()
                            .onEnded { _ in
                                if fightLogic.makeMove(player: player, move: Move(source: fightLogic.getFighter(player: player), skill: skill)) {
                                    currentSection = .waiting
                                }
                    })
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
