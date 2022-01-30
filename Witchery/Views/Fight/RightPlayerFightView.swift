//
//  RightPlayerFightView.swift
//  Witchery
//
//  Created by Janice Hablützel on 04.01.22.
//

import Foundation
import SwiftUI

struct RightPlayerFightView: View {
    @ObservedObject var fightLogic: FightLogic
    @ObservedObject var player: Player
    
    let offsetX: CGFloat
    
    @State var currentSection: Section = .summary
    @Binding var gameOver: Bool
    
    @State var blink: Bool = false
    
    func calcWidth(witch: Witch) -> CGFloat {
        let percentage: CGFloat = CGFloat(witch.currhp)/CGFloat(witch.getModifiedBase().health)
        let width = round(170 * percentage)
        
        return width
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                ZStack(alignment: .bottomTrailing) {
                    if player.state == PlayerState.neutral {
                        Image(blink ? player.getCurrentWitch().name + "_blink" : player.getCurrentWitch().name).resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40 + offsetX, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(-90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    } else if player.state == PlayerState.healing {
                        Image(player.getCurrentWitch().name + "_happy").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(-90))
                    } else if player.state == PlayerState.hurting {
                        Image(player.getCurrentWitch().name + "_hurt").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(-90))
                    } else {
                        Image(player.getCurrentWitch().name + "_attacking").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(-90))
                    }
                    Rectangle().fill(Color("outline")).frame(width: 1).padding(.trailing, 175 + geometry.safeAreaInsets.trailing).offset(x: geometry.safeAreaInsets.trailing)
                    Rectangle().fill(Color("background")).frame(width: 175 + geometry.safeAreaInsets.trailing).offset(x: geometry.safeAreaInsets.trailing)
                    HStack(spacing: 10) {
                        ZStack(alignment: .trailing) {
                            VStack(alignment: .trailing) {
                                ZStack(alignment: .bottomLeading) {
                                    HStack(spacing: 0) {
                                        Triangle().fill(Color("outline")).frame(width: 21, height: 57)
                                        Rectangle().fill(Color("outline")).frame(width: 190, height: 57)
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
                                            Triangle().fill(Color("button")).frame(width: 20, height: 55)
                                            ZStack(alignment: .topTrailing) {
                                                Rectangle().fill(Color("button")).frame(width: 190)
                                                HStack(spacing: 5) {
                                                    ForEach(player.getCurrentWitch().hexes, id: \.self) { hex in
                                                        HexView(hex: hex, battling: fightLogic.battling)
                                                    }
                                                    if fightLogic.weather != nil {
                                                        HexView(hex: fightLogic.weather!, battling: fightLogic.battling, weather: true)
                                                    }
                                                }
                                                .offset(x: -12, y: -12)
                                                VStack(spacing: 0) {
                                                    HStack {
                                                        CustomText(key: player.getCurrentWitch().name, fontSize: 16).lineLimit(1)
                                                        Spacer()
                                                        CustomText(text: Localization.shared.getTranslation(key: "hpBar", params: ["\(player.getCurrentWitch().currhp)", "\(player.getCurrentWitch().getModifiedBase().health)"]), fontSize: 13)
                                                    }
                                                    ZStack(alignment: .leading) {
                                                        Rectangle().fill(Color("outline")).frame(height: 6)
                                                        Rectangle().fill(Color("health")).frame(width: calcWidth(witch: player.getCurrentWitch()), height: 6).animation(.default, value: player.getCurrentWitch().currhp)
                                                    }
                                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                                }
                                                .padding(.trailing, 15).padding(.leading, 5).frame(height: 55)
                                            }
                                        }
                                        .frame(height: 55)
                                    }
                                    .frame(height: 75)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 75, height: 210).offset(y: offsetX).animation(.easeOut(duration: 0.3).delay(0.1), value: offsetX)
                                Spacer()
                            }
                            VStack(alignment: .trailing) {
                                Spacer()
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
                                    .buttonStyle(ClearButton(width: 100, height: 35))
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 35, height: 100).opacity(fightLogic.battling ? 0.7 : 1.0).disabled(fightLogic.battling)
                            }
                            .padding(.bottom, 15)
                        }
                        Group {
                            if currentSection == .summary {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: geometry.size.height - 30, height: 115)
                                    RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: geometry.size.height - 30, height: 115)
                                    ScrollView(.vertical, showsIndicators: false) {
                                        CustomText(text: fightLogic.battleLog, fontSize: 13).frame(width: geometry.size.height - 60, alignment: .leading)
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
                                    RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: geometry.size.height - 30, height: 115)
                                    CustomText(key: "waiting", fontSize: 13).frame(width: geometry.size.height - 60, height: 85, alignment: .topLeading).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
                            }
                        }
                        .padding(.trailing, 15)
                    }
                }
            }
            .frame(width: geometry.size.width)
            .onReceive(fightLogic.$battling, perform: { battling in
                if battling {
                    currentSection = .summary
                }
            })
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + CGFloat.random(in: 0.0 ..< 1.0)) {
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                    blink = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        blink = false
                    }
                }
            }
        }
    }
}

struct RightPlayerFightView_Previews: PreviewProvider {
    static var previews: some View {
        RightPlayerFightView(fightLogic: FightLogic(players: [Player(id: 0, witches: [exampleWitch]), Player(id: 1, witches: [exampleWitch])]), player: Player(id: 1, witches: [exampleWitch]), offsetX: 0, gameOver: .constant(false))
            .ignoresSafeArea(.all, edges: .bottom)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
