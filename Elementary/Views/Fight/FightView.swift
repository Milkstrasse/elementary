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
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                TriangleA().fill(Color("Background2")).frame(height: 145).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                Spacer()
                TriangleA().fill(Color("Background2")).frame(height: 145).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .padding(.vertical, 175)
            VStack(spacing: 0) {
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[0], gameOver: $gameOver, fightOver: $fightOver, isInteractable: true).rotationEffect(.degrees(180))
                Spacer()
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[1], gameOver: $gameOver, fightOver: $fightOver, isInteractable: true)
            }
            ZigZag().fill(Color.black).frame(height: geometry.size.height + 50).offset(y: transitionToggle ? -50 : geometry.size.height + 50).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            AudioPlayer.shared.playFightMusic()
            
            transitionToggle = false
        }
        .onChange(of: fightOver) { _ in
            transitionToggle = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                manager.setView(view: AnyView(FightSelectionView(topFighters: fightLogic.players[0].fighters, bottomFighters: fightLogic.players[1].fighters).environmentObject(manager)))
            }
        }
    }
}

struct FightView_Previews: PreviewProvider {
    static var previews: some View {
        FightView(fightLogic: FightLogic(players: [Player(id: 0, fighters: [exampleFighter]), Player(id: 1, fighters: [exampleFighter])]))
    }
}
