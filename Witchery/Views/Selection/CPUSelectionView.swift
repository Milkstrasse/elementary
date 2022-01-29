//
//  CPUSelectionView.swift
//  Witchery
//
//  Created by Janice Hablützel on 15.01.22.
//

import SwiftUI

struct CPUSelectionView: View {
    var witches: [Witch?]
    var selectedSlot: Int = 0
    var selectedLoadout: Int = 0
    var selectedAbility: Int = 0
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    HStack(spacing: 5) {
                        ForEach(0 ..< 4) { index in
                            SquareWitchView(witch: witches[index], isSelected: false)
                        }
                    }
                    .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                    Spacer()
                }
            }
        }
    }
}

struct CPUSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CPUSelectionView(witches: [nil, nil, nil, nil])
.previewInterfaceOrientation(.landscapeLeft)
    }
}
