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
    
    @State var topWitches: [Witch?] = [nil, nil, nil, nil]
    @State var bottomWitches: [Witch?] = [nil, nil, nil, nil]
    
    @State var topReady: Bool = false
    @State var bottomReady: Bool = false
    
    @State var transitionToggle: Bool = true
    
    /// Creates and returns the logic that will be used int the upcoming fight.
    /// - Returns: returns the logic that will be used int the upcoming fight.
    func createLogic() -> FightLogic {
        var tops: [Witch] = []
        for witch in topWitches {
            if witch != nil {
                if GlobalData.shared.artifactUse == 2 {
                    witch?.setArtifact(artifact: 0)
                }
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
        
        return FightLogic(players: [Player(id: 0, witches: tops), Player(id: 1, witches: bottoms)])
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
                    Button(topReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "ready")) {
                        if !topReady {
                            AudioPlayer.shared.playConfirmSound()
                        } else {
                            AudioPlayer.shared.playCancelSound()
                        }
                        
                        topReady = !topReady
                        gameLogic.setReady(player: 0, ready: topReady)
                        
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
                    Button(bottomReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "ready")) {
                        if !bottomReady {
                            AudioPlayer.shared.playConfirmSound()
                        } else {
                            AudioPlayer.shared.playCancelSound()
                        }
                        
                        bottomReady = !bottomReady
                        gameLogic.setReady(player: 1, ready: bottomReady)
                        
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
                PlayerSelectionView(witches: $topWitches, isTop: true).disabled(topReady)
                ZStack {
                    Rectangle().fill(Color("highlight")).frame(height: 2)
                    CustomText(text: "X", fontColor: Color("highlight"), fontSize: largeFontSize, isBold: true).padding(.horizontal, 10).background(Color.purple)
                }
                .padding(.all, 15)
                PlayerSelectionView(witches: $bottomWitches, isTop: false).disabled(bottomReady)
            }
            ZigZag().fill(Color("panel")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 65).rotationEffect(.degrees(180)).offset(y: transitionToggle ? 0 : -geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
        }
    }
}

struct FightSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FightSelectionView()
    }
}
