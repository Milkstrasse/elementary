//
//  SettingsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 20.08.22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var manager: ViewManager
    
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
    
    @State var transitionToggle: Bool = true
    
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
            ZStack(alignment: .top) {
                Color("Panel")
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            
                            AudioPlayer.shared.hapticToggle = hapticToggle
                            
                            GlobalData.shared.teamRestricted = teamToggle
                            GlobalData.shared.artifactUse = artifactIndex
                            
                            DispatchQueue.main.async {
                                SaveLogic.shared.save()
                            }
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MainView().environmentObject(manager)))
                            }
                        }) {
                            BorderedButton(label: "X", width: smallHeight, height: smallHeight, isInverted: false)
                        }
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color.white).frame(width: 255, height: largeHeight).shadow(radius: 5, x: 5, y: 0)
                            CustomText(text: Localization.shared.getTranslation(key: "settings").uppercased(), fontColor: Color("Title"), fontSize: 16, isBold: true).padding(.all, outerPadding)
                        }
                    }
                    .padding([.top, .leading], outerPadding)
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack(alignment: .top, spacing: innerPadding) {
                            VStack(spacing: innerPadding) {
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "music").uppercased(), fontSize: 16, isBold: true)
                                        Spacer()
                                        Button(action: {
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
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
                                        CustomText(text: "\(musicVolume * 10)%".uppercased(), fontSize: 14).frame(width: 100)
                                        Button(action: {
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
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
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "sound").uppercased(), fontSize: 16, isBold: true)
                                        Spacer()
                                        Button(action: {
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        .onChange(of: isMusicDecreasing, perform: { _ in
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
                                        CustomText(text: "\(soundVolume * 10)%".uppercased(), fontSize: 14).frame(width: 100)
                                        Button(action: {
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
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
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "voices").uppercased(), fontSize: 16, isBold: true)
                                        Spacer()
                                        Button(action: {
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
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
                                        CustomText(text: "\(voiceVolume * 10)%".uppercased(), fontSize: 14).frame(width: 100)
                                        Button(action: {
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
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
                                                    
                                                    AudioPlayer.shared.setVoiceVolume(volume: Float(musicVolume)/10)
                                                    AudioPlayer.shared.playHurtSound()
                                        })
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "haptic").uppercased(), fontSize: 16, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            hapticToggle = !hapticToggle
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: Localization.shared.getTranslation(key: hapticToggle ? "enabled" : "disabled").uppercased(), fontSize: 14).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            hapticToggle = !hapticToggle
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                            }
                            VStack(spacing: innerPadding) {
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "language").uppercased(), fontSize: 16, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if langIndex <= 0 {
                                                langIndex = Localization.shared.languages.count - 1
                                            } else {
                                                langIndex -= 1
                                            }
                                            
                                            Localization.shared.loadLanguage(language: Localization.shared.languages[langIndex])
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: Localization.shared.getTranslation(key: Localization.shared.languages[langIndex]).uppercased(), fontSize: 14).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if langIndex >= Localization.shared.languages.count - 1 {
                                                langIndex = 0
                                            } else {
                                                langIndex += 1
                                            }
                                            
                                            Localization.shared.loadLanguage(language: Localization.shared.languages[langIndex])
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "textSpeed").uppercased(), fontSize: 16, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if textIndex > 1 {
                                                textIndex -= 1
                                            } else {
                                                textIndex = textSpeeds.count
                                            }
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: Localization.shared.getTranslation(key: textSpeeds[textIndex - 1]).uppercased(), fontSize: 14).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if textIndex < textSpeeds.count {
                                                textIndex += 1
                                            } else {
                                                textIndex = 1
                                            }
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "teams").uppercased(), fontSize: 16, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            teamToggle = !teamToggle
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: Localization.shared.getTranslation(key: teamToggle ? "limited" : "unlimited").uppercased(), fontSize: 14).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            teamToggle = !teamToggle
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "artifacts").uppercased(), fontSize: 16, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if artifactIndex <= 0 {
                                                artifactIndex = artifactsUse.count - 1
                                            } else {
                                                artifactIndex -= 1
                                            }
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: Localization.shared.getTranslation(key: artifactsUse[artifactIndex]).uppercased(), fontSize: 14).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if artifactIndex >= artifactsUse.count - 1 {
                                                artifactIndex = 0
                                            } else {
                                                artifactIndex += 1
                                            }
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                            }
                        }
                        .padding(.horizontal, outerPadding)
                    }
                    .padding(.top, innerPadding)
                    HStack(spacing: innerPadding) {
                        Spacer()
                        Button(action: {
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
                        }) {
                            BorderedButton(label: Localization.shared.getTranslation(key: "reset"), width: 210, height: smallHeight, isInverted: false)
                        }
                    }
                    .padding([.leading, .bottom, .trailing], outerPadding).padding(.top, innerPadding)
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
            ZigZag().fill(Color.black).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(musicVolume: 10, soundVolume: 10, voiceVolume: 10, hapticToggle: true, textIndex: 2, teamToggle: true, artifactIndex: 0)
    }
}
