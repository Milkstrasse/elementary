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
    
    let currentFighter: String
    
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
                    VStack {
                        HStack(spacing: innerPadding) {
                            Button(action: {
                                AudioPlayer.shared.playStandardSound()
                                
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MissionsView().environmentObject(manager)))
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
                            Button(action: {
                                GlobalData.shared.userProgress.unlockSkin(fighter: "aether1", index: 1)
                            }) {
                                IconButton(label: "\u{f8c1}")
                            }
                            Spacer()
                        }
                        .padding(.all, outerPadding)
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            Image(fileName: blink ? currentFighter + "_blink" : currentFighter).resizable().frame(width: geometry.size.width - smallHeight - 2 * outerPadding, height: geometry.size.width - smallHeight - 2 * outerPadding).offset(x: -20).shadow(radius: 5, x: 5, y: 0)
                            Spacer()
                            VStack {
                                Button(action: {
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(FightSelectionView().environmentObject(manager)))
                                    }
                                }) {
                                    BasicButton(label: Localization.shared.getTranslation(key: "fight"), width: 175, height: largeHeight, fontSize: mediumFont)
                                }
                                Button(action: {
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(TrainingSelectionView().environmentObject(manager)))
                                    }
                                }) {
                                    BasicButton(label: Localization.shared.getTranslation(key: "training"), width: 175, height: largeHeight, fontSize: mediumFont)
                                }
                                Button(action: {
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        manager.setView(view: AnyView(OverviewView().environmentObject(manager)))
                                    }
                                }) {
                                    BasicButton(label: Localization.shared.getTranslation(key: "overview"), width: 175, height: largeHeight, fontSize: mediumFont)
                                }
                            }
                            .padding(.bottom, outerPadding)
                        }
                        .padding(.horizontal, outerPadding)
                    }
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 50).offset(y: transitionToggle ? -50 : geometry.size.height + 50).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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
        MainView(currentFighter: exampleFighter.name)
    }
}
