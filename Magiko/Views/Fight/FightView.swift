//
//  FightView.swift
//  Magiko
//
//  Created by Janice Hablützel on 04.01.22.
//

import SwiftUI

enum Section {
    case summary
    case options
    case skills
    case team
    case waiting
}

struct FightView: View {
    @EnvironmentObject var manager: ViewManager
    
    let fightLogic: FightLogic
    
    @State var transitionToggle: Bool = true
    @State var offsetX: CGFloat = -200
    
    @State var gameOver: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                LeftPlayerFightView(fightLogic: fightLogic, offsetX: offsetX, gameOver: $gameOver)
                Spacer()
                RightPlayerFightView(fightLogic: fightLogic, offsetX: offsetX, gameOver: $gameOver)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            GeometryReader { geometry in
                ZigZag().fill(Color("outline")).frame(height: geometry.size.height + 65)
                    .offset(y: transitionToggle ? -65 : geometry.size.height + 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
            }
        }
        .onAppear {
            transitionToggle = false
            offsetX = 0
        }
        .onChange(of: gameOver) { _ in
            transitionToggle = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                manager.setView(view: AnyView(FightOverView(leftFighters: fightLogic.fighters[0], rightFighters: fightLogic.fighters[1], winner: fightLogic.getWinner()).environmentObject(manager)))
            }
        }
    }
}

struct FightView_Previews: PreviewProvider {
    static var previews: some View {
        FightView(fightLogic: FightLogic(leftFighters: [], rightFighters: []))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
