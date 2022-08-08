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
    
    let topWitches: [Witch]
    let bottomWitches: [Witch]
    
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
            VStack(spacing: 0) {
                HStack(spacing: 5) {
                    Spacer()
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
                    .buttonStyle(BasicButton(width: 45))
                }
                .rotationEffect(.degrees(180))
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(height: 110)
                    ZStack {
                        CustomText(key: "won game", fontSize: mediumFontSize).frame(width: geometry.size.width - 60, height: 80, alignment: .topLeading)
                    }
                    .frame(height: 80).padding(.all, 15)
                }
                .padding(.bottom, 10).rotationEffect(.degrees(180))
                Spacer()
                HStack {
                    Spacer()
                    ForEach(topWitches, id: \.self) { witch in
                        SquareWitchView(witch: witch, isSelected: false, inverted: true)
                    }
                    ForEach(0 ..< 4 - topWitches.count, id:  \.self) { index in
                        SquareWitchView(witch: nil, isSelected: false, inverted: true)
                    }
                    Spacer()
                }
                .rotationEffect(.degrees(180))
                ZStack {
                    Rectangle().fill(Color("highlight")).frame(height: 2)
                    CustomText(text: "X", fontColor: Color("highlight"), fontSize: largeFontSize, isBold: true).padding(.horizontal, 10).background(Color.purple)
                }
                .padding(.all, 15)
                HStack {
                    Spacer()
                    ForEach(bottomWitches, id: \.self) { witch in
                        SquareWitchView(witch: witch, isSelected: false, inverted: true)
                    }
                    ForEach(0 ..< 4 - bottomWitches.count, id:  \.self) { index in
                        SquareWitchView(witch: nil, isSelected: false, inverted: true)
                    }
                    Spacer()
                }
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(height: 110)
                    ZStack {
                        if !isTutorial {
                            CustomText(key: winner == 1 ? "won game" : "lost game", fontSize: mediumFontSize).frame(width: geometry.size.width - 60, height: 80, alignment: .topLeading)
                        } else {
                            CustomText(key: "tutorial15", fontSize: smallFontSize).frame(width: geometry.size.width - 60, height: 80, alignment: .topLeading)
                        }
                    }
                    .frame(height: 80).padding(.all, 15)
                }
                .padding(.bottom, 10)
                HStack(spacing: 5) {
                    Spacer()
                    Button(Localization.shared.getTranslation(key: "rematch")) {
                        AudioPlayer.shared.playConfirmSound()
                        
                        resetWitches(witches: topWitches)
                        resetWitches(witches: bottomWitches)
                        
                        let fightLogic: FightLogic = FightLogic(players: [Player(id: 0, witches: topWitches), Player(id: 1, witches: bottomWitches)], hasCPUPlayer: true)
                        
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
                    .buttonStyle(BasicButton(width: 45))
                }
            }
            .padding(.all, 15)
            ZigZag().fill(Color("panel")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 65).rotationEffect(.degrees(180)).offset(y: transitionToggle ? 0 : -geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            AudioPlayer.shared.playMenuMusic()
            transitionToggle = false
        }
    }
}

struct TrainingOverView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingOverView(topWitches: [exampleWitch, exampleWitch], bottomWitches: [exampleWitch, exampleWitch, exampleWitch], winner: 0)
    }
}
