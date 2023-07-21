//
//  TargetView.swift
//  Elementary
//
//  Created by Janice Hablützel on 06.01.23.
//

import SwiftUI

struct TargetView: View {
    @Binding var currentSection: Section
    
    var fightLogic: FightLogic
    var player: Player
    
    @State var target: Int = 0
    
    /// Returns the effectiveness of a spell against the current opponent.
    /// - Parameters:
    ///   - fighter: The targeted fighter
    ///   - spellIndex: The index of the intended spell
    /// - Returns: Returns the effectiveness of a spell against the opponent
    func getEffectiveness(fighter: Fighter, spellIndex: Int) -> String {
        let modifier: Float
        
        if spellIndex >= 0 {
            modifier = DamageCalculator.shared.getElementalModifier(attacker: player.getCurrentFighter(), defender: fighter, spellElement: player.getCurrentFighter().multiSpells[spellIndex].element, weather: fightLogic.weather)
        } else {
            modifier = 1
        }
        
        switch modifier {
        case GlobalData.shared.elementalModifier * 2:
            return Localization.shared.getTranslation(key: "superEffective")
        case GlobalData.shared.elementalModifier:
            return Localization.shared.getTranslation(key: "veryEffective")
        case 1/GlobalData.shared.elementalModifier:
            return Localization.shared.getTranslation(key: "notVeryEffective")
        case 1/(GlobalData.shared.elementalModifier * 2):
            return Localization.shared.getTranslation(key: "notEffective")
        default:
            return Localization.shared.getTranslation(key: "effective")
        }
    }
    
    /// Generates and returns info on a fighter.
    /// - Parameter fighter: The targeted fighter
    /// - Returns: Returns generated info on a fighter
    func generateInfo(fighter: Fighter) -> String {
        let spellIndex: Int = fightLogic.gameLogic.tempSpells[player.currentFighterId + player.id * fightLogic.gameLogic.fighterCounts[0]]
        
        if spellIndex >= 0 && player.getCurrentFighter().multiSpells[spellIndex].typeID > 10 {
            return Localization.shared.getTranslation(key: "hpBar", params: ["\(fighter.currhp)", "\(fighter.getModifiedBase().health)"])
        } else {
            return Localization.shared.getTranslation(key: "hpBar", params: ["\(fighter.currhp)", "\(fighter.getModifiedBase().health)"]) + " - " + getEffectiveness(fighter: fighter, spellIndex: spellIndex)
        }
    }
    
    var body: some View {
        ScrollViewReader { value in
            VStack(spacing: General.innerPadding/2) {
                ForEach(fightLogic.players[target].fighters.indices, id: \.self) { index in
                    Button(action: {
                        if fightLogic.makeMove(player: player, move: Move(source: player.currentFighterId, index: -1, target: index, targetedPlayer: target, spell: fightLogic.gameLogic.tempSpells[player.currentFighterId + player.id * fightLogic.gameLogic.fighterCounts[0]], type: MoveType.spell)) {
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
                            currentSection = Section.options
                        }
                    }) {
                        ActionView(titleKey: fightLogic.players[target].getFighter(index: index).name, description: generateInfo(fighter: fightLogic.players[target].getFighter(index: index)), symbol: fightLogic.players[target].getFighter(index: index).getElement().symbol, color: Color(hex: fightLogic.players[target].getFighter(index: index).getElement().color))
                    }
                    .id(index).opacity(fightLogic.players[target].getFighter(index: index).currhp == 0 ? 0.5 : 1.0).disabled(fightLogic.players[target].getFighter(index: index).currhp == 0)
                }
                if fightLogic.gameLogic.tempSpells[player.currentFighterId + player.id * fightLogic.gameLogic.fighterCounts[0]] > -1 && player.getCurrentFighter().multiSpells[fightLogic.gameLogic.tempSpells[player.currentFighterId + player.id * fightLogic.gameLogic.fighterCounts[0]]].range == 5 {
                    ForEach(player.fighters.indices, id: \.self) { index in
                        Button(action: {
                            if fightLogic.makeMove(player: player, move: Move(source: player.currentFighterId, index: -1, target: index, targetedPlayer: player.id, spell: fightLogic.gameLogic.tempSpells[player.currentFighterId + player.id * fightLogic.gameLogic.fighterCounts[0]], type: MoveType.spell)) {
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
                                currentSection = Section.options
                            }
                        }) {
                            ActionView(titleKey: player.getFighter(index: index).name, description: generateInfo(fighter: player.getFighter(index: index)), symbol: player.getFighter(index: index).getElement().symbol, color: Color(hex: player.getFighter(index: index).getElement().color))
                        }
                        .opacity(player.getFighter(index: index).currhp == 0 ? 0.5 : 1.0).disabled(player.getFighter(index: index).currhp == 0)
                    }
                }
            }
            .onAppear {
                if player.getCurrentFighter().multiSpells[fightLogic.gameLogic.tempSpells[player.currentFighterId + player.id * fightLogic.gameLogic.fighterCounts[0]]].range < 3 {
                    target = player.id
                } else {
                    target = player.getOppositePlayerId()
                }
                
                value.scrollTo(0)
            }
        }
    }
}

struct TargetView_Previews: PreviewProvider {
    static var previews: some View {
        TargetView(currentSection: Binding.constant(Section.team), fightLogic: FightLogic(players: [Player(id: 0, fighters: [GlobalData.shared.fighters[0]]), Player(id: 1, fighters: [GlobalData.shared.fighters[0]])], hasCPUPlayer: false, singleMode: true), player: Player(id: 0, fighters: [GlobalData.shared.fighters[0]]))
    }
}
