//
//  SpellsView.swift
//  Magiko
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
    
    func getHexiveness(spellElement: String) -> String {
        if fightLogic.getWitch(player: player).ability.name == Abilities.ethereal.rawValue {
            return "Hexive"
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
                return "superHexive"
            case 2.0:
                return "veryHexive"
            case 0.5:
                return "notVeryHexive"
            case 0.25:
                return "Not Hexive"
            default:
                return "hexive"
        }
    }
    
    func generateDescription(spell: Spell, witch: Witch) -> String {
        return "\(spell.getUses(witch: witch) - spell.useCounter)/\(spell.getUses(witch: witch))PP - " + Localization.shared.getTranslation(key: getHexiveness(spellElement: spell.element.name))
    }
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(fightLogic.getWitch(player: player).spells, id: \.self) { spell in
                Button(action: {
                }) {
                    ZStack {
                        if isDetectingPress {
                            DetailedActionView(title: spell.name, description: spell.name + "Descr", symbol: spell.element.symbol, width: geoHeight - 30)
                        } else {
                            DetailedActionView(title: spell.name, description: generateDescription(spell: spell, witch: fightLogic.getWitch(player: player)), symbol: spell.element.symbol, width: geoHeight - 30)
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
                                if fightLogic.makeMove(player: player, move: Move(source: fightLogic.getWitch(player: player), spell: spell)) {
                                    AudioPlayer.shared.playConfirmSound()
                                    currentSection = .waiting
                                } else {
                                    AudioPlayer.shared.playStandardSound()
                                }
                    })
                }
                
            }
        }
    }
}

struct SpellsView_Previews: PreviewProvider {
    static var previews: some View {
        SpellsView(currentSection: .constant(.spells), fightLogic: FightLogic(leftWitches: [exampleWitch], rightWitches: [exampleWitch]), player: 0, geoHeight: 375)
    }
}
