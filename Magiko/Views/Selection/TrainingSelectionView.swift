//
//  TrainingSelectionView.swift
//  Magiko
//
//  Created by Janice Hablützel on 15.01.22.
//

import SwiftUI

struct TrainingSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    @State var leftFighters: [Fighter?] = [nil, nil, nil, nil]
    @State var rightFighters: [Fighter?] = [nil, nil, nil, nil]
    
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
        
        return FightLogic(leftFighters: lefts, rightFighters: rights, hasCPUPlayer: true)
    }
    
    func selectRandom() {
        var set = Set<Int>()
        while set.count < 4 {
            set.insert(Int.random(in: 0 ..< GlobalData.shared.fighters.count))
        }
        
        let rndm: [Int] = Array(set)
        
        for index in 0 ..< 4 {
            leftFighters[index] = Fighter(data: GlobalData.shared.fighters[rndm[index]].data)
            leftFighters[index]?.setAbility(ability: Int.random(in: 0 ..< Abilities.allCases.count))
        }
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
                            Button("randomize") {
                                AudioPlayer.shared.playStandardSound()
                                selectRandom()
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
                        .rotationEffect(.degrees(90)).frame(width: 40, height: 170)
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
                                        manager.setView(view: AnyView(TrainingView(fightLogic: fightLogic).environmentObject(manager)))
                                    }
                                }
                            }
                            .buttonStyle(BasicButton(width: 135)).disabled(isArrayEmpty(array: rightFighters))
                            Button("X") {
                                AudioPlayer.shared.playCancelSound()
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
                .padding(.all, 15).ignoresSafeArea(.all, edges: .bottom)
                HStack(spacing: 0) {
                    CPUSelectionView(fighters: leftFighters)
                    CustomText(text: "------- X -------").rotationEffect(.degrees(90)).frame(width: 60)
                    RightSelectionView(fighters: $rightFighters)
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
            GeometryReader { geometry in
                ZigZag().fill(Color("outline")).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
                    .offset(y: transitionToggle ? -65 : -(geometry.size.height + 65)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
            }
        }
        .onAppear {
            transitionToggle = false
            selectRandom()
        }
    }
}

struct TrainingSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingSelectionView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
