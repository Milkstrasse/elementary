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
                                infoToggle = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.blue)
                                    Text("+")
                                    FighterView()
                                }
                                .frame(width: 70, height: 70)
                            }
                            Button(action: {
                                infoToggle = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color.blue)
                                    Text("+")
                                    FighterView()
                                }
                                .frame(width: 70, height: 70)
                            }
                            Button(action: {
                                infoToggle = true
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
                if selectionToggle {
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
                } else if infoToggle {
                    VStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 5) {
                                VStack(spacing: 5) {
                                    Button("Remove") {
                                        infoToggle = false
                                    }
                                    .buttonStyle(GrowingButton(width: geometry.size.height - 30 - 215 - 5)).rotationEffect(.degrees(-90)).frame(width: 40, height: geometry.size.height - 30 - 215 - 5)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5).fill(Color.blue).frame(width: 40, height: 215)
                                        Text("<  Loadout  >").rotationEffect(.degrees(-90)).fixedSize().frame(width: 40, height: 215)
                                    }
                                }
                                StatOverviewView(width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 75, height: geometry.size.height - 30)
                                .padding(.trailing, 5)
                                DetailedAttackView(width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                DetailedAttackView(width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                DetailedAttackView(width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                            }
                            .padding(.vertical, 15)
                        }
                        .clipped()
                    }
                    .padding(.horizontal, 15).frame(width: 175)
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
