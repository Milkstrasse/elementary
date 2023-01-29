//
//  TextSettingsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 29.01.23.
//

import SwiftUI

struct TextSettingsView: View {
    @Binding var langIndex: Int
    @Binding var textIndex: Int
    let textSpeeds: [String] = ["slow", "normal", "fast", "rapid"]
    
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
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(Color("Positive"))
            HStack {
                CustomText(text: Localization.shared.getTranslation(key: "text").uppercased(), fontSize: General.mediumFont, isBold: true)
                Spacer()
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    resetTextSettings()
                }) {
                    Text("\u{f2ed}").font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color("Text")).frame(width: General.smallHeight, height: General.smallHeight)
                }
            }
            .frame(height: General.largeHeight).padding(.leading, General.innerPadding)
        }
        .padding(.vertical, General.innerPadding/2)
        ZStack {
            Rectangle().fill(Color("MainPanel"))
                .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
            HStack(spacing: 0) {
                CustomText(text: Localization.shared.getTranslation(key: "textSpeed").uppercased(), fontSize: General.mediumFont, isBold: true)
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
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                CustomText(text: Localization.shared.getTranslation(key: textSpeeds[textIndex - 1]).uppercased(), fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    if textIndex < textSpeeds.count {
                        textIndex += 1
                    } else {
                        textIndex = 1
                    }
                    
                    GlobalData.shared.textSpeed = textIndex
                }) {
                    ClearButton(label: ">", width: 35, height: General.largeHeight)
                }
            }
            .padding(.leading, General.innerPadding)
        }
        ZStack {
            Rectangle().fill(Color("MainPanel"))
                .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
            HStack(spacing: 0) {
                CustomText(text: Localization.shared.getTranslation(key: "language").uppercased(), fontSize: General.mediumFont, isBold: true)
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
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                CustomText(text: Localization.shared.getTranslation(key: Localization.shared.languages[langIndex]).uppercased(), fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    if langIndex >= Localization.shared.languages.count - 1 {
                        langIndex = 0
                    } else {
                        langIndex += 1
                    }
                    
                    Localization.shared.loadLanguage(language: Localization.shared.languages[langIndex])
                }) {
                    ClearButton(label: ">", width: 35, height: General.largeHeight)
                }
            }
            .padding(.leading, General.innerPadding)
        }
    }
}

struct TextSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TextSettingsView(langIndex: Binding.constant(0), textIndex: Binding.constant(0))
    }
}
