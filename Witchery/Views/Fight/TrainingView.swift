//
//  TrainingView.swift
//  Witchery
//
//  Created by Janice Hablützel on 15.01.22.
//

import SwiftUI

struct TrainingView: View {
    @EnvironmentObject var manager: ViewManager
    
    let fightLogic: FightLogic
    
    @State var transitionToggle: Bool = true
    @State var offsetX: CGFloat = -200
    
    @State var gameOver: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[0], offsetX: offsetX, gameOver: $gameOver, isInteractable: false)
                Spacer()
                PlayerFightView(fightLogic: fightLogic, player: fightLogic.players[1], offsetX: offsetX, gameOver: $gameOver, isInteractable: true)
            }
            GeometryReader { geometry in
                ZigZag().fill(Color("panel")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 65).offset(y: transitionToggle ? -65 : geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
            }
        }
        .onAppear {
            AudioPlayer.shared.playBattleMusic()
            
            transitionToggle = false
            offsetX = 0
        }
        .onChange(of: gameOver) { _ in
            transitionToggle = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                manager.setView(view: AnyView(TrainingOverView(topWitches: fightLogic.players[0].witches, bottomWitches: fightLogic.players[1].witches, winner: fightLogic.getWinner()).environmentObject(manager)))
            }
        }
    }
}

struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingView(fightLogic: FightLogic(players: [Player(id: 0, witches: [exampleWitch]), Player(id: 1, witches: [exampleWitch])]))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
