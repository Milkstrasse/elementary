//
//  MainView.swift
//  Magiko
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
    
    @State var transitionToggle: Bool = true
    
    @State var offsetX: CGFloat = -450
    
    @State var blink: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                Image(blink ? currentWitch.name + "_blink" : currentWitch.name).resizable().frame(width: geometry.size.height * 0.95, height: geometry.size.height * 0.95).scaleEffect(1).aspectRatio(contentMode: .fit).offset(x: -geometry.size.height/4.5, y: 0).padding(.trailing, offsetX < 0 ? 0 : geometry.size.width/2.6).animation(.linear(duration: 0.2), value: offsetX)
                HStack(alignment: .top, spacing: 5) {
                    HStack(spacing: 5) {
                        Button(Localization.shared.getTranslation(key: "training")) {
                            AudioPlayer.shared.playStandardSound()
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(TrainingSelectionView().environmentObject(manager)))
                            }
                        }
                        .buttonStyle(BasicButton(width: 135))
                        Button("W") {
                            AudioPlayer.shared.playStandardSound()
                            overviewToggle = true
                        }
                        .buttonStyle(BasicButton(width: 40))
                        Button("S") {
                            AudioPlayer.shared.playStandardSound()
                            settingsToggle = true
                        }
                        .buttonStyle(BasicButton(width: 40))
                        Button("C") {
                            AudioPlayer.shared.playStandardSound()
                            infoToggle = true
                        }
                        .buttonStyle(BasicButton(width: 40))
                    }
                    .padding(.leading, offsetX < 0 ? 0 : -450).animation(.linear(duration: 0.2), value: offsetX)
                    Spacer()
                    VStack {
                        Spacer()
                        Button(Localization.shared.getTranslation(key: "fight")) {
                            AudioPlayer.shared.playStandardSound()
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(FightSelectionView().environmentObject(manager)))
                            }
                        }
                        .buttonStyle(BasicButton(width: 190, height: 50))
                    }
                }
                .padding(.all, 15)
                if overviewToggle {
                    WitchesOverviewView(currentWitch: $currentWitch, overviewToggle: $overviewToggle, offsetX: $offsetX)
                } else if settingsToggle {
                    SettingsView(settingsToggle: $settingsToggle, offsetX: $offsetX)
                } else if infoToggle {
                    CreditsView(infoToggle: $infoToggle, offsetX: $offsetX)
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            ZigZag().fill(Color("outline")).frame(height: geometry.size.height + 65).offset(y: transitionToggle ? -65 : geometry.size.height + 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                blink = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    blink = false
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
.previewInterfaceOrientation(.landscapeRight)
    }
}
