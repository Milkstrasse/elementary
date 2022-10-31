//
//  HelpView.swift
//  Elementary
//
//  Created by Janice Hablützel on 20.08.22.
//

import SwiftUI

struct HelpView: View {
    @EnvironmentObject var manager: ViewManager
    
    @State var transitionToggle: Bool = true
    
    @State var showInfo: Bool = false
    
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
                            CustomText(text: Localization.shared.getTranslation(key: "tutorial").uppercased(), fontColor: Color("Title"), fontSize: mediumFont, isBold: true).padding(.all, outerPadding)
                        }
                    }
                    .padding([.top, .leading], outerPadding)
                    ScrollViewReader { value in
                        ScrollView(.vertical, showsIndicators: false) {
                            HStack(alignment: .top, spacing: outerPadding) {
                                VStack(alignment: .leading, spacing: innerPadding) {
                                    ForEach(0 ..< 4) { index in
                                        ZStack {
                                            Rectangle().fill(Color("Panel"))
                                                .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                            VStack(spacing: 0) {
                                                CustomText(text: Localization.shared.getTranslation(key: "help\(index + 1)").uppercased(), fontSize: mediumFont, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                                CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: "help\(index + 1)Descr"), geoWidth: geometry.size.width - innerPadding - 2 * outerPadding), fontSize: smallFont).frame(width: geometry.size.width - 2 * innerPadding - 2 * outerPadding, alignment: .leading)
                                            }
                                            .padding(.all, innerPadding)
                                        }
                                        .id(index).fixedSize()
                                    }
                                }
                                ElementalChartView().frame(width: geometry.size.width - 2 * outerPadding)
                            }
                            .padding(.horizontal, outerPadding)
                            .onChange(of: showInfo) { newValue in
                                value.scrollTo(0)
                            }
                        }
                        .frame(width: geometry.size.width, alignment: showInfo ? .trailing : .leading).padding(.top, innerPadding).animation(.linear(duration: 0.3), value: showInfo).clipped()
                    }
                    HStack(spacing: innerPadding) {
                        Spacer()
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            showInfo = !showInfo
                        }) {
                            BorderedButton(label: Localization.shared.getTranslation(key: showInfo ? "hideChart" : "showChart"), width: 210, height: smallHeight, isInverted: false)
                        }
                    }
                    .padding([.leading, .bottom, .trailing], outerPadding).padding(.top, innerPadding)
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

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
