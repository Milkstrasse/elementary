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
    
    /// Reset each witch in team to make them ready for a fight.
    /// - Parameter witches: The array of witches that should be reset
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
                                SquareWitchView(witch: witch, isSelected: false, inverted: true)
                            }
                            ForEach(0 ..< 4 - leftWitches.count, id: \.self) { index in
                                SquareWitchView(witch: nil, isSelected: false, inverted: true)
                            }
                        }
                        .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                        Spacer()
                    }
                    ZStack {
                        Rectangle().fill(Color("highlight")).frame(width: 2).padding(.vertical, 15)
                        CustomText(text: "X", fontColor: Color("highlight"), fontSize: largeFontSize, isBold: true).padding(.horizontal, 10).background(Color("background")).rotationEffect(.degrees(90))
                    }
                    .frame(width: 60)
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(rightWitches, id: \.self) { witch in
                                SquareWitchView(witch: witch, isSelected: false, inverted: true)
                            }
                            ForEach(0 ..< 4 - rightWitches.count, id: \.self) { index in
                                SquareWitchView(witch: nil, isSelected: false, inverted: true)
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
                            RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                            ZStack {
                                if !isTutorial {
                                    CustomText(key: winner == 0 ? "won game" : "lost game", fontSize: mediumFontSize).frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 60, height: 80, alignment: .topLeading)
                                } else {
                                    CustomText(key: "tutorial15", fontSize: smallFontSize).frame(width: geometry.size.height - 60, height: 80, alignment: .topLeading)
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
                                .buttonStyle(BasicButton(width: 135, bgColor: Color("health"))).opacity(0.7).disabled(true)
                                Button("X") {
                                    AudioPlayer.shared.playCancelSound()
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                    }
                                }
                                .buttonStyle(BasicButton(width: 40, bgColor: Color("health")))
                            }
                            .rotationEffect(.degrees(90)).frame(width: 40, height: 180)
                        }
                        .padding([.bottom, .leading], 15)
                    }
                    Spacer()
                    ZStack(alignment: .trailing) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(width: 110, height: geometry.size.height - 30)
                            ZStack {
                                if !isTutorial {
                                    CustomText(key: winner == 1 ? "won game" : "lost game", fontSize: mediumFontSize).frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 60, height: 80, alignment: .topLeading)
                                } else {
                                    CustomText(key: "tutorial15", fontSize: smallFontSize).frame(width: geometry.size.height - 60, height: 80, alignment: .topLeading)
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
                                .buttonStyle(BasicButton(width: 135, bgColor: Color("health")))
                                Button("X") {
                                    AudioPlayer.shared.playCancelSound()
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                    }
                                }
                                .buttonStyle(BasicButton(width: 40, bgColor: Color("health")))
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
            ZigZag().fill(Color("panel")).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
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
