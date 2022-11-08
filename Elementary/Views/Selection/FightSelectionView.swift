//
//  FightSelectionView.swift
//  Elementary
//
//  Created by Janice Hablützel on 21.08.22.
//

import SwiftUI

struct FightSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    @State var topFighters: [Fighter?] = [nil, nil, nil, nil]
    @State var bottomFighters: [Fighter?] = [nil, nil, nil, nil]
    
    @State var topReady: Bool = false
    @State var bottomReady: Bool = false
    
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
        
        return FightLogic(players: [Player(id: 0, fighters: tops), Player(id: 1, fighters: bottoms)])
    }
    
    /// Checks if selected teams contains atleast one fighter.
    /// - Parameter array: The selection of fighters to check
    /// - Returns: Returns wether atleast one fighter was selected or not
    func isArrayEmpty(array: [Fighter?]) -> Bool {
        for fighter in array {
            if fighter != nil {
                return false
            }
        }
        
        return true
    }
    
    /// Reset each fighter in both teams to make them ready for a fight.
    func resetFighters() {
        for fighter in topFighters {
            fighter?.reset()
        }
        
        for fighter in bottomFighters {
            fighter?.reset()
        }
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
            VStack(spacing: innerPadding/2) {
                HStack(spacing: innerPadding) {
                    Spacer()
                    Button(action: {
                        AudioPlayer.shared.playCancelSound()
                        
                        transitionToggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            manager.setView(view: AnyView(MainView(currentFighter: GlobalData.shared.getRandomFighter()).environmentObject(manager)))
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
                                    manager.setView(view: AnyView(FightView(fightLogic: fightLogic).environmentObject(manager)))
                                }
                            }
                        }
                    }) {
                        BasicButton(label: topReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "ready"), width: 110, height: 35, fontSize: smallFont)
                    }
                    .disabled(isArrayEmpty(array: topFighters))
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
                                    manager.setView(view: AnyView(FightView(fightLogic: fightLogic).environmentObject(manager)))
                                }
                            }
                        }
                    }) {
                        BasicButton(label: bottomReady ? Localization.shared.getTranslation(key: "cancel") : Localization.shared.getTranslation(key: "ready"), width: 110, height: 35, fontSize: smallFont)
                    }
                    .disabled(isArrayEmpty(array: bottomFighters))
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
                            manager.setView(view: AnyView(MainView(currentFighter: GlobalData.shared.getRandomFighter()).environmentObject(manager)))
                        }
                    }) {
                        IconButton(label: "\u{f00d}")
                    }
                }
            }
            .padding(.all, outerPadding)
            VStack(spacing: innerPadding/2) {
                PlayerSelectionView(opponents: bottomFighters, fighters: $topFighters).frame(width: geometry.size.width).rotationEffect(.degrees(180))
                PlayerSelectionView(opponents: topFighters, fighters: $bottomFighters).frame(width: geometry.size.width)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            if !isArrayEmpty(array: bottomFighters) {
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
                
                resetFighters()
            }
        }
    }
}

struct FightSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FightSelectionView()
    }
}
