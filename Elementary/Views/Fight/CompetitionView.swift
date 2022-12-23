//
//  CompetitionView.swift
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

struct CompetitionView: View {
    @EnvironmentObject var manager: ViewManager
    
    let fightLogic: FightLogic
    
    @State var transitionToggle: Bool = true
    
    @State var gameOver: Bool = false
    @State var fightOver: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 0).clipShape(TriangleB()).rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                Spacer()
                Image("Pattern").resizable(resizingMode: .tile).offset(x: 0).clipShape(TriangleB())
            }
            .padding(.vertical, 175)
            VStack(spacing: 0) {
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[0], gameOver: $gameOver, fightOver: $fightOver, isInteractable: true).rotationEffect(.degrees(180))
                Spacer()
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[1], gameOver: $gameOver, fightOver: $fightOver, isInteractable: true)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 100).rotationEffect(.degrees(180)).offset(y: transitionToggle ? -50 : -(geometry.size.height + 100)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            AudioPlayer.shared.playFightMusic()
            
            transitionToggle = false
        }
        .onChange(of: fightOver) { _ in
            GlobalData.shared.userProgress.addFight()
            GlobalData.shared.userProgress.checkTeams(teamA: fightLogic.players[0].fighters, teamB: fightLogic.players[1].fighters)
            SaveData.saveProgress()
            
            transitionToggle = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                manager.setView(view: AnyView(CompetitionSelectionView(topFighters: fightLogic.players[0].fighters, bottomFighters: fightLogic.players[1].fighters).environmentObject(manager)))
            }
        }
    }
}

struct CompetitionView_Previews: PreviewProvider {
    static var previews: some View {
        CompetitionView(fightLogic: FightLogic(players: [Player(id: 0, fighters: [waterFighter]), Player(id: 1, fighters: [waterFighter])]))
    }
}
