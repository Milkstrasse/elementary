//
//  CPUTrainingView.swift
//  Witchery
//
//  Created by Janice Hablützel on 15.01.22.
//

import SwiftUI

struct CPUTrainingView: View {
    @ObservedObject var fightLogic: FightLogic
    @ObservedObject var player: Player
    
    let offsetX: CGFloat
    
    var currentSection: Section = .waiting
    @Binding var gameOver: Bool
    
    @State var blink: Bool = false
    @State var stopBlinking: Bool = false
    
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
                        Image(blink ? player.getCurrentWitch().name + "_blink" : player.getCurrentWitch().name).resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40 + offsetX, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    } else if player.state == PlayerState.healing {
                        Image(player.getCurrentWitch().name + "_happy").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90))
                    } else if player.state == PlayerState.hurting {
                        Image(player.getCurrentWitch().name + "_hurt").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90))
                    } else {
                        Image(player.getCurrentWitch().name + "_attack").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(90))
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
            let blinkInterval: Int = Int.random(in: 5 ... 10)
            blink(delay: TimeInterval(blinkInterval))
        }
        .onDisappear {
            stopBlinking = true
        }
    }
}

struct CPUTrainingView_Previews: PreviewProvider {
    static var previews: some View {
        CPUTrainingView(fightLogic: FightLogic(players: [Player(id: 0, witches: [exampleWitch]), Player(id: 1, witches: [exampleWitch])]), player: Player(id: 1, witches: [exampleWitch]), offsetX: 0, gameOver:Binding.constant(false)).ignoresSafeArea(.all, edges: .bottom)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
