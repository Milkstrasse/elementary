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
    
    let topWitches: [Witch]
    let bottomWitches: [Witch]
    
    let winner: Int
    
    @State var topReady: Bool = false
    @State var bottomReady: Bool = false
    
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
                    Button(topReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "rematch")) {
                        if !topReady {
                            AudioPlayer.shared.playConfirmSound()
                        } else {
                            AudioPlayer.shared.playCancelSound()
                        }
                        
                        topReady = !topReady
                        gameLogic.setReady(player: 0, ready: topReady)
                        
                        if gameLogic.areBothReady() {
                            let fightLogic: FightLogic = FightLogic(players: [Player(id: 0, witches: topWitches), Player(id: 1, witches: bottomWitches)])
                            
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
                    .buttonStyle(BasicButton(width: 45))
                }
                .rotationEffect(.degrees(180))
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(height: 110)
                    ZStack {
                        CustomText(key: winner == 0 ? "won game" : "lost game", fontSize: mediumFontSize).frame(width: geometry.size.width - 60, height: 80, alignment: .topLeading)
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
                    ForEach(0 ..< 4 - topWitches.count, id:\.self) { index in
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
                    ForEach(0 ..< 4 - bottomWitches.count, id:\.self) { index in
                        SquareWitchView(witch: nil, isSelected: false, inverted: true)
                    }
                    Spacer()
                }
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(height: 110)
                    ZStack {
                        CustomText(key: winner == 1 ? "won game" : "lost game", fontSize: mediumFontSize).frame(width: geometry.size.width - 60, height: 80, alignment: .topLeading)
                    }
                    .frame(height: 80).padding(.all, 15)
                }
                .padding(.bottom, 10)
                HStack(spacing: 5) {
                    Spacer()
                    Button(bottomReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "rematch")) {
                        if !bottomReady {
                            AudioPlayer.shared.playConfirmSound()
                        } else {
                            AudioPlayer.shared.playCancelSound()
                        }
                        
                        bottomReady = !bottomReady
                        gameLogic.setReady(player: 1, ready: bottomReady)
                        
                        if gameLogic.areBothReady() {
                            let fightLogic: FightLogic = FightLogic(players: [Player(id: 0, witches: topWitches), Player(id: 1, witches: bottomWitches)])
                            
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

struct FightOverView_Previews: PreviewProvider {
    static var previews: some View {
        FightOverView(topWitches: [exampleWitch, exampleWitch], bottomWitches: [exampleWitch, exampleWitch, exampleWitch], winner: 0)
    }
}
