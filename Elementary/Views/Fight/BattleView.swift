//
//  BattleView.swift
//  Elementary
//
//  Created by Janice Hablützel on 09.11.22.
//

import SwiftUI

struct BattleView: View {
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
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[0], gameOver: $gameOver, fightOver: $fightOver, isInteractable: false).rotationEffect(.degrees(180))
                Spacer()
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[1], gameOver: $gameOver, fightOver: $fightOver, isInteractable: true)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180)).offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            AudioPlayer.shared.playFightMusic()
            
            transitionToggle = false
        }
        .onChange(of: fightOver) { _ in
            GlobalData.shared.userProgress.addWin(winner: fightLogic.getWinner(), fighters: fightLogic.players[1].fighters)
            GlobalData.shared.userProgress.checkTeams(teamA: [], teamB: fightLogic.players[1].fighters)
            SaveData.save()
            
            transitionToggle = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                manager.setView(view: AnyView(BattleSelectionView(topFighters: [], bottomFighters: fightLogic.players[1].fighters).environmentObject(manager)))
            }
        }
    }
}

struct BattleView_Previews: PreviewProvider {
    static var previews: some View {
        BattleView(fightLogic: FightLogic(players: [Player(id: 0, fighters: [exampleFighter]), Player(id: 1, fighters: [exampleFighter])]))
    }
}
