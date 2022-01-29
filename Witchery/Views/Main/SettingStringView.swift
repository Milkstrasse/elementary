//
//  SettingStringView.swift
//  Witchery
//
//  Created by Janice Hablützel on 29.01.22.
//

import SwiftUI

struct SettingSTringView: View {
    @Binding var settingIndex: Int
    
    
    var body: some View {
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
}

struct SettingStringView_Previews: PreviewProvider {
    static var previews: some View {
        SettingStringView()
    }
}
