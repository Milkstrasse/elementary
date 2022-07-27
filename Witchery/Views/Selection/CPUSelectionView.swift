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
    var selectedNature: Int = 0
    var selectedArtifact: Int = 0
    
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Spacer()
                ForEach(0 ..< 4) { index in
                    SquareWitchView(witch: witches[index], isSelected: false, inverted: true)
                }
                Spacer()
            }
            Spacer()
        }
        .rotationEffect(.degrees(180))
    }
}

struct CPUSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CPUSelectionView(witches: [nil, nil, nil, nil])
    }
}
