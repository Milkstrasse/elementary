//
//  TournamentSelectionView.swift
//  Elementary
//
//  Created by Janice Hablützel on 09.11.22.
//

import SwiftUI

struct TournamentSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    @State var topFighters: [Fighter?] = [nil, nil, nil, nil]
    @State var bottomFighters: [Fighter?] = [nil, nil, nil, nil]
    
    @State var transitionToggle: Bool = true
    
    /// Creates and returns the logic that will be used int the upcoming fight.
    /// - Returns: returns the logic that will be used int the upcoming fight.
    func createLogic() -> FightLogic {
        var tops: [Fighter] = []
        for fighter in topFighters {
            if fighter != nil {
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
        
        return FightLogic(players: [Player(id: 0, fighters: tops), Player(id: 1, fighters: bottoms)], hasCPUPlayer: true)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Image("Pattern").resizable(resizingMode: .tile).frame(height: 175 - geometry.size.width/3.3)
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 0).clipShape(TriangleB()).rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                Spacer()
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 0, y: 0).clipShape(TriangleB())
                Image("Pattern").resizable(resizingMode: .tile).frame(height: 175 - geometry.size.width/3.3)
            }
            VStack {
                TriangleA().fill(Color("MainPanel")).frame(height: 175).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                Spacer()
                TriangleA().fill(Color("MainPanel")).frame(height: 175).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            VStack(spacing: innerPadding) {
                Spacer()
                CPUSelectionView(fighters: topFighters).rotationEffect(.degrees(180))
                CPUSelectionView(fighters: bottomFighters)
                Spacer()
            }
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
                    BasicButton(label: Localization.shared.getTranslation(key: "cancel"), width: 110, height: 35, fontSize: smallFont)
                    Spacer()
                }
                .frame(width: 280 + 3 * innerPadding/2).rotationEffect(.degrees(180))
                Spacer().frame(height: 140 + innerPadding)
                HStack {
                    Button(action: {
                        AudioPlayer.shared.playConfirmSound()
                        let fightLogic: FightLogic = createLogic()
                        
                        if fightLogic.isValid() {
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(TournamentView(fightLogic: fightLogic).environmentObject(manager)))
                            }
                        }
                    }) {
                        BasicButton(label: Localization.shared.getTranslation(key: "ready"), width: 110, height: 35, fontSize: smallFont)
                    }
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
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 100).offset(y: transitionToggle ? -50 : geometry.size.height + 100).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            if TeamManager.isArrayEmpty(array: bottomFighters) {
                topFighters = TeamManager.selectRandom(opponents: bottomFighters)
                bottomFighters = TeamManager.selectRandom(opponents: topFighters)
            } else {
                if topFighters.count < 4 {
                    let missingFighters: Int = 4 - topFighters.count
                    for _ in 0 ..< missingFighters {
                        topFighters.append(nil)
                    }
                }
                
                if bottomFighters.count < 4 {
                    let missingFighters: Int = 4 - bottomFighters.count
                    for _ in 0 ..< missingFighters {
                        bottomFighters.append(nil)
                    }
                }
                
                TeamManager.resetFighters(topFighters: topFighters, bottomFighters: bottomFighters)
            }
        }
    }
}

struct TournamentSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TournamentSelectionView()
    }
}
