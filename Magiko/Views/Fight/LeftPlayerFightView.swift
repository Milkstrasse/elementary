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
        let width = round(190 * percentage)
        
        return width
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ZStack(alignment: .topLeading) {
                    if !hurting && !healing {
                        Image(fightLogic.getFighter(player: 0).name).resizable().scaleEffect(3.7).aspectRatio(contentMode: .fit).frame(width: 215).offset(x: -40 + offsetX, y: 0).rotationEffect(.degrees(90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    } else if healing {
                        Image(fightLogic.getFighter(player: 0).name + "_healed").resizable().scaleEffect(healing ? 3.8 : 3.7).animation(.easeInOut, value: healing).aspectRatio(contentMode: .fit).frame(width: 215).offset(x: -40 + offsetX, y: 0).rotationEffect(.degrees(90))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    healing = false
                                }
                            }
                    } else {
                        Image(fightLogic.getFighter(player: 0).name + "_hurt").resizable().scaleEffect(hurting ? 3.8 : 3.7).animation(.easeInOut, value: hurting).aspectRatio(contentMode: .fit).frame(width: 215).offset(x: -40 + offsetX, y: 0).rotationEffect(.degrees(90))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    hurting = false
                                }
                            }
                    }
                    Rectangle().fill(Color.pink).frame(width: 175 + geometry.safeAreaInsets.leading).offset(x: -geometry.safeAreaInsets.leading)
                    HStack(spacing: 10) {
                        Group {
                            if currentSection == .summary {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: geometry.size.height - 30, height: 123)
                                    ScrollView(.vertical, showsIndicators: false) {
                                        CustomText(text: fightLogic.battleLog).frame(width: geometry.size.height - 60, alignment: .leading)
                                    }
                                    .frame(height: 93).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 123, height: geometry.size.height - 30)
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
                                .padding(.vertical, 15).frame(width: 123, height: geometry.size.height - 30)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: geometry.size.height - 30, height: 123)
                                    CustomText(key: "waiting on other player").frame(width: geometry.size.height - 60, height: 93, alignment: .topLeading).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 123, height: geometry.size.height - 30)
                            }
                        }
                        .padding(.trailing, 15).rotationEffect(.degrees(180))
                        ZStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Spacer()
                                ZStack(alignment: .leading) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(spacing: 5) {
                                            ForEach(fightLogic.fighters[0].indices) { index in
                                                Circle().fill(Color.blue).frame(width: 12)
                                            }
                                        }
                                        .padding(.leading, 24)
                                        HStack(spacing: 0) {
                                            Triangle().fill(Color.blue).frame(width: 20)
                                            ZStack(alignment: .topTrailing) {
                                                Rectangle().fill(Color.blue).frame(width: 210)
                                                HStack(spacing: 5) {
                                                    ForEach(fightLogic.getFighter(player: 0).effects, id: \.self) { effect in
                                                        EffectView(effect: effect, battling: fightLogic.battling)
                                                    }
                                                    if fightLogic.weather != nil {
                                                        EffectView(effect: fightLogic.weather!, battling: fightLogic.battling, weather: true)
                                                    }
                                                }
                                                .offset(x: -15, y: -15)
                                                VStack(spacing: 0) {
                                                    HStack {
                                                        CustomText(key: fightLogic.getFighter(player: 0).name).lineLimit(1)
                                                        Spacer()
                                                        CustomText(text: "\(fightLogic.getFighter(player: 0).currhp)/\(fightLogic.getFighter(player: 0).getModifiedBase().health)HP")
                                                    }
                                                    ZStack(alignment: .leading) {
                                                        Rectangle().fill(Color.purple).frame(height: 6)
                                                        Rectangle().fill(Color.yellow).frame(width: calcWidth(fighter: fightLogic.getFighter(player: 0)), height: 6).animation(.default, value: fightLogic.getFighter(player: 0).currhp)
                                                    }
                                                }
                                                .padding(.trailing, 15).padding(.leading, 5).frame(height: 55)
                                            }
                                        }
                                        .frame(height: 55)
                                    }
                                    .frame(height: 75)
                                }
                                .rotationEffect(.degrees(90)).frame(width: 75, height: 230).offset(y: -offsetX).animation(.easeOut(duration: 0.3).delay(0.1), value: offsetX)
                            }
                            VStack(alignment: .leading) {
                                ZStack {
                                    Button(currentSection == .summary ? Localization.shared.getTranslation(key: "next") : Localization.shared.getTranslation(key: "back")) {
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
                .frame(width: 215)
                Spacer()
            }
            .onReceive(fightLogic.$battling, perform: { battling in
                if battling {
                    currentSection = .summary
                }
            })
        }
    }
}

struct LeftPlayerFightView_Previews: PreviewProvider {
    static var previews: some View {
        LeftPlayerFightView(fightLogic: FightLogic(leftFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter], rightFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter]), offsetX: 0, gameOver: .constant(false)).edgesIgnoringSafeArea(.bottom)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
