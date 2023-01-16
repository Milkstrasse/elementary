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
        var modifiers: [Float] = [Float](repeating: 0, count: fightLogic.gameLogic.fullAmount/2)
        let element: Element = GlobalData.shared.elements[spell.element.name] ?? Element()
        
        if fightLogic.singleMode {
            modifiers[0] = DamageCalculator.shared.getElementalModifier(attacker: player.getCurrentFighter(), defender: fightLogic.players[player.id == 0 ? 1 : 0].getCurrentFighter(), spellElement: element, weather: fightLogic.weather)
        } else {
            for index in 0 ..< fightLogic.gameLogic.fullAmount/2 {
                if fightLogic.players[player.id == 0 ? 1 : 0].fighters[index].currhp > 0 {
                    modifiers[index] = DamageCalculator.shared.getElementalModifier(attacker: player.getCurrentFighter(), defender: fightLogic.players[player.id == 0 ? 1 : 0].fighters[index], spellElement: element, weather: fightLogic.weather)
                }
            }
            
            modifiers.sort(by: >)
        }
        
        switch modifiers[0] {
        case GlobalData.shared.elementalModifier * 2:
            return "superEffective"
        case GlobalData.shared.elementalModifier:
            return "veryEffective"
        case 1:
            return "effective"
        case 1/GlobalData.shared.elementalModifier:
            return "notVeryEffective"
        case 1/(GlobalData.shared.elementalModifier * 2):
            return "notEffective"
        default:
            return "ineffective"
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
                if fightLogic.singleMode {
                    ForEach(player.getCurrentFighter().singleSpells.indices, id: \.self) { index in
                        Button(action: {
                        }) {
                            ZStack {
                                if isDetectingPress && selectIndex == index {
                                    SpellView(spell: player.getCurrentFighter().singleSpells[index], desccription: Localization.shared.getTranslation(key: player.getCurrentFighter().singleSpells[index].name + "Descr"))
                                } else {
                                    SpellView(spell: player.getCurrentFighter().singleSpells[index], desccription: generateDescription(spell: player.getCurrentFighter().singleSpells[index], fighter: player.getCurrentFighter()))
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
                                        if fightLogic.singleMode {
                                            let target: Fighter
                                            if player.getCurrentFighter().singleSpells[index].subSpells[0].range == 0 {
                                                target = player.getCurrentFighter()
                                            } else if player.id == 0 {
                                                target = fightLogic.players[1].getCurrentFighter()
                                            } else {
                                                target = fightLogic.players[0].getCurrentFighter()
                                            }
                                            
                                            if fightLogic.makeMove(player: player, move: Move(source: player.getCurrentFighter(), index: -1, target: target, spell: index, type: MoveType.spell)) {
                                                AudioPlayer.shared.playConfirmSound()
                                                currentSection = Section.waiting
                                            } else {
                                                AudioPlayer.shared.playStandardSound()
                                            }
                                        } else {
                                            AudioPlayer.shared.playStandardSound()
                                            fightLogic.gameLogic.useSpell(player: player.id, fighter: player.currentFighterId, spell: index)
                                            currentSection = Section.targeting
                                        }
                                    })
                        }
                        .id(index)
                    }
                } else {
                    ForEach(player.getCurrentFighter().multiSpells.indices, id: \.self) { index in
                        Button(action: {
                        }) {
                            ZStack {
                                if isDetectingPress && selectIndex == index {
                                    SpellView(spell: player.getCurrentFighter().multiSpells[index], desccription: Localization.shared.getTranslation(key: player.getCurrentFighter().multiSpells[index].name + "Descr"))
                                } else {
                                    SpellView(spell: player.getCurrentFighter().multiSpells[index], desccription: generateDescription(spell: player.getCurrentFighter().multiSpells[index], fighter: player.getCurrentFighter()))
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
                                        if fightLogic.singleMode {
                                            let target: Fighter
                                            if player.getCurrentFighter().multiSpells[index].subSpells[0].range == 0 {
                                                target = player.getCurrentFighter()
                                            } else if player.id == 0 {
                                                target = fightLogic.players[1].getCurrentFighter()
                                            } else {
                                                target = fightLogic.players[0].getCurrentFighter()
                                            }
                                            
                                            if fightLogic.makeMove(player: player, move: Move(source: player.getCurrentFighter(), index: -1, target: target, spell: index, type: MoveType.spell)) {
                                                AudioPlayer.shared.playConfirmSound()
                                                currentSection = Section.waiting
                                            } else {
                                                AudioPlayer.shared.playStandardSound()
                                            }
                                        } else {
                                            AudioPlayer.shared.playStandardSound()
                                            fightLogic.gameLogic.useSpell(player: player.id, fighter: player.currentFighterId, spell: index)
                                            currentSection = Section.targeting
                                        }
                                    })
                        }
                        .id(index)
                    }
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
        SpellsView(currentSection: Binding.constant(Section.spells), fightLogic: FightLogic(players: [Player(id: 0, fighters: [GlobalData.shared.fighters[0]]), Player(id: 1, fighters: [GlobalData.shared.fighters[0]])], hasCPUPlayer: false, singleMode: true), player: Player(id: 1, fighters: [GlobalData.shared.fighters[0]]))
    }
}
