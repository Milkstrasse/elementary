//
//  RightSelectionView.swift
//  Magiko
//
//  Created by Janice Hablützel on 04.01.22.
//

import SwiftUI

struct RightSelectionView: View {
    @State var selectionToggle: Bool = false
    @State var infoToggle: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                HStack(spacing: 0) {
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
                        .rotationEffect(.degrees(-90)).frame(width: 70, height: 220)
                        Spacer()
                    }
                    Spacer()
                    if selectionToggle || infoToggle {
                        HStack(spacing: 0) {
                            SmallTriangle().fill(Color.pink).frame(width: 14, height: 26)
                            Rectangle().fill(Color.pink).frame(width: 175 + geometry.safeAreaInsets.trailing)
                        }
                        .offset(x: geometry.safeAreaInsets.trailing)
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
                    .padding(.vertical, 15).rotationEffect(.degrees(180))
                }
            }
        }
    }
}

struct RightSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RightSelectionView().edgesIgnoringSafeArea(.bottom).previewInterfaceOrientation(.landscapeLeft)
    }
}
