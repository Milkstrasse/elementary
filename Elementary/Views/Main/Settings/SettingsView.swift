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
    
    @State var teamIndex: Int
    @State var artifactIndex: Int
    
    @State var attackModifier: Float
    @State var criticalModifier: Float
    @State var elementalModifier: Float
    @State var weatherModifier: Float
    @State var deviation: Int
    
    @State var transitionToggle: Bool = true
    
    /// Creates the settings view.
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
                Color("MainPanel").ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            
                            AudioPlayer.shared.hapticToggle = hapticToggle
                            
                            GlobalData.shared.teamLimit = teamIndex
                            GlobalData.shared.artifactUse = artifactIndex
                            
                            DispatchQueue.main.async {
                                SaveData.saveSettings()
                            }
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MainView(currentFighter: GlobalData.shared.getRandomFighter()).environmentObject(manager)))
                            }
                        }) {
                            IconButton(label: "\u{f00d}")
                        }
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color("TitlePanel")).frame(width: 255 + geometry.safeAreaInsets.bottom, height: General.largeHeight).shadow(radius: 5, x: 5, y: 0)
                            CustomText(text: Localization.shared.getTranslation(key: "settings").uppercased(), fontColor: Color("MainPanel"), fontSize: General.mediumFont, isBold: true).padding(.all, General.outerPadding).padding(.trailing, geometry.safeAreaInsets.bottom)
                        }
                        .ignoresSafeArea().offset(x: geometry.safeAreaInsets.bottom)
                    }
                    .padding([.top, .leading], General.outerPadding)
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack(alignment: .top, spacing: General.innerPadding) {
                            VStack(spacing: General.innerPadding/2) {
                                AudioSettingsView(generalVolume: $generalVolume, musicVolume: $musicVolume, soundVolume: $soundVolume, voiceVolume: $voiceVolume, hapticToggle: $hapticToggle, langIndex: langIndex)
                                TextSettingsView(langIndex: $langIndex, textIndex: $textIndex)
                            }
                            VStack(spacing: General.innerPadding/2) {
                                GeneralSettingsView(teamIndex: $teamIndex, artifactIndex: $artifactIndex, langIndex: langIndex)
                                AdvancedSettingsView(attackModifier: $attackModifier, criticalModifier: $criticalModifier, elementalModifier: $elementalModifier, weatherModifier: $weatherModifier, deviation: $deviation, langIndex: langIndex)
                            }
                        }
                        .padding(.horizontal, General.outerPadding)
                    }
                    .padding(.top, General.innerPadding)
                    HStack(spacing: General.innerPadding) {
                        Spacer()
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            resetSettings()
                        }) {
                            BorderedButton(label: Localization.shared.getTranslation(key: "reset"), width: 170, height: General.smallHeight, isInverted: false)
                        }
                    }
                    .padding(.all, General.outerPadding)
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).offset(y: transitionToggle ? -50 : geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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
