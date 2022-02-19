//
//  CreditsView.swift
//  Witchery
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct CreditsView: View {
    @Binding var creditsToggle: Bool
    @Binding var offsetX: CGFloat
    
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
                        CustomText(key: "credits", fontSize: 18).padding(.horizontal, 10).background(Color("background")).offset(x: 10)
                    }
                    .frame(height: 60).padding(.horizontal, 15).padding(.leading, 10)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
                                VStack(spacing: 0) {
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["characters", "Shirazu Yomi"]), fontSize: 14).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["menuSFX", "Kevin Fowler"]), fontSize: 14).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["voices", "Cici Fyre"]), fontSize: 14).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["music", "Theo Allen"]), fontSize: 14).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["icons", "FontAwesome"]), fontSize: 14).frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.all, 15)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    Spacer().frame(height: 10)
                    HStack(spacing: 5) {
                        Spacer()
                        Button("X") {
                            AudioPlayer.shared.playCancelSound()
                            offsetX = -450
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                creditsToggle = false
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
        }
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView(creditsToggle: Binding.constant(true), offsetX: Binding.constant(0))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
