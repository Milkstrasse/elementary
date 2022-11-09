//
//  ModeSelectionView.swift
//  Elementary
//
//  Created by Janice Hablützel on 09.11.22.
//

import SwiftUI

struct ModeSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    
    @State var transitionToggle: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    HStack {
                        VStack {
                            Spacer()
                            Image("Pattern").frame(width: 240, height: 145).clipShape(TriangleA())
                        }
                        Spacer()
                        VStack {
                            Image("Pattern").frame(width: 240, height: 145).clipShape(TriangleA()).rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                            Spacer()
                        }
                    }
                    VStack(spacing: outerPadding) {
                        HStack(spacing: innerPadding) {
                            Button(action: {
                                AudioPlayer.shared.playCancelSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MainView(currentFighter: GlobalData.shared.getRandomFighter()).environmentObject(manager)))
                                }
                            }) {
                                IconButton(label: "\u{f00d}")
                            }
                            Spacer()
                        }
                        HStack(spacing: innerPadding) {
                            Button(action: {
                                AudioPlayer.shared.playCancelSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(FightSelectionView().environmentObject(manager)))
                                }
                            }) {
                                Rectangle()
                            }
                            Button(action: {
                                AudioPlayer.shared.playCancelSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(TrainingSelectionView().environmentObject(manager)))
                                }
                            }) {
                                Rectangle()
                            }
                            Button(action: {
                                AudioPlayer.shared.playCancelSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(RandomSelectionView().environmentObject(manager)))
                                }
                            }) {
                                Rectangle()
                            }
                            Button(action: {
                                AudioPlayer.shared.playCancelSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(BattleSelectionView().environmentObject(manager)))
                                }
                            }) {
                                Rectangle()
                            }
                        }
                    }
                    .padding(.all, outerPadding)
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180)).offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
        }
    }
}

struct ModeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectionView()
    }
}
