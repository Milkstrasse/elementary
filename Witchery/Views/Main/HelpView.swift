//
//  HelpView.swift
//  Witchery
//
//  Created by Janice Hablützel on 31.01.22.
//

import SwiftUI

struct HelpView: View {
    @EnvironmentObject var manager: ViewManager
    
    @Binding var infoToggle: Bool
    @Binding var offsetX: CGFloat
    
    @Binding var transitionToggle: Bool
    
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
                        CustomText(key: "help", fontSize: 18).padding(.horizontal, 10).background(Color("background")).offset(x: 10)
                    }
                    .frame(height: 60).padding(.horizontal, 15).padding(.leading, 10)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
                                VStack(spacing: 0) {
                                    CustomText(key: "help1", fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: "help1Descr"), geoWidth: 255), fontSize: 14).frame(width: 280, alignment: .leading)
                                }
                                .padding(.all, 15)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
                                VStack(spacing: 0) {
                                    CustomText(key: "help2", fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                    Image("elements").resizable().frame(width: 280, height: 280)
                                }
                                .padding(.all, 15)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
                                VStack(spacing: 0) {
                                    CustomText(key: "help3", fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: "help3Descr"), geoWidth: 255), fontSize: 14).frame(width: 280, alignment: .leading)
                                }
                                .padding(.all, 15)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
                                VStack(spacing: 0) {
                                    CustomText(key: "help4", fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: "help4Descr"), geoWidth: 255), fontSize: 14).frame(width: 280, alignment: .leading)
                                }
                                .padding(.all, 15)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
                                VStack(spacing: 0) {
                                    CustomText(key: "help5", fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: "help5Descr"), geoWidth: 255), fontSize: 14).frame(width: 280, alignment: .leading)
                                }
                                .padding(.all, 15)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    Spacer().frame(height: 10)
                    HStack(spacing: 5) {
                        Spacer()
                        Button(Localization.shared.getTranslation(key: "tutorial")) {
                            AudioPlayer.shared.playStandardSound()
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(TutorialSelectionView().environmentObject(manager)))
                            }
                        }
                        .buttonStyle(BasicButton(width: 160))
                        Button("X") {
                            AudioPlayer.shared.playCancelSound()
                            offsetX = -450
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                infoToggle = false
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

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(infoToggle: Binding.constant(true), offsetX: Binding.constant(0), transitionToggle: Binding.constant(false))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
