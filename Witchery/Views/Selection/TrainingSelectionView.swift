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
    
    @State var topWitches: [Witch?] = [nil, nil, nil, nil]
    @State var bottomWitches: [Witch?] = [nil, nil, nil, nil]
    
    @State var transitionToggle: Bool = true
    
    /// Creates and returns the logic that will be used int the upcoming fight.
    /// - Returns: returns the logic that will be used int the upcoming fight.
    func createLogic() -> FightLogic {
        var tops: [Witch] = []
        for witch in topWitches {
            if witch != nil {
                tops.append(witch!)
            }
        }
        
        var bottoms: [Witch] = []
        for witch in bottomWitches {
            if witch != nil {
                if GlobalData.shared.artifactUse == 2 {
                    witch?.setArtifact(artifact: 0)
                }
                bottoms.append(witch!)
            }
        }
        
        return FightLogic(players: [Player(id: 0, witches: tops), Player(id: 1, witches: bottoms)], hasCPUPlayer: true)
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
            topWitches[index] = Witch(data: GlobalData.shared.witches[rndmWitches[index]].data)
            if GlobalData.shared.artifactUse != 2 {
                topWitches[index]?.setArtifact(artifact: rndmArtifacts[index])
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
            VStack(spacing: 0) {
                HStack(spacing: 5) {
                    Spacer()
                    Button(Localization.shared.getTranslation(key: "randomize")) {
                        AudioPlayer.shared.playStandardSound()
                        selectRandom()
                    }
                    .buttonStyle(BasicButton(width: 135)).opacity(isArrayEmpty(array: topWitches) ? 0.7 : 1.0).disabled(isArrayEmpty(array: topWitches))
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
                Spacer()
                HStack(spacing: 5) {
                    Spacer()
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
                    .buttonStyle(BasicButton(width: 135)).opacity(isArrayEmpty(array: bottomWitches) ? 0.7 : 1.0).disabled(isArrayEmpty(array: bottomWitches))
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
            VStack(spacing: 0) {
                CPUSelectionView(witches: topWitches)
                ZStack {
                    Rectangle().fill(Color("highlight")).frame(height: 2)
                    CustomText(text: "X", fontColor: Color("highlight"), fontSize: largeFontSize, isBold: true).padding(.horizontal, 10).background(Color.purple)
                }
                .padding(.all, 15)
                PlayerSelectionView(witches: $bottomWitches, isTop: false)
            }
            ZigZag().fill(Color("panel")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 65).rotationEffect(.degrees(180)).offset(y: transitionToggle ? 0 : -geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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
    }
}
