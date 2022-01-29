//
//  CPUTrainingView.swift
//  Witchery
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
    @State var healing: Bool = false
    
    @State var blink: Bool = false
    
    @State var previousWitch: String = ""
    
    func calcWidth(witch: Witch) -> CGFloat {
        DispatchQueue.main.async {
            let newHealth = fightLogic.getWitch(player: 0).currhp
            
            if fightLogic.getWitch(player: 0).name == previousWitch || previousWitch == ""  {
                if currentHealth > newHealth {
                    hurting = true
                } else if currentHealth < newHealth && currentHealth > 0 {
                    healing = true
                }
            }
            
            previousWitch = fightLogic.getWitch(player: 0).name
            currentHealth = newHealth
        }
        
        let percentage: CGFloat = CGFloat(witch.currhp)/CGFloat(witch.getModifiedBase().health)
        let width = round(170 * percentage)
        
        return width
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ZStack(alignment: .topLeading) {
                    if !hurting && !healing {
                        Image(blink ? fightLogic.getWitch(player: 0).name + "_blink" : fightLogic.getWitch(player: 0).name).resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40 + offsetX, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    } else if healing {
                        Image(fightLogic.getWitch(player: 0).name + "_happy").resizable().scaleEffect(healing ? 1.2 : 1.1).animation(.easeInOut, value: healing).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    healing = false
                                }
                            }
                    } else {
                        Image(fightLogic.getWitch(player: 0).name + "_hurt").resizable().scaleEffect(hurting ? 1.2 : 1.1).animation(.easeInOut, value: hurting).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90))
                            .onAppear {
                                AudioPlayer.shared.playHurtSound()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    hurting = false
                                }
                            }
                    }
                    Rectangle().fill(Color("outline")).frame(width: 1).padding(.leading, 175 + geometry.safeAreaInsets.leading).offset(x: -geometry.safeAreaInsets.leading)
                    Rectangle().fill(Color("background")).frame(width: 175 + geometry.safeAreaInsets.leading).offset(x: -geometry.safeAreaInsets.leading)
                    HStack(spacing: 10) {
                        Group {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: geometry.size.height - 30, height: 115)
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: geometry.size.height - 30, height: 115)
                                CustomText(key: "waiting", fontSize: 14).frame(width: geometry.size.height - 60, height: 85, alignment: .topLeading).padding(.horizontal, 15)
                            }
                            .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
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
                                    .padding(.bottom, 4).offset(x: -1).frame(width: 210)
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(spacing: 5) {
                                            ForEach(fightLogic.witches[0].indices) { index in
                                                Circle().fill(Color("outline")).frame(width: 10, height: 10).opacity(fightLogic.witches[0][index].currhp == 0 ? 0.5 : 1)
                                            }
                                        }
                                        .padding(.leading, 24).offset(y: -5)
                                        HStack(spacing: 0) {
                                            Triangle().fill(Color("button")).frame(width: 20, height: 55)
                                            ZStack(alignment: .topTrailing) {
                                                Rectangle().fill(Color("button")).frame(width: 190)
                                                HStack(spacing: 5) {
                                                    ForEach(fightLogic.getWitch(player: 0).hexes, id: \.self) { hex in
                                                        HexView(hex: hex, battling: fightLogic.battling)
                                                    }
                                                    if fightLogic.weather != nil {
                                                        HexView(hex: fightLogic.weather!, battling: fightLogic.battling, weather: true)
                                                    }
                                                }
                                                .offset(x: -12, y: -12)
                                                VStack(spacing: 0) {
                                                    HStack {
                                                        CustomText(key: fightLogic.getWitch(player: 0).name, fontSize: 16).lineLimit(1)
                                                        Spacer()
                                                        CustomText(text: Localization.shared.getTranslation(key: "hpBar", params: ["\(fightLogic.getWitch(player: 0).currhp)", "\(fightLogic.getWitch(player: 0).getModifiedBase().health)"]), fontSize: 13)
                                                    }
                                                    ZStack(alignment: .leading) {
                                                        Rectangle().fill(Color("outline")).frame(height: 6)
                                                        Rectangle().fill(Color("health")).frame(width: calcWidth(witch: fightLogic.getWitch(player: 0)), height: 6).animation(.default, value: fightLogic.getWitch(player: 0).currhp)
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
                                    }
                                    .buttonStyle(ClearButton(width: 100, height: 35)).opacity(0.7).disabled(true)
                                }
                                .rotationEffect(.degrees(90)).frame(width: 35, height: 100)
                                Spacer()
                            }
                            .padding(.top, 15)
                        }
                    }
                }
                Spacer()
            }
            .frame(width: geometry.size.width)
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

struct CPUTrainingView_Previews: PreviewProvider {
    static var previews: some View {
        CPUTrainingView(fightLogic: FightLogic(leftWitches: [exampleWitch, exampleWitch, exampleWitch, exampleWitch], rightWitches: [exampleWitch, exampleWitch, exampleWitch, exampleWitch]), offsetX: 0, gameOver: .constant(false)).ignoresSafeArea(.all, edges: .bottom)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
