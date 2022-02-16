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
    
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 5).fill(Color("button"))
            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
            Rectangle().strokeBorder(Color("outline"), lineWidth: 1).frame(width: 40).padding(.all, 10)
            Rectangle().strokeBorder(Color("outline"), lineWidth: 1).frame(width: 42, height: 42).rotationEffect(.degrees(45)).padding(.trailing, 9)
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    CustomText(key: title, fontSize: 16, isBold: true)
                    CustomText(key: description, fontSize: 13)
                }
                .padding(.leading, 15)
                Spacer()
                Text(createSymbol()).frame(width: 60, height: 60).font(.custom("Font Awesome 5 Free", size: 13)).foregroundColor(Color("highlight"))
            }
        }
        .frame(width: width, height: 60)
    }
}

struct RectangleWitchView: View {
    let witch: Witch
    var isSelected: Bool
    
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(witch.getElement().symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 5).fill(isSelected ? Color("outline") : Color("button")).frame(height: 125)
            Image(witch.name).resizable().scaleEffect(1.3).aspectRatio(contentMode: .fit).frame(height: 125).offset(y: 0)
            Text(createSymbol()).frame(width: 30, height: 30).font(.custom("Font Awesome 5 Free", size: 13)).foregroundColor(isSelected ? Color("background") : Color("outline"))
            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(height: 125)
        }
        .clipShape(RoundedRectangle(cornerRadius: 5)).contentShape(Rectangle())
    }
}

struct BaseWitchesOverviewView: View {
    let base: Base
    
    var width: CGFloat?
    
    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 75)
                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(height: 75)
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            CustomText(key: "health", fontSize: 14, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.health)", fontSize: 14)
                        }
                        HStack {
                            CustomText(key: "attack", fontSize: 14, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.attack)", fontSize: 14)
                        }
                        HStack {
                            CustomText(key: "defense", fontSize: 14, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.defense)", fontSize: 14)
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(height: 75)
                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(height: 75)
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            CustomText(key: "agility", fontSize: 14, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.agility)", fontSize: 14)
                        }
                        HStack {
                            CustomText(key: "precision", fontSize: 14, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.precision)", fontSize: 14)
                        }
                        HStack {
                            CustomText(key: "resistance", fontSize: 14, isBold: true)
                            Spacer()
                            CustomText(text: "\(base.resistance)", fontSize: 14)
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
    
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(witch!.getElement(ignoreOverride: true).symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 5).fill(isSelected ? Color("outline") : Color("button"))
            if witch != nil {
                Text(createSymbol()).frame(width: 28, height: 28).font(.custom("Font Awesome 5 Free", size: 11)).foregroundColor(isSelected ? Color("background") : Color("outline"))
                Image(witch!.name).resizable().scaleEffect(1.3).aspectRatio(contentMode: .fit).offset(x: 10, y: -10).clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                CustomText(text: "+", fontColor: isSelected ? Color("background") : Color("outline"), fontSize: 24).frame(width: 70, height: 70)
            }
            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
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
                        Text(textArray[line][index]).font(.custom(isBold(index: index) ? "Recoleta-Bold" : "Recoleta-Regular", size: fontSize)).fixedSize().foregroundColor(fontColor).lineLimit(lineLimit)
                    }
                }
            }
        }
    }
}

struct HexView: View {
    let hex: Hex
    let battling: Bool
    var weather: Bool = false
    
    @State var opacity: Double = 1
    
    func getBackgroundColor() -> Color {
        if !hex.positive || weather {
            return Color("button")
        } else {
            return Color("outline")
        }
    }
    
    func getOutlineColor() -> Color {
        if weather {
            return Color("highlight")
        } else {
            return Color("outline")
        }
    }
    
    func getFontColor() -> Color {
        if weather {
            return Color("highlight")
        }
        
        if hex.positive {
            return Color("background")
        } else {
            return Color("outline")
        }
    }
    
    func createSymbol() -> String {
        return String(Character(UnicodeScalar(hex.symbol) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(Color("background")).frame(width: 24, height: 24)
            Group {
                RoundedRectangle(cornerRadius: 5).fill(getBackgroundColor()).frame(width: 24, height: 24)
                RoundedRectangle(cornerRadius: 5).strokeBorder(getOutlineColor(), lineWidth: 1).frame(width: 24, height: 24)
                Text(self.createSymbol()).frame(width: 24, height: 24).font(.custom("Font Awesome 5 Free", size: 13)).foregroundColor(getFontColor())
            }
            .opacity(opacity).animation(.linear(duration: 0.5).repeatForever(autoreverses: true), value: opacity)
        }
        .onChange(of: battling) { _ in
            if hex.duration == 1 {
                opacity = 0
            }
        }
    }
}

struct Views_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DetailedActionView(title: "Title", description: "Description", symbol: "#")
            RectangleWitchView(witch: exampleWitch, isSelected: false).frame(width: 100)
            SquareWitchView(witch: exampleWitch, isSelected: false)
            BaseWitchesOverviewView(base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100))
            HexView(hex: Hex(name: "sample", symbol: 0xf6de, duration: 3, positive: true), battling: false)
        }
    }
}
