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
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollViewReader { value in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: General.innerPadding) {
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color("Positive"))
                                HStack(spacing: 0) {
                                    CustomText(text: Localization.shared.getTranslation(key: fighter.name).uppercased(), fontSize: General.mediumFont, isBold: true)
                                    Spacer()
                                    Text(General.createSymbol(string: fighter.getElement().symbol)).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color("Text")).frame(width: General.smallHeight, height: General.smallHeight)
                                }
                                .frame(height: General.largeHeight).padding(.leading, General.innerPadding)
                            }
                            .id(0)
                            ZStack {
                                Rectangle().fill(Color("MainPanel")).overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: fighter.name + "Descr"), geoWidth:  geometry.size.width - 2 * General.outerPadding), fontSize: General.smallFont).frame(width: geometry.size.width - 2 * General.innerPadding - 2 * General.outerPadding, alignment: .leading).padding(.all, General.innerPadding)
                            }
                            BaseFighterOverviewView(modifiedBase: fighter.getModifiedBase(), base: fighter.base)
                            VStack(spacing: General.innerPadding/2) {
                                ForEach(fighter.singleSpells, id: \.self) { spell in
                                    SpellView(spell: spell, desccription: Localization.shared.getTranslation(key: spell.name + "Descr"))
                                }
                            }
                            VStack(spacing: General.innerPadding/2) {
                                ForEach(fighter.multiSpells, id: \.self) { spell in
                                    SpellView(spell: spell, desccription: Localization.shared.getTranslation(key: spell.name + "Descr"))
                                }
                            }
                            HStack(spacing: General.innerPadding) {
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
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
                                            ClearButton(label: "<", width: 35, height: General.smallHeight)
                                        }
                                        HStack(spacing: General.innerPadding/2) {
                                            if !userProgress.isOutfitUnlocked(fighter: fighter.name, index: selectedOutfit) {
                                                CustomText(text: Localization.shared.getTranslation(key: fighter.data.outfits[selectedOutfit].name).uppercased(), fontSize: General.smallFont, isBold: true)
                                                CustomText(text: "-", fontSize: General.smallFont)
                                                CustomText(text: "\(fighter.data.outfits[selectedOutfit].cost)", fontColor: userProgress.points < fighter.data.outfits[selectedOutfit].cost ? Color("Negative") : Color("Positive"), fontSize: General.smallFont)
                                                Text("\u{f890}").font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(userProgress.points < fighter.data.outfits[selectedOutfit].cost ? Color("Negative") : Color("Positive"))
                                            } else {
                                                CustomText(text: Localization.shared.getTranslation(key: fighter.data.outfits[selectedOutfit].name).uppercased(), fontSize: General.smallFont, isBold: false)
                                            }
                                        }
                                        .frame(width: geometry.size.width - 2 * General.outerPadding - 179 - General.innerPadding)
                                        Button(action: {
                                            AudioPlayer.shared.playStandardSound()
                                            
                                            if fighter.outfitIndex >= fighter.data.outfits.count - 1 {
                                                fighter.outfitIndex = 0
                                            } else {
                                                fighter.outfitIndex += 1
                                            }
                                            
                                            selectedOutfit = fighter.outfitIndex
                                        }) {
                                            ClearButton(label: ">", width: 35, height: General.smallHeight)
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
                                    BorderedButton(label: "purchase", width: 105, height: General.smallHeight, isInverted: false)
                                }
                                .opacity(userProgress.points < fighter.data.outfits[selectedOutfit].cost || userProgress.isOutfitUnlocked(fighter: fighter.name, index: selectedOutfit) ? 0.5 : 1).disabled(userProgress.points < fighter.data.outfits[selectedOutfit].cost || userProgress.isOutfitUnlocked(fighter: fighter.name, index: selectedOutfit))
                            }
                        }
                        .padding(.horizontal, General.outerPadding)
                    }
                    .padding(.top, General.outerPadding + General.innerPadding + 50).padding(.bottom, General.outerPadding)
                    .onChange(of: fighter) { newValue in
                        value.scrollTo(0)
                    }
                }
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
        }
    }
}

struct FighterInfoView_Previews: PreviewProvider {
    static var previews: some View {
        FighterInfoView(fighter: GlobalData.shared.fighters[0], userProgress: UserProgress(), selectedOutfit: Binding.constant(0))
    }
}
