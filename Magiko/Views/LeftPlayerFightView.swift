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
    
    func calcWidth(fighter: Fighter) -> CGFloat {
        let percentage: CGFloat = CGFloat(fighter.currhp)/CGFloat(fighter.base.health)
        let width = round(180 * percentage)
        
        return width
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ZStack(alignment: .topLeading) {
                    Image(fightLogic.getFighter(player: 0).name).resizable().scaleEffect(3.7).aspectRatio(contentMode: .fit).frame(width: 215).offset(x: -40 + offsetX, y: 0).rotationEffect(.degrees(90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    Rectangle().fill(Color.pink).frame(width: 175 + geometry.safeAreaInsets.leading).offset(x: -geometry.safeAreaInsets.leading)
                    HStack(spacing: 10) {
                        Group {
                            if currentSection == .summary {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: geometry.size.height - 30, height: 115)
                                    ScrollView(.vertical, showsIndicators: false) {
                                        CustomText(key: "player did something").frame(width: geometry.size.height - 60, alignment: .leading)
                                    }
                                    .frame(height: 87).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
                            } else if currentSection != .waiting {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 5) {
                                        if currentSection == .options {
                                            OptionsView(currentSection: $currentSection, geoHeight: geometry.size.height)
                                        } else if currentSection == .skills {
                                            SkillsView(currentSection: $currentSection, fightLogic: fightLogic, player: 0, geoHeight: geometry.size.height)
                                        } else if currentSection == .team {
                                            TeamView(currentSection: $currentSection, fightLogic: fightLogic, player: 0, geoHeight: geometry.size.height)
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
                        .padding(.trailing, 15).rotationEffect(.degrees(180))
                        VStack(alignment: .leading) {
                            ZStack {
                                Button(currentSection == .summary ? GlobalData.shared.getTranslation(key: "next") : GlobalData.shared.getTranslation(key: "back")) {
                                    if currentSection == .options {
                                        currentSection = .summary
                                    } else {
                                        currentSection = .options
                                    }
                                }
                                .buttonStyle(ClearGrowingButton(width: 100, height: 35))
                            }
                            .rotationEffect(.degrees(90)).frame(width: 35, height: 100)
                            Spacer()
                            ZStack(alignment: .leading) {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 5) {
                                        ForEach(fightLogic.leftFighters.indices) { index in
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
                                                    CustomText(key: fightLogic.getFighter(player: 0).name).lineLimit(1)
                                                    Spacer()
                                                    CustomText(key: "\(Int(fightLogic.getFighter(player: 0).currhp))/\(Int(fightLogic.getFighter(player: 0).base.health))HP")
                                                }
                                                ZStack(alignment: .leading) {
                                                    Rectangle().fill(Color.purple).frame(height: 6)
                                                    Rectangle().fill(Color.yellow).frame(width: calcWidth(fighter: fightLogic.getFighter(player: 0)), height: 6)
                                                }
                                            }
                                            .padding(.horizontal, 15).frame(height: 55)
                                        }
                                    }
                                    .frame(height: 55)
                                }
                                .frame(height: 75)
                            }
                            .rotationEffect(.degrees(90)).frame(width: 75, height: 230).offset(y: -offsetX).animation(.easeOut(duration: 0.3).delay(0.1), value: offsetX)
                        }
                        .padding(.top, 15)
                    }
                }
                .frame(width: 215)
                Spacer()
            }
        }
    }
}

struct LeftPlayerFightView_Previews: PreviewProvider {
    static var previews: some View {
        LeftPlayerFightView(fightLogic: FightLogic(leftFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter], rightFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter]), offsetX: 0).edgesIgnoringSafeArea(.bottom)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
