//
//  FighterViews.swift
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
        let icon: UInt16 = UInt16(Float64(fighter.getElement().symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle().fill(Color("Panel")).overlay(Rectangle().strokeBorder(isSelected ? Color(hex: fighter.getElement().color) : Color("Border2"), lineWidth: borderWidth))
            Image(fileName: fighter.name).resizable().aspectRatio(contentMode: .fill).scaleEffect(1.2).offset(x: width/4, y: -width/7).frame(width: width - borderWidth * 2, height: width * 1.48 - borderWidth * 2).clipped().padding(.all, borderWidth)
            ZStack {
                VStack(spacing: 0) {
                    TriangleB().fill(isSelected ? Color(hex: fighter.getElement().color) : Color("Border2")).frame(width: width, height: 20)
                    Rectangle().fill(isSelected ? Color(hex: fighter.getElement().color) : Color("Border2")).frame(width: width, height: 25)
                }
                HStack {
                    Spacer()
                    Text(createSymbol()).font(.custom("Font Awesome 5 Pro", size: 14)).foregroundColor(Color.white)
                }
                .padding([.trailing, .top], 8)
            }
        }
        .frame(width: width, height: width * 1.48)
    }
}

struct SquarePortraitView: View {
    let fighter: Fighter?
    
    let isSelected: Bool
    let isInverted: Bool
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(fighter!.getElement().symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    /// Returns the appropiate border color.
    /// - Returns: Returns the appropiate border color
    func getBorderColor() -> Color {
        if isSelected {
            if isInverted {
                return Color("Background2")
            } else if fighter != nil {
                return Color(hex: fighter!.getElement().color)
            } else {
                return Color("Border1")
            }
        } else {
            if isInverted {
                return Color.white
            } else {
                return Color("Border2")
            }
        }
    }
    
    /// Returns the appropiate text color.
    /// - Returns: Returns the appropiate text color
    func getTextColor() -> Color {
        if isSelected {
            return Color.white
        } else {
            if isInverted {
                return Color("Panel")
            } else {
                return Color.white
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(isInverted ? Color("Background1") : Color("Panel")).frame(width: 70, height: 70)
                .overlay(Rectangle().strokeBorder(getBorderColor(), lineWidth: borderWidth))
            if fighter != nil {
                Image(fileName: fighter!.name).resizable().aspectRatio(contentMode: .fill).scaleEffect(2.4).offset(x: 26, y: 3).frame(width: 70 - borderWidth * 2, height: 70 - borderWidth * 2).clipped().padding(.all, borderWidth)
                TriangleA().fill(getBorderColor()).frame(width: 70, height: 30).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                Text(createSymbol()).font(.custom("Font Awesome 5 Pro", size: 10)).foregroundColor(getTextColor()).padding(.all, 6)
            } else {
                Text("\u{f067}").font(.custom("Font Awesome 5 Pro", size: 20)).foregroundColor(getBorderColor()).frame(width: 70, height: 70)
            }
        }
    }
}

struct BaseFighterOverviewView: View {
    let base: Base
    
    var body: some View {
        HStack(spacing: innerPadding/2) {
            ZStack {
                Rectangle().fill(Color("Panel")).frame(height: 85).overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            CustomText(text: Localization.shared.getTranslation(key: "health").uppercased(), fontSize: 16, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.health)".uppercased(), fontSize: 16)
                        }
                        HStack {
                            CustomText(text: Localization.shared.getTranslation(key: "attack").uppercased(), fontSize: 16, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.attack)".uppercased(), fontSize: 16)
                        }
                        HStack {
                            CustomText(text: Localization.shared.getTranslation(key: "defense").uppercased(), fontSize: 16, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.defense)".uppercased(), fontSize: 16)
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
            ZStack {
                Rectangle().fill(Color("Panel")).frame(height: 85).overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            CustomText(text: Localization.shared.getTranslation(key: "agility").uppercased(), fontSize: 16, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.agility)".uppercased(), fontSize: 16)
                        }
                        HStack {
                            CustomText(text: Localization.shared.getTranslation(key: "precision").uppercased(), fontSize: 16, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.precision)".uppercased(), fontSize: 16)
                        }
                        HStack {
                            CustomText(text: Localization.shared.getTranslation(key: "resistance").uppercased(), fontSize: 16, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.resistance)".uppercased(), fontSize: 16)
                        }
                    }
                }
                .padding(.horizontal, 15)
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
        let icon: UInt16 = UInt16(Float64(spell.element.symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Rectangle().fill(Color("Panel")).frame(height: 60).overlay(Rectangle().strokeBorder(Color(hex: spell.element.color), lineWidth: borderWidth))
            HStack(spacing: 0) {
                VStack {
                    CustomText(text: Localization.shared.getTranslation(key: spell.name).uppercased(), fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                    CustomText(text: desccription, fontSize: 14).frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, innerPadding)
                TitlePanel().fill(Color(hex: spell.element.color)).frame(width: 78, height: 60)
            }
            Text(createSymbol()).font(.custom("Font Awesome 5 Pro", size: 20)).foregroundColor(Color.white).frame(width: 60, height: 60)
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
        let icon: UInt16 = UInt16(Float64(symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Rectangle().fill(Color("Panel")).frame(height: 60).overlay(Rectangle().strokeBorder(color, lineWidth: borderWidth))
            HStack(spacing: 0) {
                VStack {
                    CustomText(text: Localization.shared.getTranslation(key: titleKey).uppercased(), fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                    CustomText(text: description, fontSize: 14).frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, innerPadding)
                TitlePanel().fill(color).frame(width: 78, height: 60)
            }
            Text(createSymbol()).font(.custom("Font Awesome 5 Pro", size: 20)).foregroundColor(Color.white).frame(width: 60, height: 60)
        }
    }
}

struct HexView: View {
    let hex: Hex
    var weather: Bool = false
    
    @State var opacity: Double = 1
    
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
            Rectangle().fill(Color("Panel"))
            Text(self.createSymbol()).font(.custom("Font Awesome 5 Free", size: 14)).foregroundColor(getFontColor())
        }
        .frame(width: 24, height: 24)
    }
}

struct FighterViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RectanglePortraitView(fighter: exampleFighter, isSelected: false, width: 97)
            SquarePortraitView(fighter: exampleFighter, isSelected: false, isInverted: false)
        }
    }
}
