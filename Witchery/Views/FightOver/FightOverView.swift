//
//  FightOverView.swift
//  Witchery
//
//  Created by Janice Hablützel on 06.01.22.
//

import SwiftUI

struct FightOverView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    let leftWitches: [Witch]
    let rightWitches: [Witch]
    
    let winner: Int
    
    @State var leftReady: Bool = false
    @State var rightReady: Bool = false
    
    @State var transitionToggle: Bool = true
    
    func resetWitches(witches: [Witch]) {
        for witch in witches {
            witch.reset()
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
                            ForEach(leftWitches, id: \.self) { witch in
                                SquareWitchView(witch: witch, isSelected: false)
                            }
                            ForEach(0 ..< 4 - leftWitches.count) { index in
                                SquareWitchView(witch: nil, isSelected: false)
                            }
                        }
                        .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                        Spacer()
                    }
                    ZStack {
                        Rectangle().fill(Color("outline")).frame(width: 1).padding(.vertical, 15)
                        CustomText(text: "X", fontSize: 18).padding(.horizontal, 10).background(Color("background")).rotationEffect(.degrees(90))
                    }
                    .frame(width: 60)
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(rightWitches, id: \.self) { witch in
                                SquareWitchView(witch: witch, isSelected: false)
                            }
                            ForEach(0 ..< 4 - rightWitches.count) { index in
                                SquareWitchView(witch: nil, isSelected: false)
                            }
                        }
                        .rotationEffect(.degrees(-90)).frame(width: 70, height: 295)
                        Spacer()
                    }
                    Spacer()
                }
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                            ZStack {
                                CustomText(key: winner == 0 ? "won game" : "lost game", fontSize: 16).frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 60, height: 80, alignment: .topLeading)
                            }
                            .frame(width: 80, height: geometry.size.height + geometry.safeAreaInsets.bottom - 60).padding(.all, 15).rotationEffect(.degrees(90))
                        }
                        .padding(.leading, 65)
                        VStack {
                            Spacer()
                            HStack(spacing: 5) {
                                Button(leftReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "rematch")) {
                                    if !leftReady {
                                        AudioPlayer.shared.playConfirmSound()
                                        resetWitches(witches: leftWitches)
                                    } else {
                                        AudioPlayer.shared.playCancelSound()
                                    }
                                    
                                    leftReady = !leftReady
                                    gameLogic.setReady(player: 0, ready: leftReady)
                                    
                                    if gameLogic.areBothReady() {
                                        let fightLogic: FightLogic = FightLogic(leftWitches: leftWitches, rightWitches: rightWitches)
                                        
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
                                    AudioPlayer.shared.playCancelSound()
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
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                            ZStack {
                                CustomText(key: winner == 1 ? "won game" : "lost game", fontSize: 16).frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 60, height: 80, alignment: .topLeading)
                            }
                            .frame(width: 80, height: geometry.size.height + geometry.safeAreaInsets.bottom - 60).padding(.all, 15).rotationEffect(.degrees(-90))
                        }
                        .padding(.trailing, 65)
                        VStack {
                            HStack(spacing: 5) {
                                Button(rightReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "rematch")) {
                                    if !rightReady {
                                        AudioPlayer.shared.playConfirmSound()
                                        resetWitches(witches: rightWitches)
                                    } else {
                                        AudioPlayer.shared.playCancelSound()
                                    }
                                    
                                    rightReady = !rightReady
                                    gameLogic.setReady(player: 1, ready: rightReady)
                                    
                                    if gameLogic.areBothReady() {
                                        let fightLogic: FightLogic = FightLogic(leftWitches: leftWitches, rightWitches: rightWitches)
                                        
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
                                    AudioPlayer.shared.playCancelSound()
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
            AudioPlayer.shared.playMenuMusic()
            transitionToggle = false
        }
    }
}

struct FightOverView_Previews: PreviewProvider {
    static var previews: some View {
        FightOverView(leftWitches: [exampleWitch, exampleWitch], rightWitches: [exampleWitch, exampleWitch, exampleWitch], winner: 0)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
