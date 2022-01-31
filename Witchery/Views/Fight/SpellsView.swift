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
    let player: Player
    
    let geoHeight: CGFloat
    
    @State var gestureStates: [Bool] = []
    @GestureState var isDetectingPress = false
    
    func getEffectiveness(spellElement: String) -> String {
        if player.getCurrentWitch().artifact.name == Artifacts.ring.rawValue {
            return "effective"
        }
        
        var modifier: Float
        let element: Element = GlobalData.shared.elements[spellElement] ?? Element()
        
        if player.id == 0 {
            modifier = DamageCalculator.shared.getElementalModifier(attacker: fightLogic.players[0].getCurrentWitch(), defender: fightLogic.players[1].getCurrentWitch(), spellElement: element)
        } else {
            modifier = DamageCalculator.shared.getElementalModifier(attacker: fightLogic.players[1].getCurrentWitch(), defender: fightLogic.players[0].getCurrentWitch(), spellElement: element)
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
        return "\(spell.uses - spell.useCounter)/\(spell.uses)MP - " + Localization.shared.getTranslation(key: getEffectiveness(spellElement: spell.element.name))
    }
    
    var body: some View {
        ScrollViewReader { value in
            HStack(spacing: 5) {
                ForEach(player.getCurrentWitch().spells.indices) { index in
                    Button(action: {
                    }) {
                        ZStack {
                            if isDetectingPress {
                                DetailedActionView(title: player.getCurrentWitch().spells[index].name, description: player.getCurrentWitch().spells[index].name + "Descr", symbol: player.getCurrentWitch().spells[index].element.symbol, width: geoHeight - 30)
                            } else {
                                DetailedActionView(title: player.getCurrentWitch().spells[index].name, description: generateDescription(spell: player.getCurrentWitch().spells[index], witch: player.getCurrentWitch()), symbol: player.getCurrentWitch().spells[index].element.symbol, width: geoHeight - 30)
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
                                    if fightLogic.makeMove(player: player, move: Move(source: player.getCurrentWitch(), spell: player.getCurrentWitch().spells[index])) {
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
        SpellsView(currentSection: .constant(.spells), fightLogic: FightLogic(players: [Player(id: 0, witches: [exampleWitch]), Player(id: 1, witches: [exampleWitch])]), player: Player(id: 1, witches: [exampleWitch]), geoHeight: 375)
    }
}
