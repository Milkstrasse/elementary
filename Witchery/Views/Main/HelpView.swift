//
//  HelpView.swift
//  Witchery
//
//  Created by Janice Hablützel on 24.07.22.
//

import SwiftUI

struct HelpView: View {
    @EnvironmentObject var manager: ViewManager
    
    @Binding var offsetY: CGFloat
    @Binding var helpToggle: Bool
    
    @Binding var transitionToggle: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                Text(Localization.shared.getTranslation(key: "help")).foregroundColor(Color.white).frame(maxWidth: .infinity, alignment: .leading).frame(height: 60)
                    .padding(.horizontal, 15)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                            VStack(spacing: 0) {
                                CustomText(key: "help1", fontSize: mediumFontSize, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: "help1Descr"), geoWidth: geometry.size.width - 60), fontSize: smallFontSize).frame(width: geometry.size.width - 60, alignment: .leading)
                            }
                            .padding(.all, 15)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                            VStack(spacing: 0) {
                                CustomText(key: "help2", fontSize: mediumFontSize, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                //Image("elements").resizable().frame(width: geometry.size.width - 60, height: geometry.size.width - 60)
                            }
                            .padding(.all, 15)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                            VStack(spacing: 0) {
                                CustomText(key: "help3", fontSize: mediumFontSize, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: "help3Descr"), geoWidth: geometry.size.width - 60), fontSize: smallFontSize).frame(width: geometry.size.width - 60, alignment: .leading)
                            }
                            .padding(.all, 15)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                            VStack(spacing: 0) {
                                CustomText(key: "help4", fontSize: mediumFontSize, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: "help4Descr"), geoWidth: geometry.size.width - 60), fontSize: smallFontSize).frame(width: geometry.size.width - 60, alignment: .leading)
                            }
                            .padding(.all, 15)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                            VStack(spacing: 0) {
                                CustomText(key: "help5", fontSize: mediumFontSize, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: "help5Descr"), geoWidth: geometry.size.width - 60), fontSize: smallFontSize).frame(width: geometry.size.width - 60, alignment: .leading)
                            }
                            .padding(.all, 15)
                        }
                    }
                    .padding(.horizontal, 15)
                }
                HStack(spacing: 10) {
                    Button(Localization.shared.getTranslation(key: "tutorial")) {
                        AudioPlayer.shared.playStandardSound()
                        
                        transitionToggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            manager.setView(view: AnyView(TutorialSelectionView().environmentObject(manager)))
                        }
                    }
                    .buttonStyle(BasicButton(width: geometry.size.width - 85))
                    Button(Localization.shared.getTranslation(key: "X")) {
                        AudioPlayer.shared.playCancelSound()
                        
                        offsetY = 0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            helpToggle = false
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

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(offsetY: Binding.constant(0), helpToggle: Binding.constant(true), transitionToggle: Binding.constant(false))
    }
}
