//
//  MainView.swift
//  Witchery
//
//  Created by Janice Hablützel on 21.07.22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var manager: ViewManager
    
    @State var currentWitch: Witch = exampleWitch
    
    @State var offsetX: CGFloat = 0
    @State var offsetY: CGFloat = 0
    
    @State var overviewToggle: Bool = false
    @State var settingsToggle: Bool = false
    @State var helpToggle: Bool = false
    @State var creditsToggle: Bool = false
    
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
            ZStack(alignment: .trailing) {
                VStack(spacing: 0) {
                    Spacer()
                    Color(red: 0.15, green: 0.125, blue: 0.25).frame(height: 300)
                }
                .ignoresSafeArea(.all, edges: .vertical)
                VStack {
                    Spacer()
                    Image(fileName: blink ? currentWitch.name + "_blink" : currentWitch.name).resizable().aspectRatio(contentMode: .fit).frame(width: geometry.size.width/3 * 2)
                    Spacer().frame(height: 355)
                }
                ZStack(alignment: .top) {
                    Color(red: 0.15, green: 0.125, blue: 0.25)
                    VStack(spacing: 10) {
                        Text("Witchery").foregroundColor(Color.white).frame(maxWidth: .infinity, alignment: .leading).frame(height: 60)
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(FightSelectionView().environmentObject(manager)))
                            }
                        }) {
                            MenuActionView(title: Localization.shared.getTranslation(key: "fight"), description: "---", symbol: "0xf0d0")
                        }
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(TrainingSelectionView().environmentObject(manager)))
                            }
                        }) {
                            MenuActionView(title: Localization.shared.getTranslation(key: "training"), description: "---", symbol: "0xe05d")
                        }
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            overviewToggle = true
                        }) {
                            MenuActionView(title: Localization.shared.getTranslation(key: "overview"), description: "---", symbol: "0xf500")
                        }
                        HStack(spacing: 10) {
                            Button(Localization.shared.getTranslation(key: "help")) {
                                AudioPlayer.shared.playStandardSound()
                                helpToggle = true
                            }
                            .buttonStyle(BasicButton(width: geometry.size.width - 140))
                            Button(Localization.shared.getTranslation(key: "S")) {
                                AudioPlayer.shared.playStandardSound()
                                settingsToggle = true
                            }
                            .buttonStyle(BasicButton(width: 45))
                            Button(Localization.shared.getTranslation(key: "C")) {
                                AudioPlayer.shared.playStandardSound()
                                creditsToggle = true
                            }
                            .buttonStyle(BasicButton(width: 45))
                        }
                    }
                    .padding(.all, 15).offset(x: -offsetX).animation(.linear(duration: 0.2), value: offsetX)
                }
                .frame(height: 355 + offsetY).padding(.top, offsetY != 0 ? -355 - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom : geometry.size.height - 355).animation(.linear(duration: 0.3), value: offsetY)
                if overviewToggle {
                    OverviewView(currentWitch: $currentWitch, offsetX: $offsetX, overviewToggle: $overviewToggle)
                } else if settingsToggle {
                    SettingsView(offsetY: $offsetY, settingsToggle: $settingsToggle, musicVolume: Int(AudioPlayer.shared.musicVolume * 10), soundVolume: Int(AudioPlayer.shared.soundVolume * 10), voiceVolume: Int(AudioPlayer.shared.voiceVolume * 10), hapticToggle: AudioPlayer.shared.hapticToggle, textIndex: GlobalData.shared.textSpeed, teamToggle: GlobalData.shared.teamRestricted, artifactIndex: GlobalData.shared.artifactUse)
                } else if helpToggle {
                    HelpView(offsetY: $offsetY, helpToggle: $helpToggle, transitionToggle: $transitionToggle).environmentObject(manager)
                } else if creditsToggle {
                    CreditsView(offsetY: $offsetY, creditsToggle: $creditsToggle)
                }
            }
            ZigZag().fill(Color("panel")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 65).offset(y: transitionToggle ? -65 : geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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
