//
//  CPUSelectionView.swift
//  Elementary
//
//  Created by Janice Hablützel on 22.08.22.
//

import SwiftUI

struct CPUSelectionView: View {
    var fighters: [Fighter?]
    
    var body: some View {
        VStack {
            HStack(spacing: General.innerPadding/2) {
                Spacer()
                ForEach(0 ..< fighters.count, id: \.self) { index in
                    SquarePortraitView(fighter: fighters[index], outfitIndex: 0, isSelected: false, isInverted: true)
                }
                Spacer()
            }
            Spacer()
        }
    }
}

struct CPUSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CPUSelectionView(fighters: [nil, nil, nil, nil])
    }
}
