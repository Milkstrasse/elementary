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
        var modifiers: [Float] = [Float](repeating: 0, count: fightLogic.gameLogic.fighterCounts[player.getOppositePlayerId()])
        let element: Element = GlobalData.shared.elements[spell.element.name] ?? Element()
        
        if fightLogic.singleMode {
            modifiers[0] = DamageCalculator.shared.getElementalModifier(attacker: player.getCurrentFighter(), defender: fightLogic.players[player.getOppositePlayerId()].getCurrentFighter(), spellElement: element, weather: fightLogic.weather)
        } else {
            for index in 0 ..< fightLogic.gameLogic.fighterCounts[player.getOppositePlayerId()] {
                if fightLogic.players[player.getOppositePlayerId()].getFighter(index: index).currhp > 0 {
                    modifiers[index] = DamageCalculator.shared.getElementalModifier(attacker: player.getCurrentFighter(), defender: fightLogic.players[player.getOppositePlayerId()].getFighter(index: index), spellElement: element, weather: fightLogic.weather)
                }
            }
            
            modifiers.sort(by: >)
        }
        
        switch modifiers[0] {
        case GlobalData.shared.elementalModifier * 2:
            return "superEffective"
        case GlobalData.shared.elementalModifier:
            return "veryEffective"
        case 1/GlobalData.shared.elementalModifier:
            return "notVeryEffective"
        case 1/(GlobalData.shared.elementalModifier * 2):
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
        if spell.typeID > 10 {
            return "\(spell.uses - spell.useCounter)/\(spell.uses)MP"
        } else {
            return "\(spell.uses - spell.useCounter)/\(spell.uses)MP - " + Localization.shared.getTranslation(key: getEffectiveness(spell: spell))
        }
    }
    
    var body: some View {
        ScrollViewReader { value in
            VStack(spacing: General.innerPadding/2) {
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
                                        let target: Int
                                        let targetedPlayer: Int
                                        if player.getCurrentFighter().singleSpells[index].range < 3 {
                                            target = player.currentFighterId
                                            targetedPlayer = player.id
                                        } else {
                                            target = fightLogic.players[player.getOppositePlayerId()].currentFighterId
                                            targetedPlayer = player.getOppositePlayerId()
                                        }
                                        
                                        if fightLogic.makeMove(player: player, move: Move(source: player.currentFighterId, index: -1, target: target, targetedPlayer: targetedPlayer, spell: index, type: MoveType.spell)) {
                                            AudioPlayer.shared.playConfirmSound()
                                            currentSection = Section.waiting
                                        } else {
                                            AudioPlayer.shared.playStandardSound()
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
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        let target: Int
                                        let targetedPlayer: Int
                                        if player.getCurrentFighter().multiSpells[index].range < 3 {
                                            target = player.currentFighterId
                                            targetedPlayer = player.id
                                        } else {
                                            target = fightLogic.players[player.getOppositePlayerId()].currentFighterId
                                            targetedPlayer = player.getOppositePlayerId()
                                        }
                                        
                                        if player.getCurrentFighter().multiSpells[index].range%2 != 0 {
                                            fightLogic.gameLogic.useSpell(player: player.id, fighter: player.currentFighterId, spell: index)
                                            currentSection = Section.targeting
                                        } else if fightLogic.makeMove(player: player, move: Move(source: player.currentFighterId, index: -1, target: target, targetedPlayer: targetedPlayer, spell: index, type: MoveType.spell)) {
                                            fightLogic.gameLogic.useSpell(player: player.id, fighter: player.currentFighterId, spell: index)
                                            
                                            if player.isAtLastFighter(index: player.currentFighterId) {
                                                AudioPlayer.shared.playConfirmSound()
                                                currentSection = Section.waiting
                                            } else {
                                                player.goToNextFighter()
                                                
                                                AudioPlayer.shared.playStandardSound()
                                                currentSection = Section.options
                                            }
                                        } else {
                                            AudioPlayer.shared.playStandardSound()
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
