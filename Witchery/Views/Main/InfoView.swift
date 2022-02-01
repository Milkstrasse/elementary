//
//  InfoView.swift
//  Witchery
//
//  Created by Janice Hablützel on 31.01.22.
//

import SwiftUI

struct InfoView: View {
    @Binding var infoToggle: Bool
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
                        CustomText(key: "info", fontSize: 18).padding(.horizontal, 10).background(Color("background")).offset(x: 10)
                    }
                    .frame(height: 60).padding(.horizontal, 15).padding(.leading, 10)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
                                VStack(spacing: 0) {
                                    CustomText(text: "elements", fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: "each witch has her own element, her element and\nthe element of spells grants her more or less\npower against other witches depending on their\nelements.", fontSize: 14).frame(width: 280, alignment: .leading)
                                }
                                .padding(.all, 15)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
                                VStack(spacing: 0) {
                                    CustomText(text: "spells", fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: "spells are used to attack, heal or hex  witches.\nthey cost mana", fontSize: 14).frame(width: 280, alignment: .leading)
                                }
                                .padding(.all, 15)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
                                VStack(spacing: 0) {
                                    CustomText(text: "weather", fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                    CustomText(text: "weather boost certain elements.", fontSize: 14).frame(width: 280, alignment: .leading)
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

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(infoToggle: Binding.constant(true), offsetX: Binding.constant(0))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
