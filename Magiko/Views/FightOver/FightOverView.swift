//
//  FightOverView.swift
//  Magiko
//
//  Created by Janice Hablützel on 06.01.22.
//

import SwiftUI

struct FightOverView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    let leftFighters: [Fighter]
    let rightFighters: [Fighter]
    
    let winner: Int
    
    @State var leftReady: Bool = false
    @State var rightReady: Bool = false
    
    @State var transitionToggle: Bool = true
    
    func resetFighters(fighters: [Fighter]) {
        for fighter in fighters {
            fighter.reset()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    Spacer()
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(leftFighters, id: \.self) { fighter in
                                SquareFighterView(fighter: fighter, isSelected: false)
                            }
                            ForEach(0 ..< 4 - leftFighters.count) { index in
                                SquareFighterView(fighter: nil, isSelected: false)
                            }
                        }
                        .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                        Spacer()
                    }
                    CustomText(text: "------- X -------").rotationEffect(.degrees(90)).frame(width: 60)
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(rightFighters, id: \.self) { fighter in
                                SquareFighterView(fighter: fighter, isSelected: false)
                            }
                            ForEach(0 ..< 4 - rightFighters.count) { index in
                                SquareFighterView(fighter: nil, isSelected: false)
                            }
                        }
                        .rotationEffect(.degrees(-90)).frame(width: 70, height: 295)
                        Spacer()
                    }
                    Spacer()
                }
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Rectangle().fill(Color("background")).frame(width: 174 + geometry.safeAreaInsets.leading)
                            Rectangle().fill(Color("outline")).frame(width: 1)
                        }
                        .offset(x: -geometry.safeAreaInsets.leading)
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: 95, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: 95, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                            ZStack {
                                CustomText(key: winner == 0 ? "won game" : "lost game").frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 50, height: 75, alignment: .topLeading)
                            }
                            .frame(width: 75, height: geometry.size.height + geometry.safeAreaInsets.bottom - 50).padding(.all, 10).rotationEffect(.degrees(90))
                        }
                        .padding(.leading, 65)
                        VStack {
                            Spacer()
                            HStack(spacing: 5) {
                                Button(leftReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "rematch")) {
                                    if !leftReady {
                                        AudioPlayer.shared.playConfirmSound()
                                        resetFighters(fighters: leftFighters)
                                    } else {
                                        AudioPlayer.shared.playCancelSound()
                                    }
                                    
                                    leftReady = !leftReady
                                    gameLogic.setReady(player: 0, ready: leftReady)
                                    
                                    if gameLogic.areBothReady() {
                                        let fightLogic: FightLogic = FightLogic(leftFighters: leftFighters, rightFighters: rightFighters)
                                        
                                        if fightLogic.isValid() {
                                            transitionToggle = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                manager.setView(view: AnyView(FightView(fightLogic: fightLogic).environmentObject(manager)))
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(BasicButton(width: 135))
                                Button("X") {
                                    AudioPlayer.shared.playStandardSound()
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                    }
                                }
                                .buttonStyle(BasicButton(width: 40))
                            }
                            .rotationEffect(.degrees(90)).frame(width: 40, height: 180)
                        }
                        .padding([.bottom, .leading], 15)
                    }
                    Spacer()
                    ZStack(alignment: .trailing) {
                        HStack(spacing: 0) {
                            Rectangle().fill(Color("outline")).frame(width: 1)
                            Rectangle().fill(Color("background")).frame(width: 174 + geometry.safeAreaInsets.trailing)
                        }
                        .offset(x: geometry.safeAreaInsets.trailing)
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: 95, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: 95, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                            ZStack {
                                CustomText(key: winner == 1 ? "won game" : "lost game").frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 50, height: 75, alignment: .topLeading)
                            }
                            .frame(width: 75, height: geometry.size.height + geometry.safeAreaInsets.bottom - 50).padding(.all, 10).rotationEffect(.degrees(-90))
                        }
                        .padding(.trailing, 65)
                        VStack {
                            HStack(spacing: 5) {
                                Button(rightReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "rematch")) {
                                    if !rightReady {
                                        AudioPlayer.shared.playConfirmSound()
                                        resetFighters(fighters: rightFighters)
                                    } else {
                                        AudioPlayer.shared.playCancelSound()
                                    }
                                    
                                    rightReady = !rightReady
                                    gameLogic.setReady(player: 1, ready: rightReady)
                                    
                                    if gameLogic.areBothReady() {
                                        let fightLogic: FightLogic = FightLogic(leftFighters: leftFighters, rightFighters: rightFighters)
                                        
                                        if fightLogic.isValid() {
                                            transitionToggle = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                manager.setView(view: AnyView(FightView(fightLogic: fightLogic).environmentObject(manager)))
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(BasicButton(width: 135))
                                Button("X") {
                                    AudioPlayer.shared.playStandardSound()
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                    }
                                }
                                .buttonStyle(BasicButton(width: 40))
                            }
                            .rotationEffect(.degrees(-90)).frame(width: 40, height: 180)
                            Spacer()
                        }
                        .padding([.top, .trailing], 15)
                    }
                }
                .frame(height: geometry.size.height + geometry.safeAreaInsets.bottom)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            ZigZag().fill(Color("outline")).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -65 : -(geometry.size.height + 65)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
        }
    }
}

struct FightOverView_Previews: PreviewProvider {
    static var previews: some View {
        FightOverView(leftFighters: [exampleFighter, exampleFighter], rightFighters: [exampleFighter, exampleFighter, exampleFighter], winner: 0)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
