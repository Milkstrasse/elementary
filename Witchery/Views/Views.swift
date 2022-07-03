//
//  Views.swift
//  Witchery
//
//  Created by Janice Hablützel on 05.01.22.
//

import SwiftUI

struct DetailedActionView: View {
    let title: String
    let description: String
    let symbol: String
    
    var width: CGFloat?
    var inverted: Bool = false
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 5).fill(inverted ? Color("health") : Color("button"))
            Rectangle().strokeBorder(inverted ? Color("highlight") : Color("healthbar"), lineWidth: 1.5).frame(width: 40).padding(.all, 10)
            Rectangle().strokeBorder(inverted ? Color("highlight") : Color("healthbar"), lineWidth: 1.5).frame(width: 42, height: 42).rotationEffect(.degrees(45)).padding(.trailing, 9)
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: -2) {
                    CustomText(key: title, fontSize: smallFontSize, isBold: true)
                    CustomText(key: description, fontSize: tinyFontSize)
                }
                .padding(.leading, 15)
                Spacer()
                Text(createSymbol()).frame(width: 60, height: 60).font(.custom("Font Awesome 5 Free", size: 13)).foregroundColor(Color("outline"))
            }
        }
        .frame(width: width, height: 60)
    }
}

struct RectangleWitchView: View {
    let witch: Witch
    var isSelected: Bool
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(witch.getElement().symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 5).fill(isSelected ? Color("healthbar") : Color("button")).frame(height: 125)
            Image(fileName: witch.name).resizable().scaleEffect(1.3).aspectRatio(contentMode: .fit).frame(height: 125).offset(y: 0)
            Text(createSymbol()).frame(width: 30, height: 30).font(.custom("Font Awesome 5 Free", size: 13)).foregroundColor(isSelected ? Color("button") : Color("outline"))
        }
        .clipShape(RoundedRectangle(cornerRadius: 5)).contentShape(Rectangle())
    }
}

struct BaseWitchesOverviewView: View {
    let base: Base
    
    var width: CGFloat?
    var bgColor: Color
    
    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 5).fill(bgColor).frame(height: 85)
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            CustomText(key: "health", fontSize: smallFontSize, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.health)", fontSize: smallFontSize)
                        }
                        HStack {
                            CustomText(key: "attack", fontSize: smallFontSize, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.attack)", fontSize: smallFontSize)
                        }
                        HStack {
                            CustomText(key: "defense", fontSize: smallFontSize, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.defense)", fontSize: smallFontSize)
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 5).fill(bgColor).frame(height: 85)
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            CustomText(key: "agility", fontSize: smallFontSize, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.agility)", fontSize: smallFontSize)
                        }
                        HStack {
                            CustomText(key: "precision", fontSize: smallFontSize, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.precision)", fontSize: smallFontSize)
                        }
                        HStack {
                            CustomText(key: "resistance", fontSize: smallFontSize, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.resistance)", fontSize: smallFontSize)
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .frame(width: width)
    }
}

struct SquareWitchView: View {
    var witch: Witch?
    var isSelected: Bool
    
    var inverted: Bool = false
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(witch!.getElement().symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    /// Returns the appropiate background color.
    /// - Returns: Returns the appropiate background color
    func getBackgroundColor() -> Color {
        if isSelected {
            if inverted {
                return Color("highlight")
            } else {
                return Color("healthbar")
            }
        } else {
            if inverted {
                return Color("health")
            } else {
                return Color("button")
            }
        }
    }
    
    /// Returns the appropiate font color.
    /// - Returns: Returns the appropiate font color
    func getFontColor() -> Color {
        if isSelected {
            if inverted {
                return Color("health")
            } else {
                return Color("button")
            }
        } else {
            return Color("outline")
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 5).fill(getBackgroundColor())
            if witch != nil {
                Text(createSymbol()).frame(width: 28, height: 28).font(.custom("Font Awesome 5 Free", size: 11)).foregroundColor(getFontColor())
                Image(fileName: witch!.name).resizable().scaleEffect(1.3).aspectRatio(contentMode: .fit).offset(x: 10, y: -10).clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                CustomText(text: "+", fontColor: isSelected ? Color("background") : Color("outline"), fontSize: 24).frame(width: 70, height: 70)
            }
        }
        .frame(width: 70, height: 70).contentShape(Rectangle())
    }
}

struct CustomText: View {
    var text: String
    var fontColor: Color
    var fontSize: CGFloat
    
    var lineLimit: Int?
    var isBold: Bool
    
    var textArray: [[String]]
    
    init(text: String, fontColor: Color = Color("outline"), fontSize: CGFloat, isBold: Bool = false) {
        self.text = text
        self.fontColor = fontColor
        self.fontSize = fontSize
        
        textArray = []
        let lines: [String] = text.components(separatedBy: "\n")
        for line in lines {
            textArray.append(line.components(separatedBy: "**"))
        }
        
        self.isBold = isBold
    }
    
    init(key: String, fontColor: Color = Color("outline"), fontSize: CGFloat, isBold: Bool = false) {
        self.text = Localization.shared.getTranslation(key: key)
        self.fontColor = fontColor
        self.fontSize = fontSize
        
        self.lineLimit = 1
        
        textArray = []
        let lines: [String] = text.components(separatedBy: "\n")
        for line in lines {
            textArray.append(line.components(separatedBy: "**"))
        }
        
        self.isBold = isBold
    }
    
    /// Returns wether the word should be bold or not.
    /// - Parameter index: The current index of the word in a line
    /// - Returns: Returns wether the word should be bold or not
    func isBold(index: Int) -> Bool {
        if isBold {
            return true
        }
        
        return index%2 != 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(textArray.indices, id: \.self) { line in
                HStack(spacing: 0) {
                    ForEach(textArray[line].indices, id: \.self) { index in
                        Text(textArray[line][index]).font(.custom(isBold(index: index) ? "KGMissKindyMarker" : "KGMissKindyChunky", size: fontSize)).fixedSize().foregroundColor(fontColor).lineLimit(lineLimit)
                    }
                }
            }
        }
    }
}

struct HexView: View {
    let hex: Hex
    var weather: Bool = false
    
    @State var opacity: Double = 1
    
    /// Returns the appropiate background color.
    /// - Returns: Returns the appropiate background color
    func getBackgroundColor() -> Color {
        if weather {
            return Color("healthbar")
        } else if !hex.positive {
            return Color("button")
        } else {
            return Color("health")
        }
    }
    
    /// Returns the appropiate font color.
    /// - Returns: Returns the appropiate font color
    func getFontColor() -> Color {
        if weather {
            return Color("button")
        } else {
            return Color("outline")
        }
    }
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol() -> String {
        return String(Character(UnicodeScalar(hex.symbol) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(getBackgroundColor()).frame(width: 24, height: 24)
            Text(self.createSymbol()).frame(width: 24, height: 24).font(.custom("Font Awesome 5 Free", size: 13)).foregroundColor(getFontColor())
        }
    }
}

struct Views_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DetailedActionView(title: "Title", description: "Description", symbol: "#")
            RectangleWitchView(witch: exampleWitch, isSelected: false).frame(width: 100)
            SquareWitchView(witch: exampleWitch, isSelected: false)
            BaseWitchesOverviewView(base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100), bgColor: Color("button"))
            HexView(hex: Hex(name: "sample", symbol: 0xf6de, duration: 3, positive: true))
        }
    }
}
