//
//  AdvancedSettingsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 29.01.23.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @Binding var attackModifier: Float
    @Binding var criticalModifier: Float
    @Binding var elementalModifier: Float
    @Binding var weatherModifier: Float
    @Binding var deviation: Int
    
    @State var langIndex: Int
    
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
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(Color("Positive"))
            HStack {
                CustomText(text: Localization.shared.getTranslation(key: "advanced").uppercased(), fontSize: General.mediumFont, isBold: true)
                Spacer()
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    resetAdvancedSettings()
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
                CustomText(text: Localization.shared.getTranslation(key: "attack").uppercased(), fontSize: General.mediumFont, isBold: true)
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
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                CustomText(text: "\(attackModifier)", fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    if attackModifier >= 24 {
                        attackModifier = 8
                    } else {
                        attackModifier += 1
                    }
                    
                    GlobalData.shared.attackModifier = attackModifier
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
                CustomText(text: Localization.shared.getTranslation(key: "critical").uppercased(), fontSize: General.mediumFont, isBold: true)
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
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                CustomText(text: "\(criticalModifier)", fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    if criticalModifier >= 4 {
                        criticalModifier = 1
                    } else {
                        criticalModifier += 0.5
                    }
                    
                    GlobalData.shared.criticalModifier = criticalModifier
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
                CustomText(text: Localization.shared.getTranslation(key: "elemental").uppercased(), fontSize: General.mediumFont, isBold: true)
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
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                CustomText(text: "\(elementalModifier)", fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    if elementalModifier >= 4 {
                        elementalModifier = 1
                    } else {
                        elementalModifier += 0.5
                    }
                    
                    GlobalData.shared.elementalModifier = elementalModifier
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
                CustomText(text: Localization.shared.getTranslation(key: "weather").uppercased(), fontSize: General.mediumFont, isBold: true)
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
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                CustomText(text: "\(weatherModifier)", fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    if weatherModifier >= 4 {
                        weatherModifier = 1
                    } else {
                        weatherModifier += 0.5
                    }
                    
                    GlobalData.shared.weatherModifier = weatherModifier
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
                CustomText(text: Localization.shared.getTranslation(key: "deviation").uppercased(), fontSize: General.mediumFont, isBold: true)
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
                    ClearButton(label: "<", width: 35, height: General.largeHeight)
                }
                CustomText(text: "\(deviation)%", fontSize: General.smallFont).frame(width: 100)
                Button(action: {
                    AudioPlayer.shared.playStandardSound()
                    
                    if deviation >= 20 {
                        deviation = 0
                    } else {
                        deviation += 5
                    }
                    
                    GlobalData.shared.deviation = deviation
                }) {
                    ClearButton(label: ">", width: 35, height: General.largeHeight)
                }
            }
            .padding(.leading, General.innerPadding)
        }
    }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView(attackModifier: Binding.constant(3), criticalModifier: Binding.constant(2), elementalModifier: Binding.constant(2), weatherModifier: Binding.constant(1.5), deviation: Binding.constant(0), langIndex: 0)
    }
}
