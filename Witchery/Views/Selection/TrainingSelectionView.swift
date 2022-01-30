//
//  TrainingSelectionView.swift
//  Witchery
//
//  Created by Janice Hablützel on 15.01.22.
//

import SwiftUI

struct TrainingSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    @State var leftWitches: [Witch?] = [nil, nil, nil, nil]
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
    
    func selectRandom() {
        var set = Set<Int>()
        let maxSize: Int = min(4, GlobalData.shared.witches.count)
        print("\(maxSize)")
        
        while set.count < maxSize {
            set.insert(Int.random(in: 0 ..< GlobalData.shared.witches.count))
        }
        
        let rndm: [Int] = Array(set)
        
        for index in 0 ..< maxSize {
            leftWitches[index] = Witch(data: GlobalData.shared.witches[rndm[index]].data)
            leftWitches[index]?.setArtifact(artifact: Int.random(in: 0 ..< Artifacts.allCases.count))
        }
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
                                        manager.setView(view: AnyView(TrainingView(fightLogic: fightLogic).environmentObject(manager)))
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
                    CPUSelectionView(witches: leftWitches)
                    ZStack {
                        Rectangle().fill(Color("outline")).frame(width: 1).padding(.vertical, 15)
                        CustomText(text: "X", fontSize: 18).padding(.horizontal, 10).background(Color("background")).rotationEffect(.degrees(90))
                    }
                    .frame(width: 60)
                    RightSelectionView(witches: $rightWitches)
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
