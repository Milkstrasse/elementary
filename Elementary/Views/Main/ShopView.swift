//
//  ShopView.swift
//  Elementary
//
//  Created by Janice Hablützel on 09.11.22.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var manager: ViewManager
    
    @State var userProgress: UserProgress
    
    @State var transitionToggle: Bool = true
    
    @State var currentFighter: Fighter? = nil
    @State var selectedSkin: Int = 0
    
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
    
    func isSelected(fighter: Fighter, index: Int) -> Bool {
        if fighter == currentFighter {
            if index == selectedSkin {
                return true
            }
        }
        
        return false
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color("MainPanel")
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color("TitlePanel")).frame(width: 255, height: largeHeight).shadow(radius: 5, x: 5, y: 0)
                            CustomText(text: Localization.shared.getTranslation(key: "credits").uppercased(), fontColor: Color("MainPanel"), fontSize: mediumFont, isBold: true).padding(.all, outerPadding)
                        }
                    }
                    .padding([.top, .leading], outerPadding)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: innerPadding) {
                            ForEach(GlobalData.shared.fighters, id: \.self) { fighter in
                                ForEach(1 ..< fighter.data.skins.count, id: \.self) { index in
                                    HStack {
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if isSelected(fighter: fighter, index: index) {
                                                currentFighter = nil
                                                selectedSkin = 0
                                            } else {
                                                currentFighter = fighter
                                                selectedSkin = index
                                            }
                                        }) {
                                            ZStack {
                                                Rectangle().fill(Color("MainPanel"))
                                                    .overlay(Rectangle().strokeBorder(isSelected(fighter: fighter, index: index) ? Color("Positive") : Color("Border"), lineWidth: borderWidth))
                                                HStack(spacing: innerPadding/2) {
                                                    CustomText(text: Localization.shared.getTranslation(key: fighter.data.skins[index]).uppercased(), fontSize: smallFont)
                                                    CustomText(text: "-", fontSize: smallFont)
                                                    if userProgress.unlockedSkins[fighter.name] != nil {
                                                        CustomText(text: "owned", fontSize: smallFont)
                                                    } else {
                                                        CustomText(text: "200", fontColor: userProgress.points < 200 ? Color("Negative") : Color("Positive"), fontSize: smallFont)
                                                        Text("\u{f890}").font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(userProgress.points < 200 ? Color("Negative") : Color("Positive"))
                                                    }
                                                    Spacer()
                                                }
                                                .padding(.all, innerPadding)
                                            }
                                        }
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            userProgress.unlockSkin(points: 200, fighter: fighter.name, index: selectedSkin)
                                            
                                            GlobalData.shared.userProgress = userProgress
                                            SaveData.save()
                                        }) {
                                            BorderedButton(label: "purchase", width: 105, height: smallHeight, isInverted: false)
                                        }
                                        .opacity(userProgress.points < 200 || (userProgress.unlockedSkins[fighter.name] != nil) ? 0.5 : 1).disabled(userProgress.points < 200 || (userProgress.unlockedSkins[fighter.name] != nil))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, outerPadding)
                    }
                    .frame(width: geometry.size.width).padding(.top, innerPadding).padding(.bottom, outerPadding)
                    HStack(spacing: innerPadding) {
                        Spacer()
                        ZStack(alignment: .trailing) {
                            Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth)
                            HStack(spacing: innerPadding/2) {
                                CustomText(text: userProgress.getFormattedPoints(), fontSize: smallFont)
                                Text("\u{f890}").font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(Color("Text"))
                            }
                            .padding(.trailing, innerPadding)
                        }
                        .frame(width: 170, height: smallHeight)
                    }
                    .padding([.leading, .bottom, .trailing], outerPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height - geometry.size.width/2)
                ZStack(alignment: .bottomLeading) {
                    TitlePanel().fill(Color("Negative")).frame(width: geometry.size.height - geometry.size.width).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0)).shadow(radius: 5, x: 5, y: 5)
                    Image("Pattern").frame(width: 240, height: 145).clipShape(TriangleA())
                    if currentFighter != nil {
                        Image(fileName: blink ? currentFighter!.name + currentFighter!.getSkin(index: selectedSkin) + "_blink" : currentFighter!.name + currentFighter!.getSkin(index: selectedSkin)).resizable().frame(width: geometry.size.width - smallHeight - 2 * outerPadding, height: geometry.size.width - smallHeight - 2 * outerPadding).offset(x: transitionToggle ? -geometry.size.width * 0.9 : -50).shadow(radius: 5, x: 5, y: 0)
                            .animation(.linear(duration: 0.2).delay(0.4), value: transitionToggle)
                    } else {
                        Rectangle().fill(Color.clear).frame(width: geometry.size.width - smallHeight - 2 * outerPadding, height: geometry.size.width - smallHeight - 2 * outerPadding)
                    }
                    VStack {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MainView(currentFighter: GlobalData.shared.getRandomFighter().name).environmentObject(manager)))
                            }
                        }) {
                            IconButton(label: "\u{f00d}")
                        }
                        Spacer()
                    }
                    .padding(.all, outerPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).offset(y: transitionToggle ? -geometry.size.width : ((geometry.size.width - smallHeight - 2 * outerPadding) - geometry.size.width)/2)
                .animation(.linear(duration: 0.3).delay(0.2), value: transitionToggle)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180)).offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView(userProgress: UserProgress())
    }
}
