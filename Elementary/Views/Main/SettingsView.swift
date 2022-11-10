//
//  SettingsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 20.08.22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var manager: ViewManager
    
    @State var generalVolume: Int
    @State var musicVolume: Int
    @State var soundVolume: Int
    @State var voiceVolume: Int
    
    @State var hapticToggle: Bool
    
    @State var langIndex: Int = 0
    @State var textIndex: Int
    let textSpeeds: [String] = ["slow", "normal", "fast"]
    
    @State var teamIndex: Int
    let teamLimit: [String] = ["unlimited", "limited", "restricted"]
    @State var artifactIndex: Int
    let artifactsUse: [String] = ["unlimited", "limited", "disabled"]
    
    @State var attackModifier: Float
    @State var criticalModifier: Float
    @State var elementalModifier: Float
    @State var weatherModifier: Float
    @State var deviation: Int
    
    @GestureState var isGeneralDecreasing = false
    @GestureState var isGeneralIncreasing = false
    @GestureState var isMusicDecreasing = false
    @GestureState var isMusicIncreasing = false
    @GestureState var isSoundDecreasing = false
    @GestureState var isSoundIncreasing = false
    @GestureState var isVoicesDecreasing = false
    @GestureState var isVoicesIncreasing = false
    
    @State var transitionToggle: Bool = true
    
    init() {
        generalVolume = Int(AudioPlayer.shared.generalVolume * 10)
        musicVolume = Int(AudioPlayer.shared.musicVolume * 10)
        soundVolume = Int(AudioPlayer.shared.soundVolume * 10)
        voiceVolume = Int(AudioPlayer.shared.voiceVolume * 10)
        hapticToggle = AudioPlayer.shared.hapticToggle
    
        textIndex = GlobalData.shared.textSpeed
        
        teamIndex = GlobalData.shared.teamLimit
        artifactIndex = GlobalData.shared.artifactUse
        
        attackModifier = GlobalData.shared.attackModifier
        criticalModifier = GlobalData.shared.criticalModifier
        elementalModifier = GlobalData.shared.elementalModifier
        weatherModifier = GlobalData.shared.weatherModifier
        deviation = GlobalData.shared.deviation
    }
    
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
    
    /// Resets text values to default
    func resetTextSettings() {
        Localization.shared.loadLanguage(language: String(Locale.preferredLanguages[0].prefix(2)))
        langIndex = getCurrentLang()
        GlobalData.shared.textSpeed = 2
        textIndex = 2
    }
    
    /// Resets general values to default
    func resetGeneralSettings() {
        GlobalData.shared.teamLimit = 1
        teamIndex = 1
        GlobalData.shared.artifactUse = 0
        artifactIndex = 0
    }
    
    /// Resets advanced values to default
    func resetAdvancedSettings() {
        GlobalData.shared.attackModifier = 18
        attackModifier = 18
        GlobalData.shared.criticalModifier = 2
        criticalModifier = 2
        GlobalData.shared.elementalModifier = 2
        elementalModifier = 2
        GlobalData.shared.weatherModifier = 1.5
        weatherModifier = 1.5
        GlobalData.shared.deviation = 10
        deviation = 10
    }
    
    /// Resets all values to default
    func resetSettings() {
        resetAudioSettings()
        resetTextSettings()
        resetGeneralSettings()
        resetAdvancedSettings()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color("MainPanel")
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            
                            AudioPlayer.shared.hapticToggle = hapticToggle
                            
                            GlobalData.shared.teamLimit = teamIndex
                            GlobalData.shared.artifactUse = artifactIndex
                            
                            DispatchQueue.main.async {
                                SaveData.save()
                            }
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MainView(currentFighter: GlobalData.shared.getRandomFighter().name).environmentObject(manager)))
                            }
                        }) {
                            IconButton(label: "\u{f00d}")
                        }
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color("TitlePanel")).frame(width: 255, height: largeHeight).shadow(radius: 5, x: 5, y: 0)
                            CustomText(text: Localization.shared.getTranslation(key: "settings").uppercased(), fontColor: Color("MainPanel"), fontSize: mediumFont, isBold: true).padding(.all, outerPadding)
                        }
                    }
                    .padding([.top, .leading], outerPadding)
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack(alignment: .top, spacing: innerPadding) {
                            VStack(spacing: innerPadding/2) {
                                ZStack(alignment: .leading) {
                                    Rectangle().fill(Color("Positive"))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "audio").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            resetAudioSettings()
                                        }) {
                                            Text("\u{f2ed}").font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(Color("Text")).frame(width: smallHeight, height: smallHeight)
                                        }
                                    }
                                    .frame(height: largeHeight).padding(.leading, innerPadding)
                                }
                                .padding(.bottom, innerPadding/2)
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "general").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
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
                                        CustomText(text: "\(generalVolume * 10)%".uppercased(), fontSize: smallFont).frame(width: 100)
                                        Button(action: {
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
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
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "music").uppercased(), fontSize: mediumFont, isBold: true)
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
                                        CustomText(text: "\(musicVolume * 10)%".uppercased(), fontSize: smallFont).frame(width: 100)
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
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "sound").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
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
                                        CustomText(text: "\(soundVolume * 10)%".uppercased(), fontSize: smallFont).frame(width: 100)
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
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "voices").uppercased(), fontSize: mediumFont, isBold: true)
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
                                        CustomText(text: "\(voiceVolume * 10)%".uppercased(), fontSize: smallFont).frame(width: 100)
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
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "haptic").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            hapticToggle = !hapticToggle
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: Localization.shared.getTranslation(key: hapticToggle ? "enabled" : "disabled").uppercased(), fontSize: smallFont).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            hapticToggle = !hapticToggle
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack(alignment: .leading) {
                                    Rectangle().fill(Color("Positive"))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "text").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            resetTextSettings()
                                        }) {
                                            Text("\u{f2ed}").font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(Color("Text")).frame(width: smallHeight, height: smallHeight)
                                        }
                                    }
                                    .frame(height: largeHeight).padding(.leading, innerPadding)
                                }
                                .padding(.vertical, innerPadding/2)
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "textSpeed").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if textIndex > 1 {
                                                textIndex -= 1
                                            } else {
                                                textIndex = textSpeeds.count
                                            }
                                            
                                            GlobalData.shared.textSpeed = textIndex
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: Localization.shared.getTranslation(key: textSpeeds[textIndex - 1]).uppercased(), fontSize: smallFont).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if textIndex < textSpeeds.count {
                                                textIndex += 1
                                            } else {
                                                textIndex = 1
                                            }
                                            
                                            GlobalData.shared.textSpeed = textIndex
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "language").uppercased(), fontSize: mediumFont, isBold: true)
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
                                        CustomText(text: Localization.shared.getTranslation(key: Localization.shared.languages[langIndex]).uppercased(), fontSize: smallFont).frame(width: 100)
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
                            }
                            VStack(spacing: innerPadding/2) {
                                ZStack(alignment: .leading) {
                                    Rectangle().fill(Color("Positive"))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "general").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            resetGeneralSettings()
                                        }) {
                                            Text("\u{f2ed}").font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(Color("Text")).frame(width: smallHeight, height: smallHeight)
                                        }
                                    }
                                    .frame(height: largeHeight).padding(.leading, innerPadding)
                                }
                                .padding(.bottom, innerPadding/2)
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "teams").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if teamIndex <= 0 {
                                                teamIndex = teamLimit.count - 1
                                            } else {
                                                teamIndex -= 1
                                            }
                                            
                                            GlobalData.shared.teamLimit = teamIndex
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: Localization.shared.getTranslation(key: teamLimit[teamIndex]).uppercased(), fontSize: smallFont).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if teamIndex >= teamLimit.count - 1 {
                                                teamIndex = 0
                                            } else {
                                                teamIndex += 1
                                            }
                                            
                                            GlobalData.shared.teamLimit = teamIndex
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "artifacts").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if artifactIndex <= 0 {
                                                artifactIndex = artifactsUse.count - 1
                                            } else {
                                                artifactIndex -= 1
                                            }
                                            
                                            GlobalData.shared.artifactUse = artifactIndex
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: Localization.shared.getTranslation(key: artifactsUse[artifactIndex]).uppercased(), fontSize: smallFont).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if artifactIndex >= artifactsUse.count - 1 {
                                                artifactIndex = 0
                                            } else {
                                                artifactIndex += 1
                                            }
                                            
                                            GlobalData.shared.artifactUse = artifactIndex
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack(alignment: .leading) {
                                    Rectangle().fill(Color("Positive"))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "advanced").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            resetAdvancedSettings()
                                        }) {
                                            Text("\u{f2ed}").font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(Color("Text")).frame(width: smallHeight, height: smallHeight)
                                        }
                                    }
                                    .frame(height: largeHeight).padding(.leading, innerPadding)
                                }
                                .padding(.vertical, innerPadding/2)
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "attack").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if attackModifier <= 8 {
                                                attackModifier = 24
                                            } else {
                                                attackModifier -= 1
                                            }
                                            
                                            GlobalData.shared.attackModifier = attackModifier
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: "\(attackModifier)", fontSize: smallFont).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if attackModifier >= 24 {
                                                attackModifier = 8
                                            } else {
                                                attackModifier += 1
                                            }
                                            
                                            GlobalData.shared.attackModifier = attackModifier
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "critical").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if criticalModifier <= 1 {
                                                criticalModifier = 4
                                            } else {
                                                criticalModifier -= 0.5
                                            }
                                            
                                            GlobalData.shared.criticalModifier = criticalModifier
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: "\(criticalModifier)", fontSize: smallFont).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if criticalModifier >= 4 {
                                                criticalModifier = 1
                                            } else {
                                                criticalModifier += 0.5
                                            }
                                            
                                            GlobalData.shared.criticalModifier = criticalModifier
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "elemental").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if elementalModifier <= 1 {
                                                elementalModifier = 4
                                            } else {
                                                elementalModifier -= 0.5
                                            }
                                            
                                            GlobalData.shared.elementalModifier = elementalModifier
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: "\(elementalModifier)", fontSize: smallFont).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if elementalModifier >= 4 {
                                                elementalModifier = 1
                                            } else {
                                                elementalModifier += 0.5
                                            }
                                            
                                            GlobalData.shared.elementalModifier = elementalModifier
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "weather").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if weatherModifier <= 1 {
                                                weatherModifier = 4
                                            } else {
                                                weatherModifier -= 0.5
                                            }
                                            
                                            GlobalData.shared.weatherModifier = weatherModifier
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: "\(weatherModifier)", fontSize: smallFont).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if weatherModifier >= 4 {
                                                weatherModifier = 1
                                            } else {
                                                weatherModifier += 0.5
                                            }
                                            
                                            GlobalData.shared.weatherModifier = weatherModifier
                                        }) {
                                            ClearButton(label: ">", width: 35, height: largeHeight)
                                        }
                                    }
                                    .padding(.leading, innerPadding)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        CustomText(text: Localization.shared.getTranslation(key: "deviation").uppercased(), fontSize: mediumFont, isBold: true)
                                        Spacer()
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if deviation <= 0 {
                                                deviation = 20
                                            } else {
                                                deviation -= 5
                                            }
                                            
                                            GlobalData.shared.deviation = deviation
                                        }) {
                                            ClearButton(label: "<", width: 35, height: largeHeight)
                                        }
                                        CustomText(text: "\(deviation)%", fontSize: smallFont).frame(width: 100)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if deviation >= 20 {
                                                deviation = 0
                                            } else {
                                                deviation += 5
                                            }
                                            
                                            GlobalData.shared.deviation = deviation
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
                            
                            resetSettings()
                        }) {
                            BorderedButton(label: Localization.shared.getTranslation(key: "reset"), width: 170, height: smallHeight, isInverted: false)
                        }
                    }
                    .padding(.all, outerPadding)
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180)).offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            langIndex = getCurrentLang()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
