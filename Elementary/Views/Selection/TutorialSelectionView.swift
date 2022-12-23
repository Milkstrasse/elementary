//
//  TutorialSelectionView.swift
//  Elementary
//
//  Created by Janice Hablützel on 22.12.22.
//

import SwiftUI

struct TutorialSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    @State var topFighters: [Fighter?] = [nil, nil, nil, nil]
    @State var bottomFighters: [Fighter?] = [nil, nil, nil, nil]
    
    @State var tutorialCounter: Int = 0
    @State var blinking: Bool = false
    
    @State var transitionToggle: Bool = true
    
    let blinkAnimation = Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)
    
    /// Creates and returns the logic that will be used int the upcoming fight.
    /// - Returns: returns the logic that will be used int the upcoming fight.
    func createLogic() -> FightLogic {
        var tops: [Fighter] = []
        for fighter in topFighters {
            if fighter != nil {
                tops.append(fighter!)
            }
        }
        
        bottomFighters[1] = SavedFighterData(fighter: plantFighter).toFighter(images: plantFighter.images)
        
        var bottoms: [Fighter] = []
        for fighter in bottomFighters {
            if fighter != nil {
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
                                manager.setView(view: AnyView(TutorialView(fightLogic: fightLogic).environmentObject(manager)))
                            }
                        }
                    }) {
                        BasicButton(label: Localization.shared.getTranslation(key: "ready"), width: 110, height: 35, fontSize: smallFont).opacity(blinking && tutorialCounter == 11 ? 0.4 : 1)
                    }
                    .disabled(TeamManager.isArrayEmpty(array: bottomFighters) || tutorialCounter < 11)
                    .onChange(of: tutorialCounter) { newValue in
                        if newValue == 11 {
                            blinking = false
                            withAnimation(blinkAnimation) {
                                blinking = true
                            }
                        }
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
            VStack(spacing: innerPadding) {
                CPUSelectionView(fighters: topFighters).rotationEffect(.degrees(180))
                TutorialPlayerSelectionView(opponents: topFighters, fighters: $bottomFighters, tutorialCounter: $tutorialCounter)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 100).offset(y: transitionToggle ? -50 : geometry.size.height + 100).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            topFighters = [waterFighter, nil, nil, nil]
        }
    }
}

struct TutorialSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialSelectionView()
    }
}
