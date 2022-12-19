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
                    VStack(spacing: innerPadding) {
                        HStack(alignment: .top, spacing: innerPadding) {
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
                            ZStack(alignment: .trailing) {
                                TitlePanel().fill(Color("TitlePanel")).frame(width: 255, height: largeHeight)
                                CustomText(text: Localization.shared.getTranslation(key: "fightModes").uppercased(), fontColor: Color("MainPanel"), fontSize: mediumFont, isBold: true).padding(.all, outerPadding)
                            }
                        }
                        .padding(.leading, outerPadding)
                        HStack(spacing: innerPadding) {
                            Button(action: {
                                AudioPlayer.shared.playCancelSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(FightSelectionView().environmentObject(manager)))
                                }
                            }) {
                                ModeView(titleKey: "competition", geoWidth: (geometry.size.height - 2 * outerPadding - 3 * innerPadding)/4, icon: "\u{f72b}").shadow(radius: 5, x: 5, y: 0)
                            }
                            Button(action: {
                                AudioPlayer.shared.playCancelSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(TrainingSelectionView().environmentObject(manager)))
                                }
                            }) {
                                ModeView(titleKey: "arena", geoWidth: (geometry.size.height - 2 * outerPadding - 3 * innerPadding)/4, icon: "\u{f6e8}").shadow(radius: 5, x: 5, y: 0)
                            }
                            Button(action: {
                                AudioPlayer.shared.playCancelSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(RandomSelectionView().environmentObject(manager)))
                                }
                            }) {
                                ModeView(titleKey: "tournament", geoWidth: (geometry.size.height - 2 * outerPadding - 3 * innerPadding)/4, icon: "\u{f890}").shadow(radius: 5, x: 5, y: 0)
                            }
                            Button(action: {
                                AudioPlayer.shared.playCancelSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(BattleSelectionView().environmentObject(manager)))
                                }
                            }) {
                                ModeView(titleKey: "arcade", geoWidth: (geometry.size.height - 2 * outerPadding - 3 * innerPadding)/4, icon: "\u{f6b8}").shadow(radius: 5, x: 5, y: 0)
                            }
                        }
                        Spacer().frame(height: smallHeight)
                    }
                    .padding(.vertical, outerPadding)
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 100).rotationEffect(.degrees(180)).offset(y: transitionToggle ? -50 : -(geometry.size.height + 100)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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
