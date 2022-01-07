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
    case info
    case waiting
}

struct FightView: View {
    let fightLogic: FightLogic
    
    @State var transitionToggle: Bool = true
    @State var offsetX: CGFloat = -200
    
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            HStack {
                LeftPlayerFightView(fightLogic: fightLogic, offsetX: offsetX)
                Spacer()
                RightPlayerFightView(fightLogic: fightLogic, offsetX: offsetX)
            }
            .edgesIgnoringSafeArea(.bottom)
            GeometryReader { geometry in
                ZigZag().fill(Color.purple).frame(height: geometry.size.height + 65)
                    .offset(y: transitionToggle ? -65 : geometry.size.height + 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
            }
        }
        .onAppear {
            transitionToggle = false
            offsetX = 0
        }
    }
}

struct FightView_Previews: PreviewProvider {
    static var previews: some View {
        FightView(fightLogic: FightLogic(leftFighters: [], rightFighters: []))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
