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
    @Binding var selectedSkin: Int
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { value in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: innerPadding) {
                        Rectangle().fill(Color("MainPanel")).frame(height: 85).overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth)).id(0)
                        BaseFighterOverviewView(base: fighter.getModifiedBase())
                        VStack(spacing: innerPadding/2) {
                            ForEach(fighter.spells, id: \.self) { spell in
                                SpellView(spell: spell, desccription: Localization.shared.getTranslation(key: spell.name + "Descr"))
                            }
                        }
                        HStack(spacing: innerPadding) {
                            ZStack {
                                Rectangle().fill(Color("MainPanel"))
                                    .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                HStack {
                                    Button(action: {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if fighter.skinIndex <= 0 {
                                            fighter.skinIndex = fighter.data.skins.count - 1
                                        } else {
                                            fighter.skinIndex -= 1
                                        }
                                        
                                        selectedSkin = fighter.skinIndex
                                    }) {
                                        ClearButton(label: "<", width: 35, height: smallHeight)
                                    }
                                    Spacer()
                                    HStack(spacing: innerPadding/2) {
                                        if selectedSkin > 0 && (userProgress.unlockedSkins[fighter.name] == nil) {
                                            CustomText(text: Localization.shared.getTranslation(key: fighter.data.skins[selectedSkin]).uppercased(), fontSize: smallFont, isBold: true)
                                            CustomText(text: "-", fontSize: smallFont)
                                            CustomText(text: "200", fontColor: userProgress.points < 200 ? Color("Negative") : Color("Positive"), fontSize: smallFont)
                                            Text("\u{f890}").font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(userProgress.points < 200 ? Color("Negative") : Color("Positive"))
                                        } else {
                                            CustomText(text: Localization.shared.getTranslation(key: selectedSkin > 0 ? fighter.getSkin(index: selectedSkin) : "Default").uppercased(), fontSize: smallFont, isBold: false)
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if fighter.skinIndex >= fighter.data.skins.count - 1 {
                                            fighter.skinIndex = 0
                                        } else {
                                            fighter.skinIndex += 1
                                        }
                                        
                                        selectedSkin = fighter.skinIndex
                                    }) {
                                        ClearButton(label: ">", width: 35, height: smallHeight)
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                            Button(action: {
                                AudioPlayer.shared.playStandardSound()
                                
                                userProgress.unlockSkin(points: 200, fighter: fighter.name, index: selectedSkin)
                                
                                GlobalData.shared.userProgress = userProgress
                                SaveData.save()
                            }) {
                                BorderedButton(label: Localization.shared.getTranslation(key: "purchase"), width: 155, height: smallHeight, isInverted: false)
                            }
                            .disabled(userProgress.points < 200 || (userProgress.unlockedSkins[fighter.name] != nil))
                        }
                    }
                    .padding(.horizontal, outerPadding)
                }
                .padding(.top, outerPadding + innerPadding + 50).padding(.bottom, outerPadding)
                .onChange(of: fighter) { newValue in
                    value.scrollTo(0)
                }
            }
        }
    }
}

struct FighterInfoView_Previews: PreviewProvider {
    static var previews: some View {
        FighterInfoView(fighter: exampleFighter, userProgress: UserProgress(), selectedSkin: Binding.constant(0))
    }
}
