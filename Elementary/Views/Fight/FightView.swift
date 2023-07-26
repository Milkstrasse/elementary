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
    case targeting
}

struct FightView: View {
    @EnvironmentObject var manager: ViewManager
    
    @ObservedObject var fightLogic: FightLogic
    
    @State var transitionToggle: Bool = true
    
    @State var gameOver: Bool = false
    @State var fightOver: Bool = false
    
    let singleMode: Bool
    let alwaysRandom: Bool
    let hasCPUPlayer: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Color(hex: fightLogic.weather?.element.color ?? "#FF42A1").animation(.linear, value: fightLogic.weather).ignoresSafeArea()
            VStack {
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 0).clipShape(TriangleB()).rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1)).offset(x: transitionToggle ? 100 : 0).animation(.linear(duration: 0.3).delay(0.2), value: transitionToggle)
                Spacer()
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 0).clipShape(TriangleB()).offset(x: transitionToggle ? -100 : 0).animation(.linear(duration: 0.3).delay(0.2), value: transitionToggle)
            }
            .padding(.vertical, 175)
            VStack(spacing: 0) {
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[0], height: 175 + geometry.safeAreaInsets.top, gameOver: $gameOver, fightOver: $fightOver, isInteractable: !hasCPUPlayer).rotationEffect(.degrees(180))
                Spacer()
                if #available(iOS 16.0, *) {
                    PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[1], height: 175 + geometry.safeAreaInsets.bottom, gameOver: $gameOver, fightOver: $fightOver, isInteractable: true).defersSystemGestures(on: .vertical)
                } else {
                    PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[1], height: 175 + geometry.safeAreaInsets.bottom, gameOver: $gameOver, fightOver: $fightOver, isInteractable: true)
                }
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).offset(y: transitionToggle ? -50 : geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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
            GlobalData.shared.missionManager.checkMissions(value: GlobalData.shared.userProgress)
            SaveData.saveProgress()
            
            transitionToggle = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                manager.setView(view: AnyView(FightSelectionView(topFighters: fightLogic.players[0].fighters, bottomFighters: fightLogic.players[1].fighters, singleMode: singleMode, alwaysRandom: alwaysRandom, hasCPUPlayer: hasCPUPlayer).environmentObject(manager)))
            }
        }
    }
}

struct FightView_Previews: PreviewProvider {
    static var previews: some View {
        FightView(fightLogic: FightLogic(players: [Player(id: 0, fighters: [GlobalData.shared.fighters[0]]), Player(id: 1, fighters: [GlobalData.shared.fighters[0]])], hasCPUPlayer: false, singleMode: true), singleMode: true, alwaysRandom: false, hasCPUPlayer: false)
    }
}
