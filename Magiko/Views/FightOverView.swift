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
        ZStack {
            Color.red.ignoresSafeArea()
            ZStack {
                HStack(spacing: 0) {
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            Button(leftReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "rematch")) {
                                resetFighters(fighters: leftFighters)
                                
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
                            .buttonStyle(GrowingButton(width: 135))
                            Button("X") {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                }
                            }
                            .buttonStyle(GrowingButton(width: 40))
                        }
                        .rotationEffect(.degrees(90)).frame(width: 40, height: 180)
                    }
                    HStack {
                        HStack(spacing: 0) {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: 109)
                                ZStack {
                                    CustomText(key: winner == 0 ? "won game" : "lost game").fixedSize().frame(width: 250, height: 79, alignment: .topLeading)
                                }
                                .frame(width: 79, height: 250).padding(.all, 15).rotationEffect(.degrees(90))
                            }
                            .frame(width: 109)
                            SmallTriangle().fill(Color.yellow).frame(width: 14, height: 26).offset(y: 113).rotationEffect(.degrees(180))
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            HStack(spacing: 5) {
                                ForEach(leftFighters, id: \.self) { fighter in
                                    FighterView(fighter: fighter, isSelected: false)
                                }
                                ForEach(0 ..< 4 - leftFighters.count) { index in
                                    FighterView(fighter: nil, isSelected: false)
                                }
                            }
                            .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                            Spacer()
                        }
                    }
                    .padding(.leading, 10)
                    CustomText(text: "------- X -------").rotationEffect(.degrees(90)).fixedSize().frame(width: 60)
                    HStack {
                        VStack {
                            Spacer()
                            HStack(spacing: 5) {
                                ForEach(rightFighters, id: \.self) { fighter in
                                    FighterView(fighter: fighter, isSelected: false)
                                }
                                ForEach(0 ..< 4 - rightFighters.count) { index in
                                    FighterView(fighter: nil, isSelected: false)
                                }
                            }
                            .rotationEffect(.degrees(-90)).frame(width: 70, height: 295)
                            Spacer()
                        }
                        Spacer()
                        HStack(spacing: 0) {
                            SmallTriangle().fill(Color.yellow).frame(width: 14, height: 26).offset(y: 113)
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: 109)
                                ZStack {
                                    CustomText(key: winner == 0 ? "lost game" : "won game").fixedSize().frame(width: 250, height: 79, alignment: .topLeading)
                                }
                                .frame(width: 79, height: 250).padding(.all, 15).rotationEffect(.degrees(-90))
                            }
                            .frame(width: 109)
                        }
                    }
                    .padding(.trailing, 10)
                    VStack {
                        HStack(spacing: 5) {
                            Button(rightReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "rematch")) {
                                resetFighters(fighters: rightFighters)
                                
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
                            .buttonStyle(GrowingButton(width: 135))
                            Button("X") {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                }
                            }
                            .buttonStyle(GrowingButton(width: 40))
                        }
                        .rotationEffect(.degrees(-90)).frame(width: 40, height: 180)
                        Spacer()
                    }
                }
                .padding(.all, 15)
            }
            .edgesIgnoringSafeArea(.bottom)
            GeometryReader { geometry in
                ZigZag().fill(Color.purple).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
                    .offset(y: transitionToggle ? -65 : -(geometry.size.height + 65)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
            }
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
