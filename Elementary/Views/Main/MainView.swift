//
//  MainView.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.08.22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var manager: ViewManager
    @State var transitionToggle: Bool = true
    
    let currentFighter: Fighter
    
    @State var blink: Bool = false
    @State var stopBlinking: Bool = false
    
    /// Sends signal to blink.
    /// - Parameter delay: The delay between blinks
    func blink(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            blink = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                blink = false
                
                if !stopBlinking {
                    let blinkInterval: Int = Int.random(in: 5 ... 10)
                    blink(delay: TimeInterval(blinkInterval))
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    VStack {
                        Spacer()
                        Image("Pattern").resizable(resizingMode: .tile).frame(width: (geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)/2, height: 145 + geometry.safeAreaInsets.top).clipShape(TriangleA())
                    }
                    VStack {
                        Image("Pattern").resizable(resizingMode: .tile).frame(width: (geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)/2, height: 145 + geometry.safeAreaInsets.bottom).clipShape(TriangleA()).rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                        Spacer()
                    }
                }
                .frame(width: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: (geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)/2).ignoresSafeArea()
                Group {
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            currentFighter.getImage(blinking: blink, state: PlayerState.neutral).resizable().frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9).offset(x: -15).shadow(radius: 5, x: 5, y: 0)
                            Spacer()
                            VStack {
                                Button(action: {
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(ModeSelectionView().environmentObject(manager)))
                                    }
                                }) {
                                    BasicButton(label: Localization.shared.getTranslation(key: "fight"), width: 175, height: General.largeHeight, fontSize: General.mediumFont)
                                }
                                Button(action: {
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(OverviewView().environmentObject(manager)))
                                    }
                                }) {
                                    BasicButton(label: Localization.shared.getTranslation(key: "overview"), width: 175, height: General.largeHeight, fontSize: General.mediumFont)
                                }
                                Button(action: {
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(ShopView(userProgress: GlobalData.shared.userProgress, currentFighter: currentFighter).environmentObject(manager)))
                                    }
                                }) {
                                    BasicButton(label: Localization.shared.getTranslation(key: "shop"), width: 175, height: General.largeHeight, fontSize: General.mediumFont)
                                }
                            }
                            .padding(.bottom, General.outerPadding)
                        }
                        .padding(.horizontal, General.outerPadding)
                    }
                    VStack {
                        HStack(spacing: General.innerPadding) {
                            Button(action: {
                                AudioPlayer.shared.playStandardSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MissionsView(userProgress: GlobalData.shared.userProgress).environmentObject(manager)))
                                }
                            }) {
                                IconButton(label: "\u{f02e}")
                            }
                            Button(action: {
                                AudioPlayer.shared.playStandardSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(HelpView(currentFighter: currentFighter).environmentObject(manager)))
                                }
                            }) {
                                IconButton(label: "\u{f02d}")
                            }
                            Button(action: {
                                AudioPlayer.shared.playStandardSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(SettingsView().environmentObject(manager)))
                                }
                            }) {
                                IconButton(label: "\u{f013}")
                            }
                            Button(action: {
                                AudioPlayer.shared.playStandardSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(CreditsView(currentFighter: currentFighter).environmentObject(manager)))
                                }
                            }) {
                                IconButton(label: "\u{f005}")
                            }
                            Spacer()
                        }
                        .padding(.all, General.outerPadding)
                        Spacer()
                    }
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).rotationEffect(.degrees(180)).offset(y: transitionToggle ? -50 : -(geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            let blinkInterval: Int = Int.random(in: 5 ... 10)
            blink(delay: TimeInterval(blinkInterval))
        }
        .onDisappear {
            stopBlinking = true
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(currentFighter: GlobalData.shared.fighters[0])
    }
}
