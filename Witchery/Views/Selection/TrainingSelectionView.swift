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
    
    /// Creates and returns the logic that will be used int the upcoming fight.
    /// - Returns: returns the logic that will be used int the upcoming fight.
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
    
    /// Selects random witches to create a team.
    func selectRandom() {
        let maxSize: Int = min(4, GlobalData.shared.witches.count)
        
        var rndmWitches: [Int] = []
        if GlobalData.shared.teamRestricted {
            var witchSet = Set<Int>()
            
            while witchSet.count < maxSize {
                witchSet.insert(Int.random(in: 0 ..< GlobalData.shared.witches.count))
            }
            
            rndmWitches = Array(witchSet)
        } else {
            while rndmWitches.count < maxSize {
                rndmWitches.append(Int.random(in: 0 ..< GlobalData.shared.witches.count))
            }
        }
        
        var rndmArtifacts: [Int] = []
        switch GlobalData.shared.artifactUse {
            case 0:
                while rndmArtifacts.count < maxSize {
                    rndmArtifacts.append(Int.random(in: 0 ..< Artifacts.allCases.count))
                }
            case 1:
                var artifactSet = Set<Int>()
            
                while artifactSet.count < maxSize {
                    artifactSet.insert(Int.random(in: 0 ..< Artifacts.allCases.count))
                }
                rndmArtifacts = Array(artifactSet)
            default:
                break
        }
        
        for index in 0 ..< maxSize {
            leftWitches[index] = Witch(data: GlobalData.shared.witches[rndmWitches[index]].data)
            if GlobalData.shared.artifactUse != 2 {
                leftWitches[index]?.setArtifact(artifact: rndmArtifacts[index])
            }
        }
    }
    
    /// Checks if selected teams contains atleast one witch.
    /// - Parameter array: The selection of witches to check
    /// - Returns: Returns wether atleast one witch was selected or not
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
                            Button(Localization.shared.getTranslation(key: "randomize")) {
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
            ZigZag().fill(Color("outline")).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -65 : -(geometry.size.height + 65)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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
