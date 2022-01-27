//
//  LeftPlayerFightView.swift
//  Magiko
//
//  Created by Janice Hablützel on 04.01.22.
//

import SwiftUI

struct LeftPlayerFightView: View {
    @ObservedObject var fightLogic: FightLogic
    
    let offsetX: CGFloat
    
    @State var currentSection: Section = .summary
    @Binding var gameOver: Bool
    
    @State var currentHealth: Int = 0
    @State var hurting: Bool = false
    @State var healing: Bool = false
    
    @State var blink: Bool = false
    
    func calcWidth(fighter: Fighter) -> CGFloat {
        DispatchQueue.main.async {
            let newHealth = fightLogic.getFighter(player: 0).currhp
            
            if currentHealth > newHealth {
                hurting = true
            } else if currentHealth < newHealth && currentHealth > 0 {
                healing = true
            }
            
            currentHealth = newHealth
        }
        
        let percentage: CGFloat = CGFloat(fighter.currhp)/CGFloat(fighter.getModifiedBase().health)
        let width = round(170 * percentage)
        
        return width
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ZStack(alignment: .topLeading) {
                    if !hurting && !healing {
                        Image(blink ? fightLogic.getFighter(player: 0).name + "_blink" : fightLogic.getFighter(player: 0).name).resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40 + offsetX, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    } else if healing {
                        Image(fightLogic.getFighter(player: 0).name + "_happy").resizable().scaleEffect(healing ? 1.2 : 1.1).animation(.easeInOut, value: healing).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    healing = false
                                }
                            }
                    } else {
                        Image(fightLogic.getFighter(player: 0).name + "_hurt").resizable().scaleEffect(hurting ? 1.2 : 1.1).animation(.easeInOut, value: hurting).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    hurting = false
                                }
                            }
                    }
                    Rectangle().fill(Color("outline")).frame(width: 1).padding(.leading, 175 + geometry.safeAreaInsets.leading).offset(x: -geometry.safeAreaInsets.leading)
                    Rectangle().fill(Color("background")).frame(width: 175 + geometry.safeAreaInsets.leading).offset(x: -geometry.safeAreaInsets.leading)
                    HStack(spacing: 10) {
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
                                            OptionsView(currentSection: $currentSection, gameOver: $gameOver, fightLogic: fightLogic, player: 0, geoHeight: geometry.size.height)
                                        } else if currentSection == .skills {
                                            SkillsView(currentSection: $currentSection, fightLogic: fightLogic, player: 0, geoHeight: geometry.size.height)
                                        } else if currentSection == .team {
                                            TeamView(currentSection: $currentSection, fightLogic: fightLogic, player: 0, geoHeight: geometry.size.height)
                                        }
                                    }
                                }
                                .padding(.vertical, 15).frame(width: 115, height: geometry.size.height - 30)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: geometry.size.height - 30, height: 115)
                                    RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: geometry.size.height - 30, height: 115)
                                    CustomText(key: "waiting on other player", fontSize: 13).frame(width: geometry.size.height - 60, height: 85, alignment: .topLeading).padding(.horizontal, 15)
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
                                        Triangle().fill(Color("outline")).frame(width: 21, height: 57)
                                        Rectangle().fill(Color("outline")).frame(width: 190, height: 57)
                                    }
                                    .padding(.bottom, 3).offset(x: -1).frame(width: 210)
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(spacing: 5) {
                                            ForEach(fightLogic.fighters[0].indices) { index in
                                                Circle().fill(Color("outline")).frame(width: 12, height: 12).opacity(fightLogic.fighters[0][index].currhp == 0 ? 0.5 : 1)
                                            }
                                        }
                                        .padding(.leading, 24).offset(y: -5)
                                        HStack(spacing: 0) {
                                            Triangle().fill(Color("button")).frame(width: 20, height: 55)
                                            ZStack(alignment: .topTrailing) {
                                                Rectangle().fill(Color("button")).frame(width: 190)
                                                HStack(spacing: 5) {
                                                    ForEach(fightLogic.getFighter(player: 0).effects, id: \.self) { effect in
                                                        EffectView(effect: effect, battling: fightLogic.battling)
                                                    }
                                                    if fightLogic.weather != nil {
                                                        EffectView(effect: fightLogic.weather!, battling: fightLogic.battling, weather: true)
                                                    }
                                                }
                                                .offset(x: -12, y: -12)
                                                VStack(spacing: 0) {
                                                    HStack {
                                                        CustomText(key: fightLogic.getFighter(player: 0).name, fontSize: 16).lineLimit(1)
                                                        Spacer()
                                                        CustomText(text: "\(fightLogic.getFighter(player: 0).currhp)/\(fightLogic.getFighter(player: 0).getModifiedBase().health)HP", fontSize: 13)
                                                    }
                                                    ZStack(alignment: .leading) {
                                                        Rectangle().fill(Color("outline")).frame(height: 6)
                                                        Rectangle().fill(Color("health")).frame(width: calcWidth(fighter: fightLogic.getFighter(player: 0)), height: 6).animation(.default, value: fightLogic.getFighter(player: 0).currhp)
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
                                .rotationEffect(.degrees(90)).frame(width: 75, height: 210).offset(y: -offsetX).animation(.easeOut(duration: 0.3).delay(0.1), value: offsetX)
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
                                                    fightLogic.undoMove(player: 0)
                                                }
                                                currentSection = .options
                                            }
                                        }
                                    }
                                    .buttonStyle(ClearButton(width: 100, height: 35))
                                }
                                .rotationEffect(.degrees(90)).frame(width: 35, height: 100).disabled(fightLogic.battling)
                                Spacer()                            }
                            .padding(.top, 15)
                        }
                    }
                }
                Spacer()
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

struct LeftPlayerFightView_Previews: PreviewProvider {
    static var previews: some View {
        LeftPlayerFightView(fightLogic: FightLogic(leftFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter], rightFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter]), offsetX: 0, gameOver: .constant(false)).ignoresSafeArea(.all, edges: .bottom)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
