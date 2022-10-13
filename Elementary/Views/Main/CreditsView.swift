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
    
    @State var blink: Bool = false
    @State var stopBlinking: Bool = false
    
    /// Sends signal to blink.
    /// - Parameter delay: The delay between blinks
    func blink(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            blink = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                blink = false
                
                if !stopBlinking {
                    let blinkInterval: Int = Int.random(in: 5 ... 10)
                    blink(delay: TimeInterval(blinkInterval))
                }
            }
        }
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color("Panel")
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color.white).frame(width: 255, height: largeHeight).shadow(radius: 5, x: 5, y: 0)
                            CustomText(text: Localization.shared.getTranslation(key: "credits").uppercased(), fontColor: Color("Title"), fontSize: 16, isBold: true).padding(.all, outerPadding)
                        }
                    }
                    .padding([.top, .leading], outerPadding)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: innerPadding) {
                            ZStack {
                                Rectangle().fill(Color("Panel"))
                                    .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                VStack(spacing: 0) {
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["characters", "Shirazu Yomi"]).uppercased(), fontSize: 14).frame(width: geometry.size.width - 2 * innerPadding - 2 * outerPadding, alignment: .leading)
                                }
                                .padding(.all, innerPadding)
                            }
                            ZStack {
                                Rectangle().fill(Color("Panel"))
                                    .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                VStack(spacing: 2) {
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["menuSFX", "Kevin Fowler"]).uppercased(), fontSize: 14).frame(width: geometry.size.width - 2 * innerPadding - 2 * outerPadding, alignment: .leading)
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["voices", "Cici Fyre"]).uppercased(), fontSize: 14).frame(width: geometry.size.width - 2 * innerPadding - 2 * outerPadding, alignment: .leading)
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["music", "Ben Burnes"]).uppercased(), fontSize: 14).frame(width: geometry.size.width - 2 * innerPadding - 2 * outerPadding, alignment: .leading)
                                }
                                .padding(.all, innerPadding)
                            }
                            ZStack {
                                Rectangle().fill(Color("Panel"))
                                    .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                VStack(spacing: 2) {
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["icons", "FontAwesome"]).uppercased(), fontSize: 14).frame(width: geometry.size.width - 2 * innerPadding - 2 * outerPadding, alignment: .leading)
                                    CustomText(text: Localization.shared.getTranslation(key: "creditBy", params: ["font", "Christian Robertson"]).uppercased(), fontSize: 14).frame(width: geometry.size.width - 2 * innerPadding - 2 * outerPadding, alignment: .leading)
                                }
                                .padding(.all, innerPadding)
                            }
                        }
                        .padding(.horizontal, outerPadding)
                    }
                    .frame(width: geometry.size.width).padding(.top, innerPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height - geometry.size.width/2)
                ZStack(alignment: .bottomLeading) {
                    TitlePanel().fill(Color("Background1")).frame(width: geometry.size.height - geometry.size.width).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0)).shadow(radius: 5, x: 5, y: 5)
                    TriangleA().fill(Color("Background2")).frame(height: 145).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    Image(fileName: blink ? exampleFighter.name + "_blink" : exampleFighter.name).resizable().frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9).offset(x: transitionToggle ? -geometry.size.width * 0.9 : -15).shadow(radius: 5, x: 5, y: 0)
                        .animation(.linear(duration: 0.2).delay(0.4), value: transitionToggle)
                    VStack {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MainView().environmentObject(manager)))
                            }
                        }) {
                            BorderedButton(label: "X", width: smallHeight, height: smallHeight, isInverted: true)
                        }
                        Spacer()
                    }
                    .padding(.all, outerPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).offset(y: transitionToggle ? -geometry.size.width : 0)
                .animation(.linear(duration: 0.3).delay(0.2), value: transitionToggle)
            }
            ZigZag().fill(Color.black).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            let blinkInterval: Int = Int.random(in: 5 ... 10)
            blink(delay: TimeInterval(blinkInterval))
        }
        .onDisappear {
            stopBlinking = true
        }
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
