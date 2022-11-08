//
//  TrainingSelectionView.swift
//  Elementary
//
//  Created by Janice Hablützel on 22.08.22.
//

import SwiftUI

struct TrainingSelectionView: View {
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
    
    /// Selects random fighters to create a team.
    func selectRandom() {
        //let maxSize: Int = min(4, GlobalData.shared.fighters.count)
        let maxSize: Int = 4
        
        var rndmFighters: [Int] = []
        switch GlobalData.shared.teamLimit {
        case 1:
            var fighterSet = Set<Int>()
            
            while fighterSet.count < maxSize {
                fighterSet.insert(Int.random(in: 0 ..< GlobalData.shared.fighters.count))
            }
            
            rndmFighters = Array(fighterSet)
        case 2:
            topFighters = []
            while topFighters.count < maxSize {
                let rndmFighter: Fighter = GlobalData.shared.fighters[Int.random(in: 0 ..< GlobalData.shared.fighters.count)]
                
                var fighterFound: Bool = false
                for fighter in topFighters {
                    if fighter?.name == rndmFighter.name {
                        fighterFound = true
                        break
                    }
                }
                
                if !fighterFound {
                    for opponent in bottomFighters {
                        if opponent?.name == rndmFighter.name {
                            fighterFound = true
                            break
                        }
                    }
                    
                    if !fighterFound {
                        topFighters.append(rndmFighter)
                    }
                }
            }
        default:
            while rndmFighters.count < maxSize {
                rndmFighters.append(Int.random(in: 0 ..< GlobalData.shared.fighters.count))
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
            if !rndmFighters.isEmpty {
                topFighters[index] = SavedFighterData(fighter: GlobalData.shared.fighters[rndmFighters[index]]).toFighter() //make copy
            }
            
            if GlobalData.shared.artifactUse != 2 {
                topFighters[index]?.setArtifact(artifact: rndmArtifacts[index])
            }
        }
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
                Image("Pattern").resizable(resizingMode: .tile).frame(height: 175 - geometry.size.width/6.5)
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 20).clipShape(TriangleB()).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                Spacer()
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 35, y: 2).clipShape(TriangleB()).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                Image("Pattern").resizable(resizingMode: .tile).frame(height: 175 - geometry.size.width/6.5)
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
                                manager.setView(view: AnyView(TrainingView(fightLogic: fightLogic).environmentObject(manager)))
                            }
                        }
                    }) {
                        BasicButton(label: Localization.shared.getTranslation(key: "ready"), width: 110, height: 35, fontSize: smallFont)
                    }
                    .disabled(isArrayEmpty(array: bottomFighters))
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
            VStack(spacing: innerPadding) {
                CPUSelectionView(fighters: topFighters).rotationEffect(.degrees(180))
                PlayerSelectionView(opponents: topFighters, fighters: $bottomFighters)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            if isArrayEmpty(array: bottomFighters) {
                selectRandom()
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
                
                resetFighters()
            }
        }
    }
}

struct TrainingSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingSelectionView()
    }
}
