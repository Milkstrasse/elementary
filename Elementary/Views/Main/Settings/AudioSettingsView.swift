//
//  AudioSettingsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 29.01.23.
//

import SwiftUI

struct AudioSettingsView: View {
    @Binding var generalVolume: Int
    @Binding var musicVolume: Int
    @Binding var soundVolume: Int
    @Binding var voiceVolume: Int
    
    @Binding var hapticToggle: Bool
    
    @State var langIndex: Int
    
    @GestureState var isGeneralDecreasing: Bool = false
    @GestureState var isGeneralIncreasing: Bool = false
    @GestureState var isMusicDecreasing: Bool = false
    @GestureState var isMusicIncreasing: Bool = false
    @GestureState var isSoundDecreasing: Bool = false
    @GestureState var isSoundIncreasing: Bool = false
    @GestureState var isVoicesDecreasing: Bool = false
    @GestureState var isVoicesIncreasing: Bool = false
    
    /// Resets audio values to default
    func resetAudioSettings() {
        AudioPlayer.shared.generalVolume = 1.0
        generalVolume = 10
        AudioPlayer.shared.musicVolume = 1.0
        musicVolume = 10
        AudioPlayer.shared.soundVolume = 1.0
        soundVolume = 10
        AudioPlayer.shared.voiceVolume = 1.0
        voiceVolume = 10
        AudioPlayer.shared.hapticToggle = true
        hapticToggle = true
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(Color("Positive"))
            HStack {
                CustomText(text: Localization.shared.getTranslation(key: "audio").uppercased(), fontSize: General.mediumFont, isBold: true)
                Spacer()
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    resetAudioSettings()
                }) {
                    Text("\u{f2ed}").font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color("Text")).frame(width: General.smallHeight, height: General.smallHeight)
                }
            }
            .frame(height: General.largeHeight).padding(.leading, General.innerPadding)
        }
        .padding(.bottom, General.innerPadding/2)
        ZStack {
            Rectangle().fill(Color("MainPanel"))
                .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
            HStack(spacing: 0) {
                CustomText(text: Localization.shared.getTranslation(key: "general").uppercased(), fontSize: General.mediumFont, isBold: true)
                Spacer()
                Button(action: {
                }) {
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                .onChange(of: isGeneralDecreasing, perform: { _ in
                    Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                        if self.isGeneralDecreasing == true {
                            if generalVolume > 0 {
                                generalVolume -= 1
                            } else {
                                generalVolume = 10
                            }
                            
                            AudioPlayer.shared.generalVolume = Float(generalVolume)/10
                            AudioPlayer.shared.setMusicPlayer()
                            AudioPlayer.shared.playStandardSound()
                        } else {
                            timer.invalidate()
                        }
                    }
                })
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: .infinity)
                        .updating($isGeneralDecreasing) { value, state, _ in state = value }
                )
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            if generalVolume > 0 {
                                generalVolume -= 1
                            } else {
                                generalVolume = 10
                            }
                            
                            AudioPlayer.shared.generalVolume = Float(generalVolume)/10
                            AudioPlayer.shared.setMusicPlayer()
                            AudioPlayer.shared.playStandardSound()
                })
                CustomText(text: "\(generalVolume * 10)%".uppercased(), fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                }) {
                    ClearButton(label: ">", width: 35, height: General.largeHeight)
                }
                .onChange(of: isGeneralIncreasing, perform: { _ in
                    Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                        if self.isGeneralIncreasing == true {
                            if generalVolume < 10 {
                                generalVolume += 1
                            } else {
                                generalVolume = 0
                            }
                            
                            AudioPlayer.shared.generalVolume = Float(generalVolume)/10
                            AudioPlayer.shared.setMusicPlayer()
                            AudioPlayer.shared.playStandardSound()
                        } else {
                            timer.invalidate()
                        }
                    }
                })
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: .infinity)
                        .updating($isGeneralIncreasing) { value, state, _ in state = value }
                )
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            if generalVolume < 10 {
                                generalVolume += 1
                            } else {
                                generalVolume = 0
                            }
                            
                            AudioPlayer.shared.generalVolume = Float(generalVolume)/10
                            AudioPlayer.shared.setMusicPlayer()
                            AudioPlayer.shared.playStandardSound()
                })
            }
            .padding(.leading, General.innerPadding)
        }
        ZStack {
            Rectangle().fill(Color("MainPanel"))
                .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
            HStack(spacing: 0) {
                CustomText(text: Localization.shared.getTranslation(key: "music").uppercased(), fontSize: General.mediumFont, isBold: true)
                Spacer()
                Button(action: {
                }) {
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                .onChange(of: isMusicDecreasing, perform: { _ in
                    Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                        if self.isMusicDecreasing == true {
                            if musicVolume > 0 {
                                musicVolume -= 1
                            } else {
                                musicVolume = 10
                            }
                            
                            AudioPlayer.shared.musicVolume = Float(musicVolume)/10
                            AudioPlayer.shared.setMusicPlayer()
                            AudioPlayer.shared.playStandardSound()
                        } else {
                            timer.invalidate()
                        }
                    }
                })
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: .infinity)
                        .updating($isMusicDecreasing) { value, state, _ in state = value }
                )
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            if musicVolume > 0 {
                                musicVolume -= 1
                            } else {
                                musicVolume = 10
                            }
                            
                            AudioPlayer.shared.musicVolume = Float(musicVolume)/10
                            AudioPlayer.shared.setMusicPlayer()
                            AudioPlayer.shared.playStandardSound()
                })
                CustomText(text: "\(musicVolume * 10)%".uppercased(), fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                }) {
                    ClearButton(label: ">", width: 35, height: General.largeHeight)
                }
                .onChange(of: isMusicIncreasing, perform: { _ in
                    Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                        if self.isMusicIncreasing == true {
                            if musicVolume < 10 {
                                musicVolume += 1
                            } else {
                                musicVolume = 0
                            }
                            
                            AudioPlayer.shared.musicVolume = Float(musicVolume)/10
                            AudioPlayer.shared.setMusicPlayer()
                            AudioPlayer.shared.playStandardSound()
                        } else {
                            timer.invalidate()
                        }
                    }
                })
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: .infinity)
                        .updating($isMusicIncreasing) { value, state, _ in state = value }
                )
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            if musicVolume < 10 {
                                musicVolume += 1
                            } else {
                                musicVolume = 0
                            }
                            
                            AudioPlayer.shared.musicVolume = Float(musicVolume)/10
                            AudioPlayer.shared.setMusicPlayer()
                            AudioPlayer.shared.playStandardSound()
                })
            }
            .padding(.leading, General.innerPadding)
        }
        ZStack {
            Rectangle().fill(Color("MainPanel"))
                .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
            HStack(spacing: 0) {
                CustomText(text: Localization.shared.getTranslation(key: "sound").uppercased(), fontSize: General.mediumFont, isBold: true)
                Spacer()
                Button(action: {
                }) {
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                .onChange(of: isSoundDecreasing, perform: { _ in
                    Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                        if self.isSoundDecreasing == true {
                            if soundVolume > 0 {
                                soundVolume -= 1
                            } else {
                                soundVolume = 10
                            }
                            
                            AudioPlayer.shared.soundVolume = Float(soundVolume)/10
                            AudioPlayer.shared.playStandardSound()
                        } else {
                            timer.invalidate()
                        }
                    }
                })
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: .infinity)
                        .updating($isSoundDecreasing) { value, state, _ in state = value }
                )
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            if soundVolume > 0 {
                                soundVolume -= 1
                            } else {
                                soundVolume = 10
                            }
                            
                            AudioPlayer.shared.soundVolume = Float(soundVolume)/10
                            AudioPlayer.shared.playStandardSound()
                })
                CustomText(text: "\(soundVolume * 10)%".uppercased(), fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                }) {
                    ClearButton(label: ">", width: 35, height: General.largeHeight)
                }
                .onChange(of: isSoundIncreasing, perform: { _ in
                    Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                        if self.isSoundIncreasing == true {
                            if soundVolume < 10 {
                                soundVolume += 1
                            } else {
                                soundVolume = 0
                            }
                            
                            AudioPlayer.shared.soundVolume = Float(soundVolume)/10
                            AudioPlayer.shared.playStandardSound()
                        } else {
                            timer.invalidate()
                        }
                    }
                })
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: .infinity)
                        .updating($isSoundIncreasing) { value, state, _ in state = value }
                )
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            if soundVolume < 10 {
                                soundVolume += 1
                            } else {
                                soundVolume = 0
                            }
                            
                            AudioPlayer.shared.soundVolume = Float(soundVolume)/10
                            AudioPlayer.shared.playStandardSound()
                })
            }
            .padding(.leading, General.innerPadding)
        }
        ZStack {
            Rectangle().fill(Color("MainPanel"))
                .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
            HStack(spacing: 0) {
                CustomText(text: Localization.shared.getTranslation(key: "voices").uppercased(), fontSize: General.mediumFont, isBold: true)
                Spacer()
                Button(action: {
                }) {
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                .onChange(of: isVoicesDecreasing, perform: { _ in
                    Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                        if self.isVoicesDecreasing == true {
                            if voiceVolume > 0 {
                                voiceVolume -= 1
                            } else {
                                voiceVolume = 10
                            }
                            
                            AudioPlayer.shared.voiceVolume = Float(voiceVolume)/10
                            AudioPlayer.shared.playHurtSound()
                        } else {
                            timer.invalidate()
                        }
                    }
                })
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: .infinity)
                        .updating($isVoicesDecreasing) { value, state, _ in state = value }
                )
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            if voiceVolume > 0 {
                                voiceVolume -= 1
                            } else {
                                voiceVolume = 10
                            }
                            
                            AudioPlayer.shared.voiceVolume = Float(voiceVolume)/10
                            AudioPlayer.shared.playHurtSound()
                })
                CustomText(text: "\(voiceVolume * 10)%".uppercased(), fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                }) {
                    ClearButton(label: ">", width: 35, height: General.largeHeight)
                }
                .onChange(of: isVoicesIncreasing, perform: { _ in
                    Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                        if self.isVoicesIncreasing == true {
                            if voiceVolume < 10 {
                                voiceVolume += 1
                            } else {
                                voiceVolume = 0
                            }
                            
                            AudioPlayer.shared.voiceVolume = Float(voiceVolume)/10
                            AudioPlayer.shared.playHurtSound()
                        } else {
                            timer.invalidate()
                        }
                    }
                })
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: .infinity)
                        .updating($isVoicesIncreasing) { value, state, _ in state = value }
                )
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            if voiceVolume < 10 {
                                voiceVolume += 1
                            } else {
                                voiceVolume = 0
                            }
                            
                            AudioPlayer.shared.voiceVolume = Float(voiceVolume)/10
                            AudioPlayer.shared.playHurtSound()
                })
            }
            .padding(.leading, General.innerPadding)
        }
        ZStack {
            Rectangle().fill(Color("MainPanel"))
                .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
            HStack(spacing: 0) {
                CustomText(text: Localization.shared.getTranslation(key: "haptic").uppercased(), fontSize: General.mediumFont, isBold: true)
                Spacer()
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    hapticToggle = !hapticToggle
                }) {
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                CustomText(text: Localization.shared.getTranslation(key: hapticToggle ? "enabled" : "disabled").uppercased(), fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    hapticToggle = !hapticToggle
                }) {
                    ClearButton(label: ">", width: 35, height: General.largeHeight)
                }
            }
            .padding(.leading, General.innerPadding)
        }
    }
}

struct AudioSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AudioSettingsView(generalVolume: Binding.constant(1), musicVolume: Binding.constant(1), soundVolume: Binding.constant(1), voiceVolume: Binding.constant(1), hapticToggle: Binding.constant(true), langIndex: 0)
    }
}
