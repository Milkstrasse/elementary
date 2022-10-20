//
//  FightOverView.swift
//  Elementary
//
//  Created by Janice Hablützel on 23.08.22.
//

import SwiftUI

struct FightOverView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    let topFighters: [Fighter]
    let bottomFighters: [Fighter]
    
    let winner: Int
    
    @State var topReady: Bool = false
    @State var bottomReady: Bool = false
    
    @State var transitionToggle: Bool = true
    
    /// Reset each fighter in team to make them ready for a fight.
    /// - Parameter fighters: The array of fighters that should be reset
    func resetFighters(fighters: [Fighter]) {
        for fighter in fighters {
            fighter.reset()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                TriangleA().fill(Color("Background2")).frame(height: 145).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                Spacer()
                TriangleA().fill(Color("Background2")).frame(height: 145).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            VStack(spacing: innerPadding) {
                HStack(spacing: innerPadding) {
                    Spacer()
                    Button(action: {
                        if !topReady {
                            AudioPlayer.shared.playConfirmSound()
                            resetFighters(fighters: topFighters)
                        } else {
                            AudioPlayer.shared.playCancelSound()
                        }
                        
                        topReady = !topReady
                        gameLogic.setReady(player: 0, ready: topReady)
                        
                        if gameLogic.areBothReady() {
                            let fightLogic: FightLogic = FightLogic(players: [Player(id: 0, fighters: topFighters), Player(id: 1, fighters: bottomFighters)])
                            
                            if fightLogic.isValid() {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(FightView(fightLogic: fightLogic).environmentObject(manager)))
                                }
                            }
                        }
                    }) {
                        BasicButton(label: topReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "rematch"), width: 150, height: smallHeight, fontSize: 14)
                    }
                    Button(action: {
                        AudioPlayer.shared.playCancelSound()
                        
                        transitionToggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            manager.setView(view: AnyView(MainView().environmentObject(manager)))
                        }
                    }) {
                        BasicButton(label: "X", width: smallHeight, height: smallHeight, fontSize: 14)
                    }
                }
                .rotationEffect(.degrees(180))
                ZStack(alignment: .topLeading) {
                    Rectangle().fill(Color("Panel")) .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                    CustomText(text: Localization.shared.getTranslation(key: winner == 0 ? "winner" : "loser").uppercased(), fontSize: 14).padding(.all, innerPadding)
                }
                .frame(height: 110).rotationEffect(.degrees(180))
                Spacer()
                HStack(spacing: 5) {
                    ForEach(topFighters, id: \.self) { fighter in
                        SquarePortraitView(fighter: fighter, isSelected: false, isInverted: true)
                    }
                    ForEach(0 ..< 4 - topFighters.count, id: \.self) { index in
                        SquarePortraitView(fighter: nil, isSelected: false, isInverted: true)
                    }
                }
                .rotationEffect(.degrees(180))
                HStack(spacing: 5) {
                    ForEach(bottomFighters, id: \.self) { fighter in
                        SquarePortraitView(fighter: fighter, isSelected: false, isInverted: true)
                    }
                    ForEach(0 ..< 4 - bottomFighters.count, id: \.self) { index in
                        SquarePortraitView(fighter: nil, isSelected: false, isInverted: true)
                    }
                }
                Spacer()
                ZStack(alignment: .topLeading) {
                    Rectangle().fill(Color("Panel")) .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                    CustomText(text: Localization.shared.getTranslation(key: winner == 1 ? "winner" : "loser").uppercased(), fontSize: 14).padding(.all, innerPadding)
                }
                .frame(height: 110)
                HStack(spacing: innerPadding) {
                    Spacer()
                    Button(action: {
                        if !bottomReady {
                            AudioPlayer.shared.playConfirmSound()
                            resetFighters(fighters: bottomFighters)
                        } else {
                            AudioPlayer.shared.playCancelSound()
                        }
                        
                        bottomReady = !bottomReady
                        gameLogic.setReady(player: 1, ready: bottomReady)
                        
                        if gameLogic.areBothReady() {
                            let fightLogic: FightLogic = FightLogic(players: [Player(id: 0, fighters: topFighters), Player(id: 1, fighters: bottomFighters)])
                            
                            if fightLogic.isValid() {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(FightView(fightLogic: fightLogic).environmentObject(manager)))
                                }
                            }
                        }
                    }) {
                        BasicButton(label: bottomReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "rematch"), width: 150, height: smallHeight, fontSize: 14)
                    }
                    Button(action: {
                        AudioPlayer.shared.playCancelSound()
                        
                        transitionToggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            manager.setView(view: AnyView(MainView().environmentObject(manager)))
                        }
                    }) {
                        BasicButton(label: "X", width: smallHeight, height: smallHeight, fontSize: 14)
                    }
                }
            }
            .padding(.all, outerPadding)
            ZigZag().fill(Color.black).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            AudioPlayer.shared.playMenuMusic()
            
            DispatchQueue.main.async {
                GlobalData.shared.playerProgress.fightCounter += 1
                SaveLogic.shared.save()
            }
        }
    }
}

struct FightOverView_Previews: PreviewProvider {
    static var previews: some View {
        FightOverView(topFighters: [exampleFighter, exampleFighter], bottomFighters: [exampleFighter, exampleFighter, exampleFighter], winner: 0)
    }
}
