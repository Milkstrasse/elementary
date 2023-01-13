//
//  FightSelectionView.swift
//  Elementary
//
//  Created by Janice Hablützel on 21.08.22.
//

import SwiftUI

struct FightSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic(fullAmount: 8)
    
    @State var topFighters: [Fighter?] = [nil, nil, nil, nil]
    @State var bottomFighters: [Fighter?] = [nil, nil, nil, nil]
    
    @State var topReady: Bool = false
    @State var bottomReady: Bool = false
    
    let singleMode: Bool
    let alwaysRandom: Bool
    let hasCPUPlayer: Bool
    
    @State var transitionToggle: Bool = true
    
    /// Creates and returns the logic that will be used int the upcoming fight.
    /// - Returns: returns the logic that will be used int the upcoming fight.
    func createLogic() -> FightLogic {
        var tops: [Fighter] = []
        for fighter in topFighters {
            if fighter != nil {
                if GlobalData.shared.artifactUse == 2 {
                    fighter?.setArtifact(artifact: 0)
                }
                tops.append(fighter!)
            }
        }
        
        var bottoms: [Fighter] = []
        for fighter in bottomFighters {
            if fighter != nil {
                if GlobalData.shared.artifactUse == 2 {
                    fighter?.setArtifact(artifact: 0)
                }
                bottoms.append(fighter!)
            }
        }
        
        return FightLogic(players: [Player(id: 0, fighters: tops), Player(id: 1, fighters: bottoms)], hasCPUPlayer: hasCPUPlayer, singleMode: singleMode)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Image("Pattern").resizable(resizingMode: .tile).frame(height: 175 - geometry.size.width/3.3 + geometry.safeAreaInsets.top)
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 0).clipShape(TriangleB()).rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                Spacer()
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 0, y: 0).clipShape(TriangleB())
                Image("Pattern").resizable(resizingMode: .tile).frame(height: 175 - geometry.size.width/3.3 + geometry.safeAreaInsets.bottom)
            }
            .ignoresSafeArea()
            VStack {
                TriangleA().fill(Color("MainPanel")).frame(height: 175 + geometry.safeAreaInsets.top).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                Spacer()
                TriangleA().fill(Color("MainPanel")).frame(height: 175 + geometry.safeAreaInsets.bottom).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .ignoresSafeArea()
            VStack(spacing: innerPadding/2) {
                HStack(spacing: innerPadding) {
                    Spacer()
                    Button(action: {
                        AudioPlayer.shared.playCancelSound()
                        
                        transitionToggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            manager.setView(view: AnyView(ModeSelectionView().environmentObject(manager)))
                        }
                    }) {
                        IconButton(label: "\u{f00d}")
                    }
                }
                .rotationEffect(.degrees(180))
                Spacer()
                HStack {
                    Button(action: {
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
                                    manager.setView(view: AnyView(FightView(fightLogic: fightLogic, singleMode: singleMode, alwaysRandom:  alwaysRandom, hasCPUPlayer: hasCPUPlayer).environmentObject(manager)))
                                }
                            }
                        }
                    }) {
                        BasicButton(label: topReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "ready"), width: 110, height: 35, fontSize: smallFont)
                    }
                    .disabled(!TeamManager.isTeamValid(array: topFighters, singleMode: singleMode) || hasCPUPlayer)
                    Spacer()
                }
                .frame(width: 280 + 3 * innerPadding/2).rotationEffect(.degrees(180))
                Spacer().frame(height: 140 + innerPadding)
                HStack {
                    Button(action: {
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
                                    manager.setView(view: AnyView(FightView(fightLogic: fightLogic, singleMode: singleMode, alwaysRandom: alwaysRandom, hasCPUPlayer: hasCPUPlayer).environmentObject(manager)))
                                }
                            }
                        }
                    }) {
                        BasicButton(label: bottomReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "ready"), width: 110, height: 35, fontSize: smallFont)
                    }
                    .disabled(!TeamManager.isTeamValid(array: bottomFighters, singleMode: singleMode))
                    Spacer()
                }
                .frame(width: 280 + 3 * innerPadding/2)
                Spacer()
                HStack(spacing: innerPadding) {
                    Spacer()
                    Button(action: {
                        AudioPlayer.shared.playCancelSound()
                        
                        transitionToggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            manager.setView(view: AnyView(ModeSelectionView().environmentObject(manager)))
                        }
                    }) {
                        IconButton(label: "\u{f00d}")
                    }
                }
            }
            .padding(.all, outerPadding)
            VStack(spacing: innerPadding/2) {
                if hasCPUPlayer {
                    CPUSelectionView(fighters: topFighters).rotationEffect(.degrees(180)).ignoresSafeArea()
                } else {
                    PlayerSelectionView(opponents: bottomFighters, fighters: $topFighters, height: geometry.safeAreaInsets.top + 175, singleMode: singleMode, offset: geometry.safeAreaInsets.top + 175).frame(width: geometry.size.width).rotationEffect(.degrees(180)).ignoresSafeArea()
                }
                PlayerSelectionView(opponents: topFighters, fighters: $bottomFighters, height: geometry.safeAreaInsets.bottom + 175, singleMode: singleMode, offset: geometry.safeAreaInsets.bottom + 175).frame(width: geometry.size.width).ignoresSafeArea()
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).offset(y: transitionToggle ? -50 : geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            if hasCPUPlayer {
                topReady = true
                gameLogic.setReady(player: 0, ready: topReady)
            }
            
            if !TeamManager.isArrayEmpty(array: bottomFighters) {
                if alwaysRandom {
                    topFighters = TeamManager.selectRandom(opponents: bottomFighters)
                } else {
                    if topFighters.count < 4 {
                        let missingFighters: Int = 4 - topFighters.count
                        for _ in 0 ..< missingFighters {
                            topFighters.append(nil)
                        }
                    }
                }
                
                if bottomFighters.count < 4 {
                    let missingFighters: Int = 4 - bottomFighters.count
                    for _ in 0 ..< missingFighters {
                        bottomFighters.append(nil)
                    }
                }
                
                TeamManager.resetFighters(topFighters: topFighters, bottomFighters: bottomFighters)
            } else if hasCPUPlayer {
                topFighters = TeamManager.selectRandom(opponents: bottomFighters)
            }
        }
    }
}

struct FightSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FightSelectionView(singleMode: true, alwaysRandom: false, hasCPUPlayer: false)
    }
}
