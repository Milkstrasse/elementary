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
                HStack {
                    VStack {
                        TriangleA().fill(Color("Background2")).frame(height: 145).rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        TriangleA().fill(Color("Background2")).frame(height: 145)
                    }
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
                HStack(alignment: .bottom, spacing: 0) {
                    VStack {
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(OverviewView().environmentObject(manager)))
                            }
                        }) {
                            BasicButton(label: Localization.shared.getTranslation(key: "overview"), width: 175, height: largeHeight, fontSize: 16)
                        }
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(TrainingSelectionView().environmentObject(manager)))
                            }
                        }) {
                            BasicButton(label: Localization.shared.getTranslation(key: "training"), width: 175, height: largeHeight, fontSize: 16)
                        }
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(FightSelectionView().environmentObject(manager)))
                            }
                        }) {
                            BasicButton(label: Localization.shared.getTranslation(key: "fight"), width: 175, height: largeHeight, fontSize: 16)
                        }
                    }
                    .padding(.all, outerPadding)
                    Spacer()
                    Image(fileName: blink ? "example_blink" : "example").resizable().frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9).shadow(radius: 5, x: 5, y: 0)
                    VStack {
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(SettingsView(musicVolume: Int(AudioPlayer.shared.musicVolume * 10), soundVolume: Int(AudioPlayer.shared.soundVolume * 10), voiceVolume: Int(AudioPlayer.shared.voiceVolume * 10), hapticToggle: AudioPlayer.shared.hapticToggle, textIndex: GlobalData.shared.textSpeed, teamToggle: GlobalData.shared.teamRestricted, artifactIndex: GlobalData.shared.artifactUse).environmentObject(manager)))
                            }
                        }) {
                            IconButton(label: "\u{f013}")
                        }
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(HelpView().environmentObject(manager)))
                            }
                        }) {
                            IconButton(label: "\u{f128}")
                        }
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(CreditsView().environmentObject(manager)))
                            }
                        }) {
                            IconButton(label: "\u{f005}")
                        }
                        Spacer()
                    }
                    .padding(.all, outerPadding)
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
            ZigZag().fill(Color.black).frame(height: geometry.size.height + 50).offset(y: transitionToggle ? -50 : geometry.size.height + 50).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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
        MainView()
    }
}
