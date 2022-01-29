//
//  SpellsView.swift
//  Witchery
//
//  Created by Janice Hablützel on 07.01.22.
//

import SwiftUI

struct SpellsView: View {
    @Binding var currentSection: Section
    
    let fightLogic: FightLogic
    let player: Int
    
    let geoHeight: CGFloat
    
    @State var gestureStates: [Bool] = []
    @GestureState var isDetectingPress = false
    
    func getEffectiveness(spellElement: String) -> String {
        if fightLogic.getWitch(player: player).ability.name == Abilities.ethereal.rawValue {
            return "effective"
        }
        
        var modifier: Float
        let element: Element = GlobalData.shared.elements[spellElement] ?? Element()
        
        if player == 0 {
            modifier = DamageCalculator.shared.getElementalModifier(attacker: fightLogic.getWitch(player: 0), defender: fightLogic.getWitch(player: 1), spellElement: element)
        } else {
            modifier = DamageCalculator.shared.getElementalModifier(attacker: fightLogic.getWitch(player: 1), defender: fightLogic.getWitch(player: 0), spellElement: element)
        }
        
        switch modifier {
            case 4.0:
                return "superEffective"
            case 2.0:
                return "veryEffective"
            case 0.5:
                return "notVeryEffective"
            case 0.25:
                return "notEffective"
            default:
                return "effective"
        }
    }
    
    func generateDescription(spell: Spell, witch: Witch) -> String {
        return "\(spell.uses - spell.useCounter)/\(spell.uses)PP - " + Localization.shared.getTranslation(key: getEffectiveness(spellElement: spell.element.name))
    }
    
    var body: some View {
        ScrollViewReader { value in
            HStack(spacing: 5) {
                ForEach(fightLogic.getWitch(player: player).spells.indices) { index in
                    Button(action: {
                    }) {
                        ZStack {
                            if isDetectingPress {
                                DetailedActionView(title: fightLogic.getWitch(player: player).spells[index].name, description: fightLogic.getWitch(player: player).spells[index].name + "Descr", symbol: fightLogic.getWitch(player: player).spells[index].element.symbol, width: geoHeight - 30)
                            } else {
                                DetailedActionView(title: fightLogic.getWitch(player: player).spells[index].name, description: generateDescription(spell: fightLogic.getWitch(player: player).spells[index], witch: fightLogic.getWitch(player: player)), symbol: fightLogic.getWitch(player: player).spells[index].element.symbol, width: geoHeight - 30)
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
                                    if fightLogic.makeMove(player: player, move: Move(source: fightLogic.getWitch(player: player), spell: fightLogic.getWitch(player: player).spells[index])) {
                                        AudioPlayer.shared.playConfirmSound()
                                        currentSection = .waiting
                                    } else {
                                        AudioPlayer.shared.playStandardSound()
                                    }
                        })
                    }
                    .id(index)
                }
            }
            .onAppear {
                value.scrollTo(0)
            }
        }
    }
}

struct SpellsView_Previews: PreviewProvider {
    static var previews: some View {
        SpellsView(currentSection: .constant(.spells), fightLogic: FightLogic(leftWitches: [exampleWitch], rightWitches: [exampleWitch]), player: 0, geoHeight: 375)
    }
}
