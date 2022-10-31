//
//  PlayerFightView.swift
//  Elementary
//
//  Created by Janice Hablützel on 23.08.22.
//

import SwiftUI

struct PlayerFightView: View {
    @ObservedObject var fightLogic: FightLogic
    @ObservedObject var player: Player
    
    @State var currentSection: Section = .summary
    @Binding var gameOver: Bool
    @State var isGameOver: Bool = false
    @Binding var fightOver: Bool
    
    @State var offset: CGFloat = 150
    
    @State var blink: Bool = false
    @State var stopBlinking: Bool = false
    
    let isInteractable: Bool
    
    @State var winner: Int = -1
    
    /// Sends signal to blink.
    /// - Parameter delay: The delay between blinks
    func blink(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            blink = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                blink = false
                
                if !stopBlinking {
                    let blinkInterval: Int = Int.random(in: 5 ... 10)
                    blink(delay: TimeInterval(blinkInterval))
                }
            }
        }
    }
    
    /// Calculates the width of a fighter's health bar.
    /// - Parameter fighter: The current fighter
    /// - Returns: Returns the width of the health bar
    func calcWidth(fighter: Fighter) -> CGFloat {
        let percentage: CGFloat = CGFloat(fighter.currhp)/CGFloat(fighter.getModifiedBase().health)
        let width = round(175 * percentage)
        
        return width
    }
    
    /// Changes color of health bar depending on the current health of a fight.
    /// - Returns: Returns color for the health bar
    func getHealthColor() -> Color {
        let ratio: Float = Float(player.getCurrentFighter().currhp)/Float(player.getCurrentFighter().getModifiedBase().health)
        
        if ratio > 0.1 { //more than 10% health left
            return Color("Positive")
        } else {
            return Color("Negative")
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Group {
                    if player.state == PlayerState.neutral {
                        Image(fileName: blink ? player.getCurrentFighter().name + "_blink" : player.getCurrentFighter().name).resizable()
                    } else if player.state == PlayerState.healing {
                        Image(fileName: player.getCurrentFighter().name + "_happy").resizable()
                    } else if player.state == PlayerState.hurting {
                        Image(fileName: player.getCurrentFighter().name + "_hurt").resizable()
                    } else {
                        Image(fileName: player.getCurrentFighter().name + "_attack").resizable()
                    }
                }
                .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6).shadow(radius: 5, x: 5, y: 0).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).offset(x: -45 - offset, y: (geometry.size.width * 0.6 - 175)/2 * -1 - 175).animation(.linear(duration: 0.3).delay(0.2), value: offset)
                Rectangle().fill(Color("Panel")).frame(height: 175)
                VStack(spacing: outerPadding) {
                    HStack {
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            if gameOver {
                                fightOver = true
                            } else if fightLogic.isGameOver() {
                                gameOver = true
                            } else {
                                if currentSection == .options {
                                    currentSection = .summary
                                } else {
                                    if currentSection == .waiting {
                                        fightLogic.undoMove(player: player)
                                    }
                                    currentSection = .options
                                }
                            }
                        }) {
                            ClearButton(label: currentSection == .summary || gameOver ? Localization.shared.getTranslation(key: "next") : Localization.shared.getTranslation(key: "back"), width: geometry.size.width - 30 - 210, height: 50).padding(.leading, outerPadding).offset(y: 6)
                        }
                        .disabled(!isInteractable).opacity(fightLogic.fighting ? 0.5 : 1.0).disabled(fightLogic.fighting)
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color.white).frame(width: 210, height: 50).shadow(radius: 5, x: 5, y: 0)
                            VStack(spacing: 2) {
                                HStack(alignment: .top, spacing: 4) {
                                    ForEach(player.fighters.indices, id: \.self) { index in
                                        Circle().fill(Color.white).frame(width: 10, height: 10).opacity(player.fighters[index].currhp == 0 ? 0.5 : 1).offset(y: -2)
                                    }
                                    Spacer().frame(height: 24)
                                    ForEach(player.getCurrentFighter().hexes, id: \.self) { hex in
                                        HexView(hex: hex)
                                    }
                                    if fightLogic.weather != nil {
                                        HexView(hex: fightLogic.weather!, weather: true)
                                    }
                                }
                                HStack(alignment: .bottom) {
                                    CustomText(text: Localization.shared.getTranslation(key: player.getCurrentFighter().name).uppercased(), fontColor: Color("Panel"), fontSize: mediumFont, isBold: true)
                                    Spacer()
                                    CustomText(text: Localization.shared.getTranslation(key: "hpBar", params: ["\(player.getCurrentFighter().currhp)", "\(player.getCurrentFighter().getModifiedBase().health)"]), fontColor: Color("Panel"), fontSize: smallFont)
                                }
                                ZStack(alignment: .leading) {
                                    Rectangle().fill(Color("Border1")).frame(height: 6)
                                    Rectangle().fill(getHealthColor()).frame(width: calcWidth(fighter: player.getCurrentFighter()), height: 6).animation(.default, value: player.getCurrentFighter().currhp)
                                }
                            }
                            .frame(width: 195 - outerPadding - innerPadding/2).padding(.leading, innerPadding/2).padding(.trailing, outerPadding).padding(.top, -20)
                        }
                        .offset(x: offset).animation(.linear(duration: 0.3), value: offset)
                    }
                    .padding(.top, -25)
                    Group {
                        if isGameOver {
                            ZStack(alignment: .topLeading) {
                                Rectangle().fill(Color("Panel")) .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                CustomText(text: Localization.shared.getTranslation(key: winner == player.id ? "winner" : "loser").uppercased(), fontSize: smallFont).padding(.all, outerPadding)
                            }
                            .padding([.leading, .bottom, .trailing], outerPadding)
                        } else if currentSection == .summary {
                            ZStack {
                                Rectangle().fill(Color("Panel")) .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                ScrollView(.vertical, showsIndicators: false) {
                                    ScrollViewReader { value in
                                        ForEach(fightLogic.fightLog.indices, id: \.self) { index in
                                            CustomText(text: fightLogic.fightLog[index], fontSize: smallFont).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, innerPadding).id(index)
                                                .onAppear {
                                                    value.scrollTo(index, anchor: .bottom)
                                                }
                                        }
                                    }
                                }
                                .padding(.vertical, innerPadding)
                            }
                            .padding([.leading, .bottom, .trailing], outerPadding)
                        } else if currentSection != .waiting {
                            ScrollView(.vertical, showsIndicators: false) {
                                Group {
                                    if currentSection == .options {
                                        OptionsView(currentSection: $currentSection, gameOver: $gameOver, fightLogic: fightLogic, player: player)
                                    } else if currentSection == .spells {
                                        SpellsView(currentSection: $currentSection, fightLogic: fightLogic, player: player)
                                    } else if currentSection == .team {
                                        TeamView(currentSection: $currentSection, fightLogic: fightLogic, player: player)
                                    } else {
                                        InfoView(fightLogic: fightLogic, player: player)
                                    }
                                }
                                .frame(width: geometry.size.width - 30).padding(.horizontal, outerPadding)
                            }
                            .padding(.bottom, outerPadding)
                        } else {
                            ZStack(alignment: .topLeading) {
                                Rectangle().fill(Color("Panel")) .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                CustomText(text: Localization.shared.getTranslation(key: "waiting"), fontSize: smallFont).padding(.all, outerPadding)
                            }
                            .padding([.leading, .bottom, .trailing], outerPadding)
                        }
                    }
                }
                .frame(height: 175)
            }
            .frame(height: 175)
            .onReceive(fightLogic.$fighting, perform: { fighting in
                if fighting {
                    currentSection = .summary
                }
            })
            .onChange(of: gameOver) { _ in
                winner = fightLogic.getWinner()
                isGameOver = gameOver
            }
        }
        .frame(height: 175)
        .onAppear {
            let blinkInterval: Int = Int.random(in: 5 ... 10)
            blink(delay: TimeInterval(blinkInterval))
            
            offset = 0
        }
        .onDisappear {
            stopBlinking = true
        }
    }
}

struct PlayerFightView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            PlayerFightView(fightLogic: FightLogic(players: [Player(id: 0, fighters: [exampleFighter]), Player(id: 1, fighters: [exampleFighter])]), player: Player(id: 1, fighters: [exampleFighter]), gameOver: Binding.constant(false), isGameOver: false, fightOver: Binding.constant(false), isInteractable: true)
        }
    }
}
