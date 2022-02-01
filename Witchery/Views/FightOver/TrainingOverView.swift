//
//  TrainingOverView.swift
//  Witchery
//
//  Created by Janice Hablützel on 15.01.22.
//

import SwiftUI

struct TrainingOverView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    let leftWitches: [Witch]
    let rightWitches: [Witch]
    
    let winner: Int
    var isTutorial: Bool = false
    
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
                                if !isTutorial {
                                    CustomText(key: winner == 0 ? "won game" : "lost game", fontSize: 16).frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 60, height: 80, alignment: .topLeading)
                                } else {
                                    CustomText(text: "click on rematch if you want to play again", fontSize: 16).frame(width: geometry.size.height - 60, height: 80, alignment: .topLeading)
                                }
                            }
                            .frame(width: 80, height: geometry.size.height + geometry.safeAreaInsets.bottom - 60).padding(.all, 10).rotationEffect(.degrees(90))
                        }
                        .padding(.leading, 65)
                        VStack {
                            Spacer()
                            HStack(spacing: 5) {
                                Button(Localization.shared.getTranslation(key: "rematch")) {
                                }
                                .buttonStyle(BasicButton(width: 135)).opacity(0.7).disabled(true)
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
                            RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: 110, height: geometry.size.height - 30)
                            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: 110, height: geometry.size.height - 30)
                            ZStack {
                                if !isTutorial {
                                    CustomText(key: winner == 1 ? "won game" : "lost game", fontSize: 16).frame(width: geometry.size.height - 60, height: 80, alignment: .topLeading)
                                } else {
                                    CustomText(text: "rematch if you want to play again", fontSize: 16).frame(width: geometry.size.height - 60, height: 80, alignment: .topLeading)
                                }
                            }
                            .frame(width: 80, height: geometry.size.height - 60).padding(.all, 15).rotationEffect(.degrees(-90))
                        }
                        .padding(.trailing, 65)
                        VStack {
                            HStack(spacing: 5) {
                                Button(Localization.shared.getTranslation(key: "rematch")) {
                                    AudioPlayer.shared.playConfirmSound()
                                    
                                    resetWitches(witches: rightWitches)
                                    resetWitches(witches: leftWitches)
                                    
                                    let fightLogic: FightLogic = FightLogic(players: [Player(id: 0, witches: leftWitches), Player(id: 1, witches: rightWitches)], hasCPUPlayer: true)
                                    
                                    if fightLogic.isValid() {
                                        transitionToggle = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            manager.setView(view: AnyView(TrainingView(fightLogic: fightLogic).environmentObject(manager)))
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

struct TrainingOverView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingOverView(leftWitches: [exampleWitch, exampleWitch], rightWitches: [exampleWitch, exampleWitch, exampleWitch], winner: 0)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
