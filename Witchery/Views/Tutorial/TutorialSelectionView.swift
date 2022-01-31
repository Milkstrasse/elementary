//
//  TutorialSelectionView.swift
//  Witchery
//
//  Created by Janice Hablützel on 31.01.22.
//

import SwiftUI

struct TutorialSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    @State var tutorialCounter: Int = 0
    
    @State var leftWitches: [Witch?] = [exampleWitch, nil, nil, nil]
    @State var rightWitches: [Witch?] = [nil, nil, nil, nil]
    
    @State var transitionToggle: Bool = true
    
    func createLogic() -> FightLogic {
        var lefts: [Witch] = []
        for witch in leftWitches {
            if witch != nil {
                lefts.append(witch!)
            }
        }
        
        var rights: [Witch] = []
        for witch in rightWitches {
            if witch != nil {
                rights.append(witch!)
            }
        }
        
        return FightLogic(players: [Player(id: 0, witches: lefts), Player(id: 1, witches: rights)], hasCPUPlayer: true)
    }
    
    func isArrayEmpty(array: [Witch?]) -> Bool {
        for witch in array {
            if witch != nil {
                return false
            }
        }
        
        return true
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            Button(Localization.shared.getTranslation(key: "cancel")) {
                            }
                            .buttonStyle(BasicButton(width: 135)).disabled(true)
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
                    Spacer()
                    VStack {
                        HStack(spacing: 5) {
                            Button(Localization.shared.getTranslation(key: "ready")) {
                                AudioPlayer.shared.playConfirmSound()
                                let fightLogic: FightLogic = createLogic()
                                
                                if fightLogic.isValid() {
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(TutorialFightView(fightLogic: fightLogic).environmentObject(manager)))
                                    }
                                }
                            }
                            .buttonStyle(BasicButton(width: 135)).opacity(isArrayEmpty(array: rightWitches) ? 0.7 : 1.0).disabled(isArrayEmpty(array: rightWitches))
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
                }
                .padding(.all, 15).ignoresSafeArea(.all, edges: .bottom)
                HStack(spacing: 0) {
                    ZStack {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                HStack(spacing: 5) {
                                    ForEach(0 ..< 4) { index in
                                        SquareWitchView(witch: leftWitches[index], isSelected: false)
                                    }
                                }
                                .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                                Spacer()
                            }
                        }
                    }
                    ZStack {
                        Rectangle().fill(Color("outline")).frame(width: 1).padding(.vertical, 15)
                        CustomText(text: "X", fontSize: 18).padding(.horizontal, 10).background(Color("background")).rotationEffect(.degrees(90))
                    }
                    .frame(width: 60)
                    TutorialRightSelectionView(witches: $rightWitches, tutorialCounter: $tutorialCounter)
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
            ZigZag().fill(Color("outline")).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -65 : -(geometry.size.height + 65)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
        }
    }
}

struct TutorialSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialSelectionView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
