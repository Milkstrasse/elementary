//
//  CreditsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 20.08.22.
//

import SwiftUI

struct CreditsView: View {
    @EnvironmentObject var manager: ViewManager
    
    @State var transitionToggle: Bool = true
    
    let currentFighter: Fighter
    
    @State var blink: Bool = false
    
    /// Sends signal to blink.
    /// - Parameter delay: The delay between blinks
    func blink(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            blink = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                blink = false
                
                let blinkInterval: Int = Int.random(in: 5 ... 10)
                blink(delay: TimeInterval(blinkInterval))
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color("MainPanel").ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color("TitlePanel")).frame(width: 255 + geometry.safeAreaInsets.bottom, height: General.largeHeight).shadow(radius: 5, x: 5, y: 0)
                            CustomText(text: Localization.shared.getTranslation(key: "credits").uppercased(), fontColor: Color("MainPanel"), fontSize: General.mediumFont, isBold: true).padding(.all, General.outerPadding).padding(.trailing, geometry.safeAreaInsets.bottom)
                        }
                        .ignoresSafeArea().offset(x: geometry.safeAreaInsets.bottom)
                    }
                    .padding([.top, .leading], General.outerPadding)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: General.innerPadding) {
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color("Positive"))
                                CustomText(text: Localization.shared.getTranslation(key: "characters").uppercased(), fontSize: General.mediumFont, isBold: true).padding(.leading, General.innerPadding)
                            }
                            .frame(height: General.largeHeight)
                            ZStack {
                                Rectangle().fill(Color("MainPanel"))
                                    .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                VStack(spacing: 0) {
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["characters", "Shirazu Yomi"]).uppercased(), fontSize: General.smallFont).frame(width: geometry.size.width - 2 * General.innerPadding - 2 * General.outerPadding, alignment: .leading)
                                }
                                .padding(.all, General.innerPadding)
                            }
                            .padding(.bottom, General.innerPadding/2)
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color("Positive"))
                                CustomText(text: Localization.shared.getTranslation(key: "audio").uppercased(), fontSize: General.mediumFont, isBold: true).padding(.leading, General.innerPadding)
                            }
                            .frame(height: General.largeHeight)
                            ZStack {
                                Rectangle().fill(Color("MainPanel"))
                                    .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                VStack(spacing: 2) {
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["menuSFX", "Kevin Fowler"]).uppercased(), fontSize: General.smallFont).frame(width: geometry.size.width - 2 * General.innerPadding - 2 * General.outerPadding, alignment: .leading)
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["voices", "Cici Fyre"]).uppercased(), fontSize: General.smallFont).frame(width: geometry.size.width - 2 * General.innerPadding - 2 * General.outerPadding, alignment: .leading)
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["music", "Ben Burnes"]).uppercased(), fontSize: General.smallFont).frame(width: geometry.size.width - 2 * General.innerPadding - 2 * General.outerPadding, alignment: .leading)
                                }
                                .padding(.all, General.innerPadding)
                            }
                            .padding(.bottom, General.innerPadding/2)
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color("Positive"))
                                CustomText(text: Localization.shared.getTranslation(key: "fonts").uppercased(), fontSize: General.mediumFont, isBold: true).padding(.leading, General.innerPadding)
                            }
                            .frame(height: General.largeHeight)
                            ZStack {
                                Rectangle().fill(Color("MainPanel"))
                                    .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                VStack(spacing: 2) {
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["icons", "FontAwesome"]).uppercased(), fontSize: General.smallFont).frame(width: geometry.size.width - 2 * General.innerPadding - 2 * General.outerPadding, alignment: .leading)
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["font", "Christian Robertson"]).uppercased(), fontSize: General.smallFont).frame(width: geometry.size.width - 2 * General.innerPadding - 2 * General.outerPadding, alignment: .leading)
                                }
                                .padding(.all, General.innerPadding)
                            }
                        }
                        .padding(.horizontal, General.outerPadding)
                    }
                    .frame(width: geometry.size.width).padding(.top, General.innerPadding).padding(.bottom, General.outerPadding)
                    HStack(spacing: General.innerPadding) {
                        Spacer()
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                        }) {
                            BorderedButton(label: "feedback", width: 170, height: General.smallHeight, isInverted: false)
                        }
                    }
                    .padding([.leading, .bottom, .trailing], General.outerPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height - geometry.size.width/2)
                ZStack(alignment: .bottomLeading) {
                    TitlePanel().fill(Color("Negative")).frame(width: geometry.size.height - geometry.size.width + geometry.safeAreaInsets.top).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0)).offset(x: -geometry.safeAreaInsets.top).shadow(radius: 5, x: 5, y: 5)
                    Image("Pattern").resizable(resizingMode: .tile).frame(width: 350, height: 145 + geometry.safeAreaInsets.top).clipShape(TriangleA()).offset(x: -geometry.safeAreaInsets.top)
                    currentFighter.getImage(blinking: blink, state: PlayerState.neutral).resizable().frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9).offset(x: transitionToggle ? -geometry.size.width * 0.9 : -15).shadow(radius: 5, x: 5, y: 0)
                        .animation(.linear(duration: 0.2).delay(0.4), value: transitionToggle)
                    VStack {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MainView(currentFighter: currentFighter).environmentObject(manager)))
                            }
                        }) {
                            IconButton(label: "\u{f00d}")
                        }
                        Spacer()
                    }
                    .padding(.all, General.outerPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).offset(y: transitionToggle ? -geometry.size.width - geometry.safeAreaInsets.top : ((geometry.size.width * 0.9) - geometry.size.width + geometry.safeAreaInsets.top)/2)
                .animation(.linear(duration: 0.3).delay(0.2), value: transitionToggle)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).offset(y: transitionToggle ? -50 : geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            let blinkInterval: Int = Int.random(in: 5 ... 10)
            blink(delay: TimeInterval(blinkInterval))
        }
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView(currentFighter: GlobalData.shared.fighters[0])
    }
}
