//
//  FightSelectionView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct FightSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    @State var leftFighters: [Fighter?] = [nil, nil, nil, nil]
    @State var rightFighters: [Fighter?] = [nil, nil, nil, nil]
    
    @State var leftReady: Bool = false
    @State var rightReady: Bool = false
    
    @State var transitionToggle: Bool = true
    
    func createLogic() -> FightLogic {
        var lefts: [Fighter] = []
        for fighter in leftFighters {
            if fighter != nil {
                lefts.append(fighter!)
            }
        }
        
        var rights: [Fighter] = []
        for fighter in rightFighters {
            if fighter != nil {
                rights.append(fighter!)
            }
        }
        
        return FightLogic(leftFighters: lefts, rightFighters: rights)
    }
    
    func isArrayEmpty(array: [Fighter?]) -> Bool {
        for fighter in array {
            if fighter != nil {
                return false
            }
        }
        
        return true
    }
    
    var body: some View {
        ZStack {
            ZStack {
                HStack(spacing: 0) {
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            Button(leftReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "ready")) {
                                leftReady = !leftReady
                                gameLogic.setReady(player: 0, ready: leftReady)
                                
                                if gameLogic.areBothReady() {
                                    let fightLogic: FightLogic = createLogic()
                                    
                                    if fightLogic.isValid() {
                                        transitionToggle = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            manager.setView(view: AnyView(FightView(fightLogic: fightLogic).environmentObject(manager)))
                                        }
                                    }
                                }
                            }
                            .buttonStyle(BasicButton(width: 135)).disabled(isArrayEmpty(array: leftFighters))
                            Button("X") {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                }
                            }
                            .buttonStyle(BasicButton(width: 40))
                        }
                        .rotationEffect(.degrees(90)).frame(width: 40, height: 170)
                    }
                    Spacer()
                    VStack {
                        HStack(spacing: 5) {
                            Button(rightReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "ready")) {
                                rightReady = !rightReady
                                gameLogic.setReady(player: 1, ready: rightReady)
                                
                                if gameLogic.areBothReady() {
                                    let fightLogic: FightLogic = createLogic()
                                    
                                    if fightLogic.isValid() {
                                        transitionToggle = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            manager.setView(view: AnyView(FightView(fightLogic: fightLogic).environmentObject(manager)))
                                        }
                                    }
                                }
                            }
                            .buttonStyle(BasicButton(width: 135)).disabled(isArrayEmpty(array: rightFighters))
                            Button("X") {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                }
                            }
                            .buttonStyle(BasicButton(width: 40))
                        }
                        .rotationEffect(.degrees(-90)).frame(width: 40, height: 170)
                        Spacer()
                    }
                }
                .padding(.all, 15).edgesIgnoringSafeArea(.bottom)
                HStack(spacing: 0) {
                    LeftSelectionView(fighters: $leftFighters).disabled(leftReady)
                    CustomText(text: "------- X -------").rotationEffect(.degrees(90)).frame(width: 60)
                    RightSelectionView(fighters: $rightFighters).disabled(rightReady)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            GeometryReader { geometry in
                ZigZag().fill(Color("outline")).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
                    .offset(y: transitionToggle ? -65 : -(geometry.size.height + 65)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
            }
        }
        .onAppear {
            transitionToggle = false
        }
    }
}

struct FightSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FightSelectionView()
.previewInterfaceOrientation(.landscapeRight)
    }
}
