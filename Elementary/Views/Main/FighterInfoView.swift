//
//  FighterInfoView.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.08.22.
//

import SwiftUI

struct FighterInfoView: View {
    let fighter: Fighter
    
    @State var selectedSpell: Spell? = nil
    
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
        FighterInfoView(fighter: exampleFighter)
    }
}
