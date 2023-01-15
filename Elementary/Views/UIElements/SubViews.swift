//
//  SubViews.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.08.22.
//

import SwiftUI

struct RectanglePortraitView: View {
    let fighter: Fighter
    
    let isSelected: Bool
    let width: CGFloat
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(fighter.getElement().symbol) ?? 0xf128)
        return String(Character(UnicodeScalar(icon) ?? "\u{f128}"))
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle().fill(Color("MainPanel")).overlay(Rectangle().strokeBorder(isSelected ?  Color("Positive") : Color("Border"), lineWidth: borderWidth))
            fighter.getImage(blinking: false, state: PlayerState.neutral).resizable().aspectRatio(contentMode: .fill).scaleEffect(1.1).offset(x: -20, y: 5).frame(width: width - borderWidth * 2, height: width * 1.55 - borderWidth * 2).clipped().padding(.all, borderWidth)
            ZStack(alignment: .bottomTrailing) {
                TriangleA().fill(isSelected ?  Color("Positive") : Color("Border")).frame(height: 40).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                Text(createSymbol()).font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(Color.white).padding(.all, 8)
            }
        }
        .frame(width: width, height: width * 1.55)
    }
}

struct SquarePortraitView: View {
    var fighter: Fighter?
    let outfitIndex: Int
    
    let isSelected: Bool
    let isInverted: Bool
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(fighter!.getElement().symbol) ?? 0xf128)
        return String(Character(UnicodeScalar(icon) ?? "\u{f128}"))
    }
    
    /// Returns the appropiate border color.
    /// - Returns: Returns the appropiate border color
    func getBorderColor() -> Color {
        if isInverted {
            return Color.white
        } else {
            return Color("Border")
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle().fill(isSelected ? Color("Positive") : Color.clear).frame(width: 70, height: 70)
                .overlay(Rectangle().strokeBorder(getBorderColor(), lineWidth: borderWidth))
            if fighter != nil {
                fighter!.getImage(index: outfitIndex, blinking: false, state: PlayerState.neutral).resizable().aspectRatio(contentMode: .fill).scaleEffect(2.3).offset(x: 6, y: 26).frame(width: 70 - borderWidth * 2, height: 70 - borderWidth * 2).clipped().padding(.all, borderWidth)
                Text(createSymbol()).font(.custom("Font Awesome 5 Pro", size: mediumFont)).foregroundColor(Color("Text")).padding(.all, 7)
            } else {
                Text("\u{f067}").font(.custom("Font Awesome 5 Pro", size: largeFont)).foregroundColor(getBorderColor()).frame(width: 70, height: 70)
            }
        }
    }
}

struct BaseFighterOverviewView: View {
    let modifiedBase: Base
    let base: Base
    
    /// Determine the color of the font depending on the stat value.
    /// - Parameters:
    ///   - index: Index of the stat
    ///   - value: Modified value of the stat
    /// - Returns: Color determined by the stat
    func getFontColor(index: Int, value: Int) -> Color {
        switch base.compareValues(index: index, value: value) {
        case 1:
            return Color("Positive") //value increased
        case -1:
            return Color("Negative") //value decreased
        default:
            return Color("Text")
        }
    }
    
    var body: some View {
        HStack(spacing: innerPadding/2) {
            ZStack {
                Rectangle().fill(Color("MainPanel")).overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                VStack(spacing: innerPadding/2) {
                    HStack {
                        CustomText(text: Localization.shared.getTranslation(key: "health").uppercased(), fontSize: mediumFont, isBold: true)
                        Spacer()
                        CustomText(text: "\(modifiedBase.health)".uppercased(), fontColor: getFontColor(index: 0, value: modifiedBase.health), fontSize: mediumFont)
                    }
                    HStack {
                        CustomText(text: Localization.shared.getTranslation(key: "attack").uppercased(), fontSize: mediumFont, isBold: true)
                        Spacer()
                        CustomText(text: "\(modifiedBase.attack)".uppercased(), fontColor: getFontColor(index: 1, value: modifiedBase.attack), fontSize: mediumFont)
                    }
                    HStack {
                        CustomText(text: Localization.shared.getTranslation(key: "defense").uppercased(), fontSize: mediumFont, isBold: true)
                        Spacer()
                        CustomText(text: "\(modifiedBase.defense)".uppercased(), fontColor: getFontColor(index: 2, value: modifiedBase.defense), fontSize: mediumFont)
                    }
                }
                .padding(.all, innerPadding)
            }
            ZStack {
                Rectangle().fill(Color("MainPanel")).overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                VStack(spacing: innerPadding/2) {
                    HStack {
                        CustomText(text: Localization.shared.getTranslation(key: "agility").uppercased(), fontSize: mediumFont, isBold: true)
                        Spacer()
                        CustomText(text: "\(modifiedBase.agility)".uppercased(), fontColor: getFontColor(index: 3, value: modifiedBase.agility), fontSize: mediumFont)
                    }
                    HStack {
                        CustomText(text: Localization.shared.getTranslation(key: "precision").uppercased(), fontSize: mediumFont, isBold: true)
                        Spacer()
                        CustomText(text: "\(modifiedBase.precision)".uppercased(), fontColor: getFontColor(index: 4, value: modifiedBase.precision), fontSize: mediumFont)
                    }
                    HStack {
                        CustomText(text: Localization.shared.getTranslation(key: "resistance").uppercased(), fontSize: mediumFont, isBold: true)
                        Spacer()
                        CustomText(text: "\(modifiedBase.resistance)".uppercased(), fontColor: getFontColor(index: 5, value: modifiedBase.resistance), fontSize: mediumFont)
                    }
                }
                .padding(.all, innerPadding)
            }
        }
    }
}

struct SpellView: View {
    let spell: Spell
    let desccription: String
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(spell.element.symbol) ?? 0xf128)
        return String(Character(UnicodeScalar(icon) ?? "\u{f128}"))
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Rectangle().fill(Color("MainPanel")).frame(height: 60).overlay(Rectangle().strokeBorder(Color(hex: spell.element.color), lineWidth: borderWidth))
            HStack(spacing: 0) {
                VStack {
                    CustomText(text: Localization.shared.getTranslation(key: spell.name).uppercased(), fontSize: mediumFont, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                    CustomText(text: desccription, fontSize: smallFont).frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, innerPadding)
                TitlePanel().fill(Color(hex: spell.element.color)).frame(width: 78, height: 60)
            }
            Text(createSymbol()).font(.custom("Font Awesome 5 Pro", size: largeFont)).foregroundColor(Color("Text")).frame(width: 60, height: 60)
        }
    }
}

struct ActionView: View {
    let titleKey: String
    let description: String
    
    let symbol: String
    let color: Color
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(symbol) ?? 0xf128)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Rectangle().fill(Color("MainPanel")).frame(height: 60).overlay(Rectangle().strokeBorder(color, lineWidth: borderWidth))
            HStack(spacing: 0) {
                VStack {
                    CustomText(text: Localization.shared.getTranslation(key: titleKey).uppercased(), fontSize: mediumFont, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                    CustomText(text: description, fontSize: smallFont).frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, innerPadding)
                TitlePanel().fill(color).frame(width: 78, height: 60)
            }
            Text(createSymbol()).font(.custom("Font Awesome 5 Pro", size: largeFont)).foregroundColor(Color.white).frame(width: 60, height: 60)
        }
    }
}

struct HexView: View {
    let hex: Hex
    var weather: Bool = false
    
    /// Returns the appropiate font color.
    /// - Returns: Returns the appropiate font color
    func getFontColor() -> Color {
        if weather {
            return Color.white
        } else if !hex.positive {
            return Color("Negative")
        } else {
            return Color("Positive")
        }
    }
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        return String(Character(UnicodeScalar(hex.symbol) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color("MainPanel"))
            if hex.symbol < 60000 { //temporary solution to missing symbols
                Text(self.createSymbol()).font(.custom("Font Awesome 5 Free", size: smallFont)).foregroundColor(getFontColor())
            } else {
                Text(self.createSymbol()).font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(getFontColor())
            }
        }
        .frame(width: 24, height: 24)
    }
}

struct FighterViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RectanglePortraitView(fighter: GlobalData.shared.fighters[0], isSelected: false, width: 97)
            SquarePortraitView(fighter: GlobalData.shared.fighters[0], outfitIndex: 0, isSelected: false, isInverted: false)
        }
    }
}
