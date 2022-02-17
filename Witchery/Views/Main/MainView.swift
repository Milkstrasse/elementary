//
//  MainView.swift
//  Witchery
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var manager: ViewManager
    
    @State var currentWitch: Witch = exampleWitch
    
    @State var overviewToggle: Bool = false
    @State var settingsToggle: Bool = false
    @State var infoToggle: Bool = false
    @State var creditsToggle: Bool = false
    
    @State var transitionToggle: Bool = true
    
    @State var offsetX: CGFloat = -450
    
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
            ZStack(alignment: .bottomTrailing) {
                Image(blink ? currentWitch.name + "_blink" : currentWitch.name).resizable().frame(width: geometry.size.height * 0.95, height: geometry.size.height * 0.95).scaleEffect(1).aspectRatio(contentMode: .fit).offset(x: -geometry.size.height/4.5, y: 0).padding(.trailing, offsetX < 0 ? 0 : geometry.size.width/2.6).animation(.linear(duration: 0.2), value: offsetX)
                HStack(alignment: .top, spacing: 5) {
                    VStack(spacing: 5) {
                        Button(Localization.shared.getTranslation(key: "overview")) {
                            AudioPlayer.shared.playStandardSound()
                            overviewToggle = true
                        }
                        .buttonStyle(BasicButton(width: 135))
                        Button(Localization.shared.getTranslation(key: "training")) {
                            AudioPlayer.shared.playStandardSound()
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(TrainingSelectionView().environmentObject(manager)))
                            }
                        }
                        .buttonStyle(BasicButton(width: 135))
                        HStack {
                            Button(Localization.shared.getTranslation(key: "fight")) {
                                AudioPlayer.shared.playStandardSound()
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(FightSelectionView().environmentObject(manager)))
                                }
                            }
                            .buttonStyle(BasicButton(width: 135))
                        }
                    }
                    .padding(.leading, offsetX < 0 ? 0 : -450).animation(.linear(duration: 0.2), value: offsetX)
                    Spacer()
                    VStack {
                        Spacer()
                        Button("S") {
                            AudioPlayer.shared.playStandardSound()
                            settingsToggle = true
                        }
                        .buttonStyle(BasicButton(width: 40))
                        Button("?") {
                            AudioPlayer.shared.playStandardSound()
                            infoToggle = true
                        }
                        .buttonStyle(BasicButton(width: 40))
                        Button("C") {
                            AudioPlayer.shared.playStandardSound()
                            creditsToggle = true
                        }
                        .buttonStyle(BasicButton(width: 40))
                    }
                }
                .padding(.all, 15)
                if overviewToggle {
                    OverviewView(currentWitch: $currentWitch, overviewToggle: $overviewToggle, offsetX: $offsetX)
                } else if settingsToggle {
                    SettingsView(settingsToggle: $settingsToggle, offsetX: $offsetX, musicVolume: Int(AudioPlayer.shared.musicVolume * 10), soundVolume: Int(AudioPlayer.shared.soundVolume * 10), voiceVolume: Int(AudioPlayer.shared.voiceVolume * 10), hapticToggle: AudioPlayer.shared.hapticToggle, textIndex: GlobalData.shared.textSpeed, artifactIndex: GlobalData.shared.artifactUse)
                } else if infoToggle {
                    InfoView(infoToggle: $infoToggle, offsetX: $offsetX, transitionToggle: $transitionToggle).environmentObject(manager)
                } else if creditsToggle {
                    CreditsView(creditsToggle: $creditsToggle, offsetX: $offsetX)
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            ZigZag().fill(Color("outline")).frame(height: geometry.size.height + 65).offset(y: transitionToggle ? -65 : geometry.size.height + 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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
.previewInterfaceOrientation(.landscapeRight)
    }
}
