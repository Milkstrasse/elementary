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
    
    @State var currentFighter: Fighter
    @State var selectedOutfit: Int = 0
    
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
    
    /// Returns wether the outfit is selected or not.
    /// - Parameters:
    ///   - fighter: The owner of the outfit
    ///   - index: The index of the outfit
    /// - Returns: Returns wether the outfit is selected or not
    func isSelected(fighter: Fighter, index: Int) -> Bool {
        if fighter == currentFighter {
            if index == selectedOutfit {
                return true
            }
        }
        
        return false
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
                            CustomText(text: Localization.shared.getTranslation(key: "shop").uppercased(), fontColor: Color("MainPanel"), fontSize: General.mediumFont, isBold: true).padding(.all, General.outerPadding).padding(.trailing, geometry.safeAreaInsets.bottom)
                        }
                        .ignoresSafeArea().offset(x: geometry.safeAreaInsets.bottom)
                    }
                    .padding([.top, .leading], General.outerPadding)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: General.innerPadding/2) {
                            ForEach(GlobalData.shared.fighters, id: \.self) { fighter in
                                if fighter.data.outfits.count > 1 {
                                    ZStack(alignment: .leading) {
                                        Rectangle().fill(Color("Positive"))
                                        CustomText(text: Localization.shared.getTranslation(key: fighter.name).uppercased(), fontSize: General.mediumFont, isBold: true).padding(.leading, General.innerPadding)
                                    }
                                    .frame(height: General.largeHeight).padding(.bottom, General.innerPadding/2)
                                }
                                ForEach(1 ..< fighter.data.outfits.count, id: \.self) { index in
                                    Button(action: {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if isSelected(fighter: fighter, index: index) {
                                            selectedOutfit = 0
                                        } else {
                                            currentFighter = fighter
                                            selectedOutfit = index
                                        }
                                    }) {
                                        ZStack(alignment: .trailing) {
                                            Rectangle().fill(Color("MainPanel"))
                                                .overlay(Rectangle().strokeBorder(isSelected(fighter: fighter, index: index) ? Color("Positive") : Color("Border"), lineWidth: General.borderWidth))
                                            HStack(spacing: General.innerPadding/2) {
                                                CustomText(text: Localization.shared.getTranslation(key: fighter.data.outfits[index].name).uppercased(), fontSize: General.smallFont)
                                                CustomText(text: "-", fontSize: General.smallFont)
                                                if userProgress.isOutfitUnlocked(fighter: fighter.name, index: index) {
                                                    CustomText(text: "\(fighter.data.outfits[index].cost)", fontSize: General.smallFont)
                                                } else {
                                                    CustomText(text: "\(fighter.data.outfits[index].cost)", fontColor: userProgress.points < fighter.data.outfits[index].cost ? Color("Negative") : Color("Positive"), fontSize: General.smallFont)
                                                    Text("\u{f890}").font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(userProgress.points < fighter.data.outfits[index].cost ? Color("Negative") : Color("Positive"))
                                                }
                                                Spacer()
                                            }
                                            .padding(.all, General.innerPadding)
                                            Button(action: {
                                                AudioPlayer.shared.playStandardSound()
                                                
                                                userProgress.unlockOutfit(points: fighter.data.outfits[index].cost, fighter: fighter.name, index: index)
                                                
                                                GlobalData.shared.userProgress = userProgress
                                                SaveData.saveProgress()
                                            }) {
                                                BasicButton(label: Localization.shared.getTranslation(key: "purchase"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                            }
                                            .opacity(userProgress.points < fighter.data.outfits[index].cost || userProgress.isOutfitUnlocked(fighter: fighter.name, index: index) ? 0.5 : 1).disabled(userProgress.points < fighter.data.outfits[index].cost || userProgress.isOutfitUnlocked(fighter: fighter.name, index: index))
                                        }
                                        .frame(height: General.largeHeight).padding(.bottom, index == fighter.data.outfits.count - 1 ? General.innerPadding/2 : 0)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, General.outerPadding)
                    }
                    .frame(width: geometry.size.width).padding(.top, General.innerPadding).padding(.bottom, General.outerPadding)
                    HStack(spacing: General.innerPadding) {
                        Spacer()
                        ZStack(alignment: .trailing) {
                            Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth)
                            HStack(spacing: General.innerPadding/2) {
                                CustomText(text: userProgress.getFormattedPoints(), fontSize: General.smallFont)
                                Text("\u{f890}").font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color("Text"))
                            }
                            .padding(.trailing, General.innerPadding)
                        }
                        .frame(width: 170, height: General.smallHeight)
                    }
                    .padding([.leading, .bottom, .trailing], General.outerPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height - geometry.size.width/2)
                ZStack(alignment: .bottomLeading) {
                    TitlePanel().fill(Color("Negative")).frame(width: geometry.size.height - geometry.size.width + geometry.safeAreaInsets.top).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0)).offset(x: -geometry.safeAreaInsets.top).shadow(radius: 5, x: 5, y: 5)
                    Image("Pattern").resizable(resizingMode: .tile).frame(width: 350, height: 145 + geometry.safeAreaInsets.top).clipShape(TriangleA()).offset(x: -geometry.safeAreaInsets.top)
                    currentFighter.getImage(index: selectedOutfit, blinking: blink, state: PlayerState.neutral).resizable().frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9).offset(x: transitionToggle ? -geometry.size.width * 0.9 : -15).shadow(radius: 5, x: 5, y: 0)
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
        .onDisappear {
            stopBlinking = true
        }
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView(userProgress: UserProgress(), currentFighter: GlobalData.shared.fighters[0])
    }
}
