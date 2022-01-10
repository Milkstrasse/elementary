//
//  RightPlayerFightView.swift
//  Magiko
//
//  Created by Janice Hablützel on 04.01.22.
//

import Foundation
import SwiftUI

struct RightPlayerFightView: View {
    @ObservedObject var fightLogic: FightLogic
    
    let offsetX: CGFloat
    
    @State var currentSection: Section = .summary
    @Binding var gameOver: Bool
    
    @State var currentHealth: UInt = 0
    @State var hurting: Bool = false
    
    func calcWidth(fighter: Fighter) -> CGFloat {
        DispatchQueue.main.async {
            let newHealth = fightLogic.getFighter(player: 1).currhp
            if currentHealth > newHealth {
                currentHealth = newHealth
                hurting = true
            } else {
                currentHealth = newHealth
            }
        }
        
        let percentage: CGFloat = CGFloat(fighter.currhp)/CGFloat(fighter.base.health)
        let width = round(190 * percentage)
        
        return width
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                ZStack(alignment: .bottomTrailing) {
                    if !hurting {
                        Image(fightLogic.getFighter(player: 1).name).resizable().scaleEffect(3.7).aspectRatio(contentMode: .fit).frame(width: 215).offset(x: -40 + offsetX, y: 0).rotationEffect(.degrees(-90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    } else {
                        Image(fightLogic.getFighter(player: 1).name + "_closed").resizable().scaleEffect(3.7).aspectRatio(contentMode: .fit).frame(width: 215).offset(x: -40 + offsetX, y: 0).rotationEffect(.degrees(-90))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    hurting = false
                                }
                            }
                    }
                    Rectangle().fill(Color.pink).frame(width: 175 + geometry.safeAreaInsets.trailing).offset(x: geometry.safeAreaInsets.trailing)
                    HStack(spacing: 10) {
                        VStack(alignment: .trailing) {
                            ZStack(alignment: .leading) {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 5) {
                                        ForEach(fightLogic.rightFighters.indices) { index in
                                            Circle().fill(Color.blue).frame(width: 12)
                                        }
                                    }
                                    .padding(.leading, 24)
                                    HStack(spacing: 0) {
                                        Triangle().fill(Color.blue).frame(width: 20)
                                        ZStack(alignment: .topTrailing) {
                                            Rectangle().fill(Color.blue).frame(width: 210)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5).fill(Color.green)
                                                CustomText(key: "Fine")
                                            }
                                            .frame(width: 90, height: 30).offset(x: -15, y: -15)
                                            VStack(spacing: 0) {
                                                HStack {
                                                    CustomText(key: fightLogic.getFighter(player: 1).name).lineLimit(1)
                                                    Spacer()
                                                    CustomText(text: "\(Int(fightLogic.getFighter(player: 1).currhp))/\(Int(fightLogic.getFighter(player: 1).getModifiedBase().health))HP")
                                                }
                                                ZStack(alignment: .leading) {
                                                    Rectangle().fill(Color.purple).frame(height: 6)
                                                    Rectangle().fill(Color.yellow).frame(width: calcWidth(fighter: fightLogic.getFighter(player: 1)), height: 6).animation(.default, value: fightLogic.getFighter(player: 1).currhp)
                                                }
                                            }
                                            .padding(.trailing, 15).padding(.leading, 5).frame(height: 55)
                                        }
                                    }
                                    .frame(height: 55)
                                }
                                .frame(height: 75)
                            }
                            .rotationEffect(.degrees(-90)).frame(width: 75, height: 230).offset(y: offsetX).animation(.easeOut(duration: 0.3).delay(0.1), value: offsetX)
                            Spacer()
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
                                .buttonStyle(ClearGrowingButton(width: 100, height: 35))
                            }
                            .rotationEffect(.degrees(-90)).frame(width: 35, height: 100).disabled(fightLogic.battling)
                        }
                        .padding(.bottom, 15)
                        Group {
                            if currentSection == .summary {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: geometry.size.height - 30, height: 115)
                                    ScrollView(.vertical, showsIndicators: false) {
                                        CustomText(text: fightLogic.publishedText).frame(width: geometry.size.height - 60, alignment: .leading)
                                    }
                                    .frame(height: 87).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
                            } else if currentSection != .waiting {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 5) {
                                        if currentSection == .options {
                                            OptionsView(currentSection: $currentSection, gameOver: $gameOver, fightLogic: fightLogic, player: 1, geoHeight: geometry.size.height)
                                        } else if currentSection == .skills {
                                            SkillsView(currentSection: $currentSection, fightLogic: fightLogic, player: 1, geoHeight: geometry.size.height)
                                        } else if currentSection == .team {
                                            TeamView(currentSection: $currentSection, fightLogic: fightLogic, player: 1, geoHeight: geometry.size.height)
                                        } else if currentSection == .info {
                                            DetailedActionView(title: "Nickname", description: "50/50HP - No Modifiers", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                            DetailedActionView(title: "Nickname", description: "50/50HP - No Modifiers", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                        }
                                    }
                                }
                                .padding(.vertical, 15)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: geometry.size.height - 30, height: 115)
                                    CustomText(key: "waiting on other player").frame(width: geometry.size.height - 60, height: 87, alignment: .topLeading).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
                            }
                        }
                        .padding(.trailing, 15)
                    }
                }
                .frame(width: 215)
            }
            .onReceive(fightLogic.$battling, perform: { battling in
                if battling {
                    currentSection = .summary
                }
            })
        }
    }
}

struct RightPlayerFightView_Previews: PreviewProvider {
    static var previews: some View {
        RightPlayerFightView(fightLogic: FightLogic(leftFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter], rightFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter]), offsetX: 0, gameOver: .constant(false)).edgesIgnoringSafeArea(.bottom)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
