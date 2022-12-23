//
//  SpellsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 23.08.22.
//

import SwiftUI

struct SpellsView: View {
    @Binding var currentSection: Section
    
    let fightLogic: FightLogic
    let player: Player
    
    @State var isDetectingPress: Bool = false
    @State var selectIndex: Int = -1
    
    /// Returns the effectiveness of a spell against the current opponent.
    /// - Parameter spellElement: The element of the spell
    /// - Returns: Returns the effectiveness of a spell against the current opponent
    func getEffectiveness(spell: Spell) -> String {
        var modifier: Float
        let element: Element = GlobalData.shared.elements[spell.element.name] ?? Element()
        
        if player.id == 0 {
            modifier = DamageCalculator.shared.getElementalModifier(attacker: fightLogic.players[0].getCurrentFighter(), defender: fightLogic.players[1].getCurrentFighter(), spellElement: element, weather: fightLogic.weather)
        } else {
            modifier = DamageCalculator.shared.getElementalModifier(attacker: fightLogic.players[1].getCurrentFighter(), defender: fightLogic.players[0].getCurrentFighter(), spellElement: element, weather: fightLogic.weather)
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
    
    /// Creates and returns a description fitting to a spell.
    /// - Parameters:
    ///   - spell: The spell in question
    ///   - fighter: The fighter with the spell
    /// - Returns: Returns a generated description for a spell
    func generateDescription(spell: Spell, fighter: Fighter) -> String {
        if spell.typeID > 9 {
            return "\(spell.uses - spell.useCounter)/\(spell.uses)MP"
        } else {
            return "\(spell.uses - spell.useCounter)/\(spell.uses)MP - " + Localization.shared.getTranslation(key: getEffectiveness(spell: spell))
        }
    }
    
    var body: some View {
        ScrollViewReader { value in
            VStack(spacing: innerPadding/2) {
                ForEach(player.getCurrentFighter().spells.indices, id: \.self) { index in
                    Button(action: {
                    }) {
                        ZStack {
                            if isDetectingPress && selectIndex == index {
                                SpellView(spell: player.getCurrentFighter().spells[index], desccription: Localization.shared.getTranslation(key: player.getCurrentFighter().spells[index].name + "Descr"))
                            } else {
                                SpellView(spell: player.getCurrentFighter().spells[index], desccription: generateDescription(spell: player.getCurrentFighter().spells[index], fighter: player.getCurrentFighter()))
                            }
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if selectIndex < 0 {
                                        selectIndex = index
                                    }
                                    
                                    isDetectingPress = true
                                }
                                .onEnded({ _ in
                                    selectIndex = -1
                                    
                                    isDetectingPress = false
                                })
                        )
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded { _ in
                                    if fightLogic.makeMove(player: player, move: Move(source: player.getCurrentFighter(), index: -1, spell: player.getCurrentFighter().spells[index], type: MoveType.spell)) {
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
        SpellsView(currentSection:Binding.constant(.spells), fightLogic: FightLogic(players: [Player(id: 0, fighters: [waterFighter]), Player(id: 1, fighters: [waterFighter])]), player: Player(id: 1, fighters: [waterFighter]))
    }
}
