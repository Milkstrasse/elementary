//
//  PlayerFightView.swift
//  Witchery
//
//  Created by Janice Hablützel on 04.01.22.
//

import SwiftUI

struct PlayerFightView: View {
    @ObservedObject var fightLogic: FightLogic
    @ObservedObject var player: Player
    
    let offsetX: CGFloat
    
    @State var currentSection: Section = .summary
    @Binding var gameOver: Bool
    
    @State var blink: Bool = false
    @State var stopBlinking: Bool = false
    
    let isInteractable: Bool
    
    /// Calculates the width of a witch's health bar.
    /// - Parameter witch: The current witch
    /// - Returns: Returns the width of the health bar
    func calcWidth(witch: Witch) -> CGFloat {
        let percentage: CGFloat = CGFloat(witch.currhp)/CGFloat(witch.getModifiedBase().health)
        let width = round(170 * percentage)
        
        return width
    }
    
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
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ZStack(alignment: .topLeading) {
                    if player.state == PlayerState.neutral {
                        Image(fileName: blink ? player.getCurrentWitch().name + "_blink" : player.getCurrentWitch().name).resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40 + offsetX, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    } else if player.state == PlayerState.healing {
                        Image(fileName: player.getCurrentWitch().name + "_happy").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90))
                    } else if player.state == PlayerState.hurting {
                        Image(fileName: player.getCurrentWitch().name + "_hurt").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90))
                    } else {
                        Image(fileName: player.getCurrentWitch().name + "_attack").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90))
                    }
                    Rectangle().fill(Color("panel")).frame(width: 175 + (player.id == 0 ? geometry.safeAreaInsets.leading : geometry.safeAreaInsets.trailing)).offset(x: player.id == 0 ? -geometry.safeAreaInsets.leading : -geometry.safeAreaInsets.trailing)
                    HStack(spacing: 10) {
                        Group {
                            if currentSection == .summary {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: geometry.size.height - 30, height: 115)
                                    ScrollView(.vertical, showsIndicators: false) {
                                        ScrollViewReader { value in
                                            ForEach(fightLogic.battleLog.indices, id: \.self) { index in
                                                CustomText(text: fightLogic.battleLog[index], fontSize: smallFontSize).frame(width: geometry.size.height - 60, alignment: .leading).id(index)
                                                    .onAppear {
                                                        value.scrollTo(index, anchor: .bottom)
                                                    }
                                            }
                                        }
                                    }
                                    .frame(height: 85).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
                            } else if currentSection != .waiting {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 5) {
                                        if currentSection == .options {
                                            OptionsView(currentSection: $currentSection, gameOver: $gameOver, fightLogic: fightLogic, player: player, geoHeight: geometry.size.height)
                                        } else if currentSection == .spells {
                                            SpellsView(currentSection: $currentSection, fightLogic: fightLogic, player: player, geoHeight: geometry.size.height)
                                        } else if currentSection == .team {
                                            TeamView(currentSection: $currentSection, fightLogic: fightLogic, player: player, geoHeight: geometry.size.height)
                                        }
                                    }
                                }
                                .padding(.vertical, 15).frame(width: 115, height: geometry.size.height - 30)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: geometry.size.height - 30, height: 115)
                                    CustomText(key: "waiting", fontSize: smallFontSize).frame(width: geometry.size.height - 60, height: 85, alignment: .topLeading).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
                            }
                        }
                        .padding(.trailing, 15).rotationEffect(.degrees(180))
                        ZStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Spacer()
                                ZStack(alignment: .bottomLeading) {
                                    HStack(spacing: 0) {
                                        Triangle().fill(Color("outline")).frame(width: 21, height: 52)
                                        Rectangle().fill(Color("outline")).frame(width: 190, height: 52)
                                    }
                                    .padding(.bottom, 4).offset(x: -1).frame(width: 210)
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(spacing: 5) {
                                            ForEach(player.witches.indices) { index in
                                                Circle().fill(Color("outline")).frame(width: 10, height: 10).opacity(player.witches[index].currhp == 0 ? 0.5 : 1)
                                            }
                                        }
                                        .padding(.leading, 24).offset(y: -5)
                                        HStack(spacing: 0) {
                                            Triangle().fill(Color("outline")).frame(width: 20, height: 50)
                                            ZStack(alignment: .topTrailing) {
                                                Rectangle().fill(Color("outline")).frame(width: 190)
                                                HStack(spacing: 5) {
                                                    ForEach(player.getCurrentWitch().hexes, id: \.self) { hex in
                                                        HexView(hex: hex)
                                                    }
                                                    if fightLogic.weather != nil {
                                                        HexView(hex: fightLogic.weather!, weather: true)
                                                    }
                                                }
                                                .offset(x: -12, y: -12)
                                                VStack(spacing: 0) {
                                                    HStack {
                                                        CustomText(key: player.getCurrentWitch().name, fontColor: Color("background"), fontSize: mediumFontSize, isBold: true)
                                                        Spacer()
                                                        CustomText(text: Localization.shared.getTranslation(key: "hpBar", params: ["\(player.getCurrentWitch().currhp)", "\(player.getCurrentWitch().getModifiedBase().health)"]), fontColor: Color("background"), fontSize: tinyFontSize)
                                                    }
                                                    ZStack(alignment: .leading) {
                                                        Rectangle().fill(Color("healthbar")).frame(height: 6)
                                                        Rectangle().fill(Color("health")).frame(width: calcWidth(witch: player.getCurrentWitch()), height: 6).animation(.default, value: player.getCurrentWitch().currhp)
                                                    }
                                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                                }
                                                .padding(.trailing, 15).padding(.leading, 5).frame(height: 50)
                                            }
                                        }
                                        .frame(height: 50)
                                    }
                                    .frame(height: 70)
                                }
                                .rotationEffect(.degrees(90)).frame(width: 70, height: 210).offset(y: -offsetX).animation(.easeOut(duration: 0.3).delay(0.1), value: offsetX)
                            }
                            VStack(alignment: .leading) {
                                ZStack {
                                    Button(currentSection == .summary ? Localization.shared.getTranslation(key: "next") : Localization.shared.getTranslation(key: "back")) {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if fightLogic.isGameOver() {
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
                                    }
                                    .buttonStyle(ClearButton(width: 100, height: 35)).disabled(!isInteractable)
                                }
                                .rotationEffect(.degrees(90)).frame(width: 35, height: 100).opacity(fightLogic.battling ? 0.7 : 1.0).disabled(fightLogic.battling)
                                Spacer()                            }
                            .padding(.top, 15)
                        }
                    }
                }
                Spacer()
            }
            .frame(width: geometry.size.width)
            .rotationEffect(.degrees(player.id == 0 ? 0 : 180))
            .onReceive(fightLogic.$battling, perform: { battling in
                if battling {
                    currentSection = .summary
                }
            })
        }
        .onAppear {
            let blinkInterval: Int = Int.random(in: 5 ... 10)
            blink(delay: TimeInterval(blinkInterval))
        }
        .onDisappear {
            stopBlinking = true
        }
    }
}

struct PlayerFightView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerFightView(fightLogic: FightLogic(players: [Player(id: 0, witches: [exampleWitch]), Player(id: 1, witches: [exampleWitch])]), player: Player(id: 1, witches: [exampleWitch]), offsetX: 0, gameOver:Binding.constant(false), isInteractable: true).ignoresSafeArea(.all, edges: .bottom)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
