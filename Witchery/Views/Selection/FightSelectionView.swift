//
//  FightSelectionView.swift
//  Witchery
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct FightSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    @State var leftWitches: [Witch?] = [nil, nil, nil, nil]
    @State var rightWitches: [Witch?] = [nil, nil, nil, nil]
    
    @State var leftReady: Bool = false
    @State var rightReady: Bool = false
    
    @State var transitionToggle: Bool = true
    
    /// Creates and returns the logic that will be used int the upcoming fight.
    /// - Returns: returns the logic that will be used int the upcoming fight.
    func createLogic() -> FightLogic {
        var lefts: [Witch] = []
        for witch in leftWitches {
            if witch != nil {
                if GlobalData.shared.artifactUse == 2 {
                    witch?.setArtifact(artifact: 0)
                }
                lefts.append(witch!)
            }
        }
        
        var rights: [Witch] = []
        for witch in rightWitches {
            if witch != nil {
                if GlobalData.shared.artifactUse == 2 {
                    witch?.setArtifact(artifact: 0)
                }
                rights.append(witch!)
            }
        }
        
        return FightLogic(players: [Player(id: 0, witches: lefts), Player(id: 1, witches: rights)])
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
                            Button(leftReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "ready")) {
                                if !leftReady {
                                    AudioPlayer.shared.playConfirmSound()
                                } else {
                                    AudioPlayer.shared.playCancelSound()
                                }
                                
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
                            .buttonStyle(BasicButton(width: 135, bgColor: Color("health"))).opacity(isArrayEmpty(array: leftWitches) ? 0.7 : 1.0).disabled(isArrayEmpty(array: leftWitches))
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
                    Spacer()
                    VStack {
                        HStack(spacing: 5) {
                            Button(rightReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "ready")) {
                                if !rightReady {
                                    AudioPlayer.shared.playConfirmSound()
                                } else {
                                    AudioPlayer.shared.playCancelSound()
                                }
                                
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
                            .buttonStyle(BasicButton(width: 135, bgColor: Color("health"))).opacity(isArrayEmpty(array: rightWitches) ? 0.7 : 1.0).disabled(isArrayEmpty(array: rightWitches))
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
                }
                .padding(.all, 15).ignoresSafeArea(.all, edges: .bottom)
                HStack(spacing: 0) {
                    PlayerSelectionView(witches: $leftWitches, isLeft: true).disabled(leftReady)
                    ZStack {
                        Rectangle().fill(Color("highlight")).frame(width: 2).padding(.vertical, 15)
                        CustomText(text: "X", fontColor: Color("highlight"), fontSize: largeFontSize, isBold: true).padding(.horizontal, 10).background(Color("background")).rotationEffect(.degrees(90))
                    }
                    .frame(width: 60)
                    PlayerSelectionView(witches: $rightWitches, isLeft: false).disabled(rightReady)
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
            ZigZag().fill(Color("panel")).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -65 : -(geometry.size.height + 65)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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
