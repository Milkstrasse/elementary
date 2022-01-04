//
//  LeftSelectionView.swift
//  Magiko
//
//  Created by Janice Hablützel on 04.01.22.
//

import SwiftUI

struct LeftSelectionView: View {
    @State var selectionToggle: Bool = false
    @State var infoToggle: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    if selectionToggle || infoToggle {
                        HStack(spacing: 0) {
                            Rectangle().fill(Color.pink).frame(width: 175 + geometry.safeAreaInsets.leading)
                            SmallTriangle().fill(Color.pink).frame(width: 14, height: 26).rotationEffect(.degrees(180))
                        }
                        .offset(x: -geometry.safeAreaInsets.leading)
                    }
                    Spacer()
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            Button(action: {
                                selectionToggle = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.blue)
                                    Text("+")
                                    FighterView()
                                }
                                .frame(width: 70, height: 70)
                            }
                            Button(action: {
                                selectionToggle = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.blue)
                                    Text("+")
                                    FighterView()
                                }
                                .frame(width: 70, height: 70)
                            }
                            Button(action: {
                                selectionToggle = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.blue)
                                    Text("+")
                                    FighterView()
                                }
                                .frame(width: 70, height: 70)
                            }
                        }
                        .rotationEffect(.degrees(90)).frame(width: 70, height: 220)
                        Spacer()
                    }
                }
                if selectionToggle || infoToggle {
                    VStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 5) {
                                VStack(spacing: 5) {
                                    FighterView().rotationEffect(.degrees(90))
                                    FighterView().rotationEffect(.degrees(90))
                                    FighterView().rotationEffect(.degrees(90))
                                    FighterView().rotationEffect(.degrees(90))
                                    FighterView().rotationEffect(.degrees(90))
                                    FighterView().rotationEffect(.degrees(90))
                                }
                                VStack(spacing: 5) {
                                    FighterView().rotationEffect(.degrees(90))
                                    FighterView().rotationEffect(.degrees(90))
                                    FighterView().rotationEffect(.degrees(90))
                                    FighterView().rotationEffect(.degrees(90))
                                    FighterView().rotationEffect(.degrees(90))
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                        .clipped()
                    }
                    .padding(.vertical, 15)
                }
            }
        }
    }
}

struct LeftSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LeftSelectionView().edgesIgnoringSafeArea(.bottom)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
