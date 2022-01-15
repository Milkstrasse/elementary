//
//  CPUTrainingView.swift
//  Magiko
//
//  Created by Janice Hablützel on 15.01.22.
//

import SwiftUI

struct CPUTrainingView: View {
    @ObservedObject var fightLogic: FightLogic
    
    let offsetX: CGFloat
    
    var currentSection: Section = .waiting
    @Binding var gameOver: Bool
    
    @State var currentHealth: Int = 0
    @State var hurting: Bool = false
    
    func calcWidth(fighter: Fighter) -> CGFloat {
        DispatchQueue.main.async {
            let newHealth = fightLogic.getFighter(player: 0).currhp
            if currentHealth > newHealth {
                currentHealth = newHealth
                hurting = true
            } else {
                currentHealth = newHealth
            }
        }
        
        let percentage: CGFloat = CGFloat(fighter.currhp)/CGFloat(fighter.getModifiedBase().health)
        let width = round(190 * percentage)
        
        return width
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ZStack(alignment: .topLeading) {
                    if !hurting {
                        Image(fightLogic.getFighter(player: 0).name).resizable().scaleEffect(3.7).aspectRatio(contentMode: .fit).frame(width: 215).offset(x: -40 + offsetX, y: 0).rotationEffect(.degrees(90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    } else {
                        Image(fightLogic.getFighter(player: 0).name + "_closed").resizable().scaleEffect(3.7).aspectRatio(contentMode: .fit).frame(width: 215).offset(x: -40 + offsetX, y: 0).rotationEffect(.degrees(90))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    hurting = false
                                }
                            }
                    }
                    Rectangle().fill(Color.pink).frame(width: 175 + geometry.safeAreaInsets.leading).offset(x: -geometry.safeAreaInsets.leading)
                    HStack(spacing: 10) {
                        Group {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: geometry.size.height - 30, height: 115)
                                CustomText(key: "waiting on other player").frame(width: geometry.size.height - 60, height: 87, alignment: .topLeading).padding(.horizontal, 15)
                            }
                            .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
                        }
                        .padding(.trailing, 15).rotationEffect(.degrees(180))
                        VStack(alignment: .leading) {
                            ZStack {
                                Button(currentSection == .summary ? Localization.shared.getTranslation(key: "next") : Localization.shared.getTranslation(key: "back")) {
                                }
                                .buttonStyle(ClearButton(width: 100, height: 35)).disabled(true)
                            }
                            .rotationEffect(.degrees(90)).frame(width: 35, height: 100).disabled(fightLogic.battling)
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
                        .padding(.top, 15)
                    }
                }
                .frame(width: 215)
                Spacer()
            }
        }
    }
}

struct CPUTrainingView_Previews: PreviewProvider {
    static var previews: some View {
        CPUTrainingView(fightLogic: FightLogic(leftFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter], rightFighters: [exampleFighter, exampleFighter, exampleFighter, exampleFighter]), offsetX: 0, gameOver: .constant(false)).edgesIgnoringSafeArea(.bottom)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
