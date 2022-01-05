//
//  RightSelectionView.swift
//  Magiko
//
//  Created by Janice Hablützel on 04.01.22.
//

import SwiftUI

struct RightSelectionView: View {
    @State var fighter1: String = "magicalgirl_1"
    @State var fighter2: String?
    @State var fighter3: String?
    @State var fighter4: String?
    
    @State var selectionToggle: Bool = false
    @State var infoToggle: Bool = false
    
    @State var offsetX: CGFloat = 189
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                HStack {
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            Button(action: {
                                if fighter1 != nil {
                                    selectionToggle = false
                                    infoToggle = true
                                } else {
                                    infoToggle = false
                                    selectionToggle = true
                                }
                            }) {
                                if fighter1 != nil {
                                    FighterView()
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5).fill(Color.green)
                                        Text("+")
                                    }
                                    .frame(width: 70, height: 70)
                                }
                            }
                            Button(action: {
                                if fighter2 != nil {
                                    selectionToggle = false
                                    infoToggle = true
                                } else {
                                    infoToggle = false
                                    selectionToggle = true
                                }
                            }) {
                                if fighter2 != nil {
                                    FighterView()
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5).fill(Color.green)
                                        Text("+")
                                    }
                                    .frame(width: 70, height: 70)
                                }
                            }
                            Button(action: {
                                if fighter3 != nil {
                                    selectionToggle = false
                                    infoToggle = true
                                } else {
                                    infoToggle = false
                                    selectionToggle = true
                                }
                            }) {
                                if fighter3 != nil {
                                    FighterView()
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5).fill(Color.green)
                                        Text("+")
                                    }
                                    .frame(width: 70, height: 70)
                                }
                            }
                            Button(action: {
                                if fighter4 != nil {
                                    selectionToggle = false
                                    infoToggle = true
                                } else {
                                    infoToggle = false
                                    selectionToggle = true
                                }
                            }) {
                                if fighter4 != nil {
                                    FighterView()
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5).fill(Color.green)
                                        Text("+")
                                    }
                                    .frame(width: 70, height: 70)
                                }
                            }
                        }
                        .rotationEffect(.degrees(-90)).frame(width: 70, height: 295)
                        Spacer()
                    }
                    Spacer()
                }
                if selectionToggle || infoToggle {
                    HStack(spacing: 0) {
                        SmallTriangle().fill(Color.pink).frame(width: 14, height: 26)
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color.pink).frame(width: 175 + geometry.safeAreaInsets.trailing)
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
                                                    offsetX = 189
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                        selectionToggle = false
                                                        infoToggle = false
                                                    }
                                                }
                                                .buttonStyle(GrowingButton(width: geometry.size.height - 30 - 215 - 5)).rotationEffect(.degrees(-90)).frame(width: 40, height: geometry.size.height - 30 - 215 - 5)
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 5).fill(Color.blue).frame(width: 40, height: 215)
                                                    Text("<  Loadout  >").rotationEffect(.degrees(-90)).fixedSize().frame(width: 40, height: 215)
                                                }
                                            }
                                            BaseOverviewView(base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, spAttack: 100), width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 75, height: geometry.size.height - 30)
                                            .padding(.trailing, 5)
                                            DetailedActionView(title: "Attack", description: "Description", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                            DetailedActionView(title: "Attack", description: "Description", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                            DetailedActionView(title: "Attack", description: "Description", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                            DetailedActionView(title: "Attack", description: "Description", width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                        }
                                        .padding(.vertical, 15)
                                    }
                                    .clipped()
                                }
                                .padding(.horizontal, 15).frame(width: 175)
                            }
                        }
                    }
                    .offset(x: geometry.safeAreaInsets.trailing + offsetX).animation(.linear(duration: 0.2), value: offsetX)
                    .onAppear {
                        offsetX = 0
                    }
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
