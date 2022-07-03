//
//  OptionsView.swift
//  Witchery
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct SettingsView: View {
    @Binding var settingsToggle: Bool
    @Binding var offsetX: CGFloat
    
    @State var musicVolume: Int
    @State var soundVolume: Int
    @State var voiceVolume: Int
    
    @State var hapticToggle: Bool
    
    @State var langIndex: Int = 0
    @State var textIndex: Int
    let textSpeeds: [String] = ["slow", "normal", "fast"]
    
    @State var teamToggle: Bool
    @State var artifactIndex: Int
    let artifactsUse: [String] = ["unlimited", "limited", "disabled"]
    
    @GestureState var isMusicDecreasing = false
    @GestureState var isMusicIncreasing = false
    @GestureState var isSoundDecreasing = false
    @GestureState var isSoundIncreasing = false
    @GestureState var isVoicesDecreasing = false
    @GestureState var isVoicesIncreasing = false
    
    /// Returns the index of the current language.
    /// - Returns: Returns the index of the current language
    func getCurrentLang() -> Int {
        for index in Localization.shared.languages.indices {
            if Localization.shared.currentLang == Localization.shared.languages[index] {
                return index
            }
        }
        
        return 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                HStack(spacing: 0) {
                    Spacer()
                    Triangle().fill(Color("panel"))
                    Rectangle().fill(Color("panel")).frame(width: 315 + geometry.safeAreaInsets.trailing)
                }
                .offset(x: geometry.safeAreaInsets.trailing)
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color("outline")).frame(height: 2)
                        CustomText(key: "settings", fontSize: largeFontSize, isBold: true).padding(.horizontal, 10).background(Color("panel")).offset(x: 10)
                    }
                    .frame(height: 60).padding(.horizontal, 15).padding(.leading, 10)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 5) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                HStack(spacing: 0) {
                                    Spacer().frame(width: 135)
                                    Spacer()
                                    CustomText(text: "\(musicVolume * 10)%", fontSize: smallFontSize)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    CustomText(key: "music", fontSize: smallFontSize).frame(width: 120, alignment: .leading)
                                    Button("<") {
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    .onChange(of: isMusicDecreasing, perform: { _ in
                                        Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                            if self.isMusicDecreasing == true {
                                                if musicVolume > 0 {
                                                    musicVolume -= 1
                                                } else {
                                                    musicVolume = 10
                                                }
                                                
                                                AudioPlayer.shared.setMusicVolume(volume: Float(musicVolume)/10)
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
                                                
                                                AudioPlayer.shared.setMusicVolume(volume: Float(musicVolume)/10)
                                                AudioPlayer.shared.playStandardSound()
                                    })
                                    Spacer()
                                    Button(">") {
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    .onChange(of: isMusicIncreasing, perform: { _ in
                                        Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                            if self.isMusicIncreasing == true {
                                                if musicVolume < 10 {
                                                    musicVolume += 1
                                                } else {
                                                    musicVolume = 0
                                                }
                                                
                                                AudioPlayer.shared.setMusicVolume(volume: Float(musicVolume)/10)
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
                                                
                                                AudioPlayer.shared.setMusicVolume(volume: Float(musicVolume)/10)
                                                AudioPlayer.shared.playStandardSound()
                                    })
                                }
                                .padding(.leading, 15).padding(.trailing, 5)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                HStack(spacing: 0) {
                                    Spacer().frame(width: 135)
                                    Spacer()
                                    CustomText(text: "\(soundVolume * 10)%", fontSize: smallFontSize)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    CustomText(key: "sound", fontSize: smallFontSize).frame(width: 120, alignment: .leading)
                                    Button("<") {
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    .onChange(of: isSoundDecreasing, perform: { _ in
                                        Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                            if self.isSoundDecreasing == true {
                                                if soundVolume > 0 {
                                                    soundVolume -= 1
                                                } else {
                                                    soundVolume = 10
                                                }
                                                
                                                AudioPlayer.shared.setSoundVolume(volume: Float(soundVolume)/10)
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
                                                
                                                AudioPlayer.shared.setSoundVolume(volume: Float(soundVolume)/10)
                                                AudioPlayer.shared.playStandardSound()
                                    })
                                    Spacer()
                                    Button(">") {
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    .onChange(of: isSoundIncreasing, perform: { _ in
                                        Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                            if self.isSoundIncreasing == true {
                                                if soundVolume < 10 {
                                                    soundVolume += 1
                                                } else {
                                                    soundVolume = 0
                                                }
                                                
                                                AudioPlayer.shared.setSoundVolume(volume: Float(soundVolume)/10)
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
                                                
                                                AudioPlayer.shared.setSoundVolume(volume: Float(soundVolume)/10)
                                                AudioPlayer.shared.playStandardSound()
                                    })
                                }
                                .padding(.leading, 15).padding(.trailing, 5)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                HStack(spacing: 0) {
                                    Spacer().frame(width: 135)
                                    Spacer()
                                    CustomText(text: "\(voiceVolume * 10)%", fontSize: smallFontSize)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    CustomText(key: "voices", fontSize: smallFontSize).frame(width: 120, alignment: .leading)
                                    Button("<") {
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    .onChange(of: isVoicesDecreasing, perform: { _ in
                                        Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                            if self.isVoicesDecreasing == true {
                                                if voiceVolume > 0 {
                                                    voiceVolume -= 1
                                                } else {
                                                    voiceVolume = 10
                                                }
                                                
                                                AudioPlayer.shared.setVoiceVolume(volume: Float(voiceVolume)/10)
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
                                                
                                                AudioPlayer.shared.setVoiceVolume(volume: Float(voiceVolume)/10)
                                                AudioPlayer.shared.playHurtSound()
                                    })
                                    Spacer()
                                    Button(">") {
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    .onChange(of: isVoicesIncreasing, perform: { _ in
                                        Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                            if self.isVoicesIncreasing == true {
                                                if voiceVolume < 10 {
                                                    voiceVolume += 1
                                                } else {
                                                    voiceVolume = 0
                                                }
                                                
                                                AudioPlayer.shared.setVoiceVolume(volume: Float(voiceVolume)/10)
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
                                                
                                                AudioPlayer.shared.setVoiceVolume(volume: Float(voiceVolume)/10)
                                                AudioPlayer.shared.playHurtSound()
                                    })
                                }
                                .padding(.leading, 15).padding(.trailing, 5)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                HStack(spacing: 0) {
                                    Spacer().frame(width: 135)
                                    Spacer()
                                    CustomText(key: hapticToggle ? "enabled" : "disabled", fontSize: smallFontSize)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    CustomText(key: "haptic", fontSize: smallFontSize).frame(width: 120, alignment: .leading)
                                    Button("<") {
                                        AudioPlayer.shared.playStandardSound()
                                        hapticToggle = !hapticToggle
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    Spacer()
                                    Button(">") {
                                        AudioPlayer.shared.playStandardSound()
                                        hapticToggle = !hapticToggle
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                }
                                .padding(.leading, 15).padding(.trailing, 5)
                            }
                            .padding(.bottom, 5)
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                HStack(spacing: 0) {
                                    Spacer().frame(width: 135)
                                    Spacer()
                                    CustomText(key: Localization.shared.languages[langIndex], fontSize: smallFontSize)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    CustomText(key: "language", fontSize: smallFontSize).frame(width: 120, alignment: .leading)
                                    Button("<") {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if langIndex <= 0 {
                                            langIndex = Localization.shared.languages.count - 1
                                        } else {
                                            langIndex -= 1
                                        }
                                        
                                        Localization.shared.loadLanguage(language: Localization.shared.languages[langIndex])
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    Spacer()
                                    Button(">") {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if langIndex >= Localization.shared.languages.count - 1 {
                                            langIndex = 0
                                        } else {
                                            langIndex += 1
                                        }
                                        
                                        Localization.shared.loadLanguage(language: Localization.shared.languages[langIndex])
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                }
                                .padding(.leading, 15).padding(.trailing, 5)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                HStack(spacing: 0) {
                                    Spacer().frame(width: 135)
                                    Spacer()
                                    CustomText(key: textSpeeds[textIndex - 1], fontSize: smallFontSize)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    CustomText(key: "textSpeed", fontSize: smallFontSize).frame(width: 120, alignment: .leading)
                                    Button("<") {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if textIndex > 1 {
                                            textIndex -= 1
                                        } else {
                                            textIndex = textSpeeds.count
                                        }
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    Spacer()
                                    Button(">") {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if textIndex < textSpeeds.count {
                                            textIndex += 1
                                        } else {
                                            textIndex = 1
                                        }
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                }
                                .padding(.leading, 15).padding(.trailing, 5)
                            }
                            .padding(.bottom, 5)
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                HStack(spacing: 0) {
                                    Spacer().frame(width: 135)
                                    Spacer()
                                    CustomText(key: teamToggle ? "limited" : "unlimited", fontSize: smallFontSize)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    CustomText(key: "covens", fontSize: smallFontSize).frame(width: 120, alignment: .leading)
                                    Button("<") {
                                        AudioPlayer.shared.playStandardSound()
                                        teamToggle = !teamToggle
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    Spacer()
                                    Button(">") {
                                        AudioPlayer.shared.playStandardSound()
                                        teamToggle = !teamToggle
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                }
                                .padding(.leading, 15).padding(.trailing, 5)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                HStack(spacing: 0) {
                                    Spacer().frame(width: 135)
                                    Spacer()
                                    CustomText(key: artifactsUse[artifactIndex], fontSize: smallFontSize)
                                    Spacer()
                                }
                                HStack(spacing: 0) {
                                    CustomText(key: "artifacts", fontSize: smallFontSize).frame(width: 120, alignment: .leading)
                                    Button("<") {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if artifactIndex <= 0 {
                                            artifactIndex = artifactsUse.count - 1
                                        } else {
                                            artifactIndex -= 1
                                        }
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    Spacer()
                                    Button(">") {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if artifactIndex >= artifactsUse.count - 1 {
                                            artifactIndex = 0
                                        } else {
                                            artifactIndex += 1
                                        }
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                }
                                .padding(.leading, 15).padding(.trailing, 5)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    Spacer().frame(height: 10)
                    HStack(spacing: 5) {
                        Spacer()
                        Button(Localization.shared.getTranslation(key: "reset")) {
                            AudioPlayer.shared.playStandardSound()
                            
                            AudioPlayer.shared.setMusicVolume(volume: 1.0)
                            musicVolume = 10
                            AudioPlayer.shared.setSoundVolume(volume: 1.0)
                            soundVolume = 10
                            AudioPlayer.shared.setVoiceVolume(volume: 1.0)
                            voiceVolume = 10
                            AudioPlayer.shared.hapticToggle = true
                            hapticToggle = true
                            
                            Localization.shared.loadLanguage(language: String(Locale.preferredLanguages[0].prefix(2)))
                            langIndex = getCurrentLang()
                            GlobalData.shared.textSpeed = 2
                            textIndex = 2
                            
                            GlobalData.shared.teamRestricted = true
                            teamToggle = true
                            GlobalData.shared.artifactUse = 0
                            artifactIndex = 0
                        }
                        .buttonStyle(BasicButton(width: 160))
                        Button("X") {
                            AudioPlayer.shared.playCancelSound()
                            
                            AudioPlayer.shared.hapticToggle = hapticToggle
                            
                            GlobalData.shared.teamRestricted = teamToggle
                            GlobalData.shared.artifactUse = artifactIndex
                            
                            DispatchQueue.main.async {
                                SaveLogic.shared.save()
                            }
                            
                            offsetX = -450
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                settingsToggle = false
                            }
                        }
                        .buttonStyle(BasicButton(width: 40))
                    }
                    .padding(.trailing, 15)
                }
                .frame(width: 340).padding(.vertical, 15)
            }
            .padding(.trailing, offsetX).animation(.linear(duration: 0.2), value: offsetX).ignoresSafeArea(.all, edges: .bottom)

        }
        .onAppear {
            offsetX = 0
            langIndex = getCurrentLang()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsToggle: Binding.constant(true), offsetX: Binding.constant(0), musicVolume: 10, soundVolume: 10, voiceVolume: 10, hapticToggle: true, textIndex: 2, teamToggle: true, artifactIndex: 0)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
