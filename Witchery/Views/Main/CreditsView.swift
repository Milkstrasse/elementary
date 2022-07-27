//
//  CreditsView.swift
//  Witchery
//
//  Created by Janice Hablützel on 25.07.22.
//

import SwiftUI

struct CreditsView: View {
    @Binding var offsetY: CGFloat
    @Binding var creditsToggle: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                Text(Localization.shared.getTranslation(key: "credits")).foregroundColor(Color.white).frame(maxWidth: .infinity, alignment: .leading).frame(height: 60)
                    .padding(.horizontal, 15)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                            VStack(spacing: 0) {
                                CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["characters", "Shirazu Yomi"]), fontSize: smallFontSize).frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.all, 15)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                            VStack(spacing: 0) {
                                CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["menuSFX", "Kevin Fowler"]), fontSize: smallFontSize).frame(maxWidth: .infinity, alignment: .leading)
                                CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["voices", "Cici Fyre"]), fontSize: smallFontSize).frame(maxWidth: .infinity, alignment: .leading)
                                CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["music", "Theo Allen"]), fontSize: smallFontSize).frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.all, 15)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                            VStack(spacing: 0) {
                                CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["icons", "FontAwesome"]), fontSize: smallFontSize).frame(maxWidth: .infinity, alignment: .leading)
                                CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["font", "Kimberly Geswein"]), fontSize: smallFontSize).frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.all, 15)
                        }
                    }
                    .padding(.horizontal, 15)
                }
                HStack(spacing: 10) {
                    Spacer()
                    Button(Localization.shared.getTranslation(key: "X")) {
                        AudioPlayer.shared.playCancelSound()
                        
                        offsetY = 0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            creditsToggle = false
                        }
                    }
                    .buttonStyle(BasicButton(width: 45))
                }
                .padding(.horizontal, 15)
            }
            .padding(.vertical, 15).offset(y: geometry.size.height - offsetY).animation(.linear(duration: 0.3), value: offsetY)
            .onAppear {
                offsetY = geometry.size.height
            }
        }
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView(offsetY: Binding.constant(0), creditsToggle: Binding.constant(true))
    }
}
