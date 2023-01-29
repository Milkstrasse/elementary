//
//  GeneralSettingsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 29.01.23.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Binding var teamIndex: Int
    let teamLimit: [String] = ["unlimited", "limited", "veryLimited"]
    @Binding var artifactIndex: Int
    let artifactsUse: [String] = ["unlimited", "limited", "disabled"]
    
    @State var langIndex: Int
    
    /// Resets general values to default
    func resetGeneralSettings() {
        GlobalData.shared.teamLimit = 1
        teamIndex = 1
        GlobalData.shared.artifactUse = 0
        artifactIndex = 0
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(Color("Positive"))
            HStack {
                CustomText(text: Localization.shared.getTranslation(key: "general").uppercased(), fontSize: General.mediumFont, isBold: true)
                Spacer()
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    resetGeneralSettings()
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
                CustomText(text: Localization.shared.getTranslation(key: "teams").uppercased(), fontSize: General.mediumFont, isBold: true)
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
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                CustomText(text: Localization.shared.getTranslation(key: teamLimit[teamIndex]).uppercased(), fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    if teamIndex >= teamLimit.count - 1 {
                        teamIndex = 0
                    } else {
                        teamIndex += 1
                    }
                    
                    GlobalData.shared.teamLimit = teamIndex
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
                CustomText(text: Localization.shared.getTranslation(key: "artifacts").uppercased(), fontSize: General.mediumFont, isBold: true)
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
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                CustomText(text: Localization.shared.getTranslation(key: artifactsUse[artifactIndex]).uppercased(), fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    if artifactIndex >= artifactsUse.count - 1 {
                        artifactIndex = 0
                    } else {
                        artifactIndex += 1
                    }
                    
                    GlobalData.shared.artifactUse = artifactIndex
                }) {
                    ClearButton(label: ">", width: 35, height: General.largeHeight)
                }
            }
            .padding(.leading, General.innerPadding)
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView(teamIndex: Binding.constant(0), artifactIndex: Binding.constant(0), langIndex: 0)
    }
}
