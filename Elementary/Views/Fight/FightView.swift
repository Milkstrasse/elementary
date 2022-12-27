//
//  FightView.swift
//  Elementary
//
//  Created by Janice Hablützel on 22.08.22.
//

import SwiftUI

enum Section {
    case summary
    case options
    case spells
    case team
    case waiting
    case info
}

struct FightView: View {
    @EnvironmentObject var manager: ViewManager
    
    let fightLogic: FightLogic
    
    @State var transitionToggle: Bool = true
    
    @State var gameOver: Bool = false
    @State var fightOver: Bool = false
    
    let allowSelection: Bool
    let alwaysRandom: Bool
    let hasCPUPlayer: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 0).clipShape(TriangleB()).rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                Spacer()
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 0).clipShape(TriangleB())
            }
            .padding(.vertical, 175)
            VStack(spacing: 0) {
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[0], height: 175 + geometry.safeAreaInsets.top, gameOver: $gameOver, fightOver: $fightOver, isInteractable: !hasCPUPlayer).rotationEffect(.degrees(180)).ignoresSafeArea()
                Spacer()
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[1], height: 175 + geometry.safeAreaInsets.bottom, gameOver: $gameOver, fightOver: $fightOver, isInteractable: true).ignoresSafeArea()
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).rotationEffect(.degrees(180)).offset(y: transitionToggle ? -50 : -(geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            AudioPlayer.shared.playFightMusic()
            
            transitionToggle = false
        }
        .onChange(of: fightOver) { _ in
            if hasCPUPlayer {
                GlobalData.shared.userProgress.addWin(winner: fightLogic.getWinner(), fighters: fightLogic.players[1].fighters)
                GlobalData.shared.userProgress.checkTeams(teamA: [], teamB: fightLogic.players[1].fighters)
            } else {
                GlobalData.shared.userProgress.addFight()
                GlobalData.shared.userProgress.checkTeams(teamA: fightLogic.players[0].fighters, teamB: fightLogic.players[1].fighters)
            }
            SaveData.saveProgress()
            
            transitionToggle = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                manager.setView(view: AnyView(FightSelectionView(topFighters: fightLogic.players[0].fighters, bottomFighters: fightLogic.players[1].fighters, allowSelection: allowSelection, alwaysRandom: alwaysRandom, hasCPUPlayer: hasCPUPlayer).environmentObject(manager)))
            }
        }
    }
}

struct FightView_Previews: PreviewProvider {
    static var previews: some View {
        FightView(fightLogic: FightLogic(players: [Player(id: 0, fighters: [GlobalData.shared.fighters[0]]), Player(id: 1, fighters: [GlobalData.shared.fighters[0]])]), allowSelection: true, alwaysRandom: false, hasCPUPlayer: false)
    }
}
