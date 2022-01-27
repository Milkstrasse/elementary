//
//  OptionsView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct SettingsView: View {
    @Binding var settingsToggle: Bool
    @Binding var offsetX: CGFloat
    
    @State var langIndex: Int = 0
    @State var soundVolume: Int = 10
    @State var musicVolume: Int = 10
    
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
                    ZStack(alignment: .trailing) {
                        Triangle().fill(Color("outline")).offset(x: -1)
                        Triangle().fill(Color("background"))
                    }
                    Rectangle().fill(Color("background")).frame(width: 315 + geometry.safeAreaInsets.trailing)
                }
                .offset(x: geometry.safeAreaInsets.trailing)
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color("outline")).frame(height: 1)
                        CustomText(key: "settings", fontSize: 18).padding(.horizontal, 10).background(Color("background")).offset(x: 10)
                    }
                    .frame(height: 60).padding(.horizontal, 15).padding(.leading, 10)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(height: 40)
                                HStack {
                                    CustomText(key: "music", fontSize: 14).frame(width: 100, alignment: .leading)
                                    Button("<") {
                                        if musicVolume > 0 {
                                            musicVolume -= 1
                                        } else {
                                            musicVolume = 10
                                        }
                                        
                                        AudioPlayer.shared.setMusicVolume(volume: Float(musicVolume)/10)
                                        AudioPlayer.shared.playStandardSound()
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    Spacer()
                                    CustomText(text: "\(musicVolume * 10)%", fontSize: 14)
                                    Spacer()
                                    Button(">") {
                                        if musicVolume < 10 {
                                            musicVolume += 1
                                        } else {
                                            musicVolume = 0
                                        }
                                        
                                        AudioPlayer.shared.setMusicVolume(volume: Float(musicVolume)/10)
                                        AudioPlayer.shared.playStandardSound()
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                }
                                .padding(.horizontal, 15)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(height: 40)
                                HStack {
                                    CustomText(key: "sound", fontSize: 14).frame(width: 100, alignment: .leading)
                                    Button("<") {
                                        if soundVolume > 0 {
                                            soundVolume -= 1
                                        } else {
                                            soundVolume = 10
                                        }
                                        
                                        AudioPlayer.shared.setSoundVolume(volume: Float(soundVolume)/10)
                                        AudioPlayer.shared.playStandardSound()
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    Spacer()
                                    CustomText(text: "\(soundVolume * 10)%", fontSize: 14)
                                    Spacer()
                                    Button(">") {
                                        if soundVolume < 10 {
                                            soundVolume += 1
                                        } else {
                                            soundVolume = 0
                                        }
                                        
                                        AudioPlayer.shared.setSoundVolume(volume: Float(soundVolume)/10)
                                        AudioPlayer.shared.playStandardSound()
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                }
                                .padding(.horizontal, 15)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 40)
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(height: 40)
                                HStack {
                                    CustomText(key: "language", fontSize: 14).frame(width: 100, alignment: .leading)
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
                                    CustomText(key: Localization.shared.languages[langIndex], fontSize: 14)
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
                                .padding(.horizontal, 15)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    Spacer().frame(height: 10)
                    HStack(spacing: 5) {
                        Spacer()
                        Button(Localization.shared.getTranslation(key: "reset")) {
                            AudioPlayer.shared.playStandardSound()
                            Localization.shared.loadLanguage(language: String(Locale.preferredLanguages[0].prefix(2)))
                            langIndex = getCurrentLang()
                            
                            AudioPlayer.shared.setSoundVolume(volume: 1.0)
                            soundVolume = 10
                            AudioPlayer.shared.setMusicVolume(volume: 1.0)
                            musicVolume = 10
                        }
                        .buttonStyle(BasicButton(width: 160))
                        Button("X") {
                            AudioPlayer.shared.playCancelSound()
                            
                            UserDefaults.standard.set(Localization.shared.languages[langIndex], forKey: "lang")
                            UserDefaults.standard.set(Float(soundVolume)/10, forKey: "sound")
                            UserDefaults.standard.set(Float(musicVolume)/10, forKey: "music")
                            
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
            soundVolume = Int(AudioPlayer.shared.soundVolume * 10)
            musicVolume = Int(AudioPlayer.shared.musicVolume * 10)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsToggle: Binding.constant(true), offsetX: Binding.constant(0))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
