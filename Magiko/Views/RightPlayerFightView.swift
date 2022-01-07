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
    
    func calcWidth(fighter: Fighter) -> CGFloat {
        let percentage: CGFloat = CGFloat(fighter.currhp)/CGFloat(fighter.base.health)
        let width = round(180 * percentage)
        
        return width
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                ZStack(alignment: .bottomTrailing) {
                    Image(fightLogic.getRightFighter().name).resizable().scaleEffect(3.7).aspectRatio(contentMode: .fit).frame(width: 215).offset(x: -40 + offsetX, y: 0).rotationEffect(.degrees(-90)).animation(.easeOut(duration: 0.3), value: offsetX)
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
                                                    CustomText(key: fightLogic.getRightFighter().name).lineLimit(1)
                                                    Spacer()
                                                    CustomText(key: "\(Int(fightLogic.getRightFighter().currhp))/\(Int(fightLogic.getRightFighter().base.health))HP")
                                                }
                                                ZStack(alignment: .leading) {
                                                    Rectangle().fill(Color.purple).frame(height: 6)
                                                    Rectangle().fill(Color.yellow).frame(width: calcWidth(fighter: fightLogic.getRightFighter()), height: 6)
                                                }
                                            }
                                            .padding(.horizontal, 15).frame(height: 55)
                                        }
                                    }
                                    .frame(height: 55)
                                }
                                .frame(height: 75)
                            }
                            .rotationEffect(.degrees(-90)).frame(width: 75, height: 230).offset(y: offsetX).animation(.easeOut(duration: 0.3).delay(0.1), value: offsetX)
                            Spacer()
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
                            .rotationEffect(.degrees(-90)).frame(width: 35, height: 100)
                        }
                        .padding(.bottom, 15)
                        Group {
                            if currentSection == .summary {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: geometry.size.height - 30, height: 115)
                                    ScrollView(.vertical, showsIndicators: false) {
                                        CustomText(key: "jkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldjl\njfldsfjkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldj\nljfldsfjkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjf\nljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldjljfldsfjkjjjfljldjljfld\nsfjkjjjfljldj\nljfldsf").frame(maxWidth: geometry.size.height - 60)
                                    }
                                    .frame(height: 87).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 5) {
                                        if currentSection == .options {
                                            Button(action: {
                                                currentSection = .skills
                                            }) {
                                                DetailedActionView(title: "Fight", description: "Use your skills", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                            }
                                            Button(action: {
                                                currentSection = .team
                                            }) {
                                                DetailedActionView(title: "Team", description: "Switch out", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                            }
                                            Button(action: {
                                                currentSection = .info
                                            }) {
                                                DetailedActionView(title: "Info", description: "Gather intel", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                            }
                                            Button(action: {
                                                
                                            }) {
                                                DetailedActionView(title: "Forfeit", description: "End battle", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                            }
                                        } else if currentSection == .skills {
                                            ForEach(fightLogic.getRightFighter().skills, id: \.self) { skill in
                                                Button(action: {
                                                    fightLogic.attack(player: 1)
                                                }) {
                                                    DetailedActionView(title: skill.name, description: "Effective - 10/10PP", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                                }
                                            }
                                        } else if currentSection == .team {
                                            ForEach(fightLogic.rightFighters.indices) { index in
                                                if index == fightLogic.currentRightFighter {
                                                    DetailedActionView(title: fightLogic.rightFighters[index].name, description: "50/50HP - No Status", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                                } else {
                                                    Button(action: {
                                                        
                                                    }) {
                                                        DetailedActionView(title: fightLogic.rightFighters[index].name, description: "50/50HP - No Status", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                                    }
                                                }
                                            }
                                        } else {
                                            Button(action: {
                                                
                                            }) {
                                                DetailedActionView(title: "Nickname", description: "50/50HP - No Modifiers", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                            }
                                            Button(action: {
                                                
                                            }) {
                                                DetailedActionView(title: "Nickname", description: "50/50HP - No Modifiers", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 15)
                            }
                        }
                        .padding(.trailing, 15)
                    }
                }
                .frame(width: 215)
            }
        }
    }
}

struct RightPlayerFightView_Previews: PreviewProvider {
    static var previews: some View {
        RightPlayerFightView(fightLogic: FightLogic(leftFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter], rightFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter]), offsetX: 0).edgesIgnoringSafeArea(.bottom)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
