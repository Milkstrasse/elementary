//
//  FighterInfoView.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.08.22.
//

import SwiftUI

struct FighterInfoView: View {
    let fighter: Fighter
    
    @State var userProgress: UserProgress
    
    @State var selectedSpell: Spell? = nil
    @Binding var selectedOutfit: Int
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(fighter.getElement().symbol) ?? 0xf128)
        return String(Character(UnicodeScalar(icon) ?? "\u{f128}"))
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollViewReader { value in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: innerPadding) {
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color("Positive"))
                                HStack(spacing: 0) {
                                    CustomText(text: Localization.shared.getTranslation(key: fighter.name).uppercased(), fontSize: mediumFont, isBold: true)
                                    CustomText(text: " - " + Localization.shared.getTranslation(key: fighter.title).uppercased(), fontSize: smallFont, isBold: false)
                                    Spacer()
                                    Text(createSymbol()).font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(Color("Text")).frame(width: smallHeight, height: smallHeight)
                                }
                                .frame(height: largeHeight).padding(.leading, innerPadding)
                            }
                            .id(0)
                            ZStack {
                                Rectangle().fill(Color("MainPanel")).overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: fighter.name + "Descr"), geoWidth:  geometry.size.width - 2 * outerPadding), fontSize: smallFont).frame(width: geometry.size.width - 2 * innerPadding - 2 * outerPadding, alignment: .leading).padding(.all, innerPadding)
                            }
                            BaseFighterOverviewView(modifiedBase: fighter.getModifiedBase(), base: fighter.base)
                            VStack(spacing: innerPadding/2) {
                                ForEach(fighter.spells, id: \.self) { spell in
                                    SpellView(spell: spell, desccription: Localization.shared.getTranslation(key: spell.name + "Descr"))
                                }
                            }
                            HStack(spacing: innerPadding) {
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if fighter.outfitIndex <= 0 {
                                                fighter.outfitIndex = fighter.data.outfits.count - 1
                                            } else {
                                                fighter.outfitIndex -= 1
                                            }
                                            
                                            selectedOutfit = fighter.outfitIndex
                                        }) {
                                            ClearButton(label: "<", width: 35, height: smallHeight)
                                        }
                                        HStack(spacing: innerPadding/2) {
                                            if !userProgress.isOutfitUnlocked(fighter: fighter.name, index: selectedOutfit) {
                                                CustomText(text: Localization.shared.getTranslation(key: fighter.data.outfits[selectedOutfit].name).uppercased(), fontSize: smallFont, isBold: true)
                                                CustomText(text: "-", fontSize: smallFont)
                                                CustomText(text: "\(fighter.data.outfits[selectedOutfit].cost)", fontColor: userProgress.points < fighter.data.outfits[selectedOutfit].cost ? Color("Negative") : Color("Positive"), fontSize: smallFont)
                                                Text("\u{f890}").font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(userProgress.points < fighter.data.outfits[selectedOutfit].cost ? Color("Negative") : Color("Positive"))
                                            } else {
                                                CustomText(text: Localization.shared.getTranslation(key: fighter.data.outfits[selectedOutfit].name).uppercased(), fontSize: smallFont, isBold: false)
                                            }
                                        }
                                        .frame(width: geometry.size.width - 2 * outerPadding - 179 - innerPadding)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if fighter.outfitIndex >= fighter.data.outfits.count - 1 {
                                                fighter.outfitIndex = 0
                                            } else {
                                                fighter.outfitIndex += 1
                                            }
                                            
                                            selectedOutfit = fighter.outfitIndex
                                        }) {
                                            ClearButton(label: ">", width: 35, height: smallHeight)
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                                Button(action: {
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    userProgress.unlockOutfit(points: fighter.data.outfits[selectedOutfit].cost, fighter: fighter.name, index: selectedOutfit)
                                    
                                    GlobalData.shared.userProgress = userProgress
                                    SaveData.saveProgress()
                                }) {
                                    BorderedButton(label: "purchase", width: 105, height: smallHeight, isInverted: false)
                                }
                                .opacity(userProgress.points < fighter.data.outfits[selectedOutfit].cost || userProgress.isOutfitUnlocked(fighter: fighter.name, index: selectedOutfit) ? 0.5 : 1).disabled(userProgress.points < fighter.data.outfits[selectedOutfit].cost || userProgress.isOutfitUnlocked(fighter: fighter.name, index: selectedOutfit))
                            }
                        }
                        .padding(.horizontal, outerPadding)
                    }
                    .padding(.top, outerPadding + innerPadding + 50).padding(.bottom, outerPadding)
                    .onChange(of: fighter) { newValue in
                        value.scrollTo(0)
                    }
                }
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
        }
    }
}

struct FighterInfoView_Previews: PreviewProvider {
    static var previews: some View {
        FighterInfoView(fighter: exampleFighter, userProgress: UserProgress(), selectedOutfit: Binding.constant(0))
    }
}
