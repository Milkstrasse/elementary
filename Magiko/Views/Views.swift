//
//  Views.swift
//  Magiko
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
                    CustomText(key: title, bold: true)
                    CustomText(key: description)
                }
                .padding(.leading, 10)
                Spacer()
                Text(createSymbol()).frame(width: 60, height: 60).font(.custom("Font Awesome 5 Free", size: 13)).foregroundColor(Color("highlight"))
            }
        }
        .frame(width: width, height: 60)
    }
}

struct RectangleFighterView: View {
    let fighter: Fighter
    var isSelected: Bool
    
    func createSymbol() -> String {
        let icon: UInt16 = UInt16(Float64(fighter.element.symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 5).fill(isSelected ? Color("outline") : Color("button")).frame(height: 125)
            Image(fighter.name).resizable().scaleEffect(1.3).aspectRatio(contentMode: .fit).frame(height: 125).offset(y: 0)
            Text(createSymbol()).frame(width: 30, height: 30).font(.custom("Font Awesome 5 Free", size: 13)).foregroundColor(isSelected ? Color("background") : Color("outline"))
            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(height: 125)
        }
        .clipShape(RoundedRectangle(cornerRadius: 5)).contentShape(Rectangle())
    }
}

struct BaseOverviewView: View {
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
                            CustomText(key: "health", bold: true)
                            Spacer()
                            CustomText(text: "\(base.health)")
                        }
                        HStack {
                            CustomText(key: "attack", bold: true)
                            Spacer()
                            CustomText(text: "\(base.attack)")
                        }
                        HStack {
                            CustomText(key: "defense", bold: true)
                            Spacer()
                            CustomText(text: "\(base.defense)")
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
                            CustomText(key: "agility", bold: true)
                            Spacer()
                            CustomText(text: "\(base.agility)")
                        }
                        HStack {
                            CustomText(key: "precision", bold: true)
                            Spacer()
                            CustomText(text: "\(base.precision)")
                        }
                        HStack {
                            CustomText(key: "stamina", bold: true)
                            Spacer()
                            CustomText(text: "\(base.stamina)")
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .frame(width: width)
    }
}

struct SquareFighterView: View {
    var fighter: Fighter?
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(isSelected ? Color("outline") : Color("button"))
            if fighter != nil {
                Image(fighter!.name).resizable().scaleEffect(1.4).aspectRatio(contentMode: .fit).offset(y: 0).clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                CustomText(text: "+")
            }
            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
        }
        .frame(width: 70, height: 70).contentShape(Rectangle())
    }
}

struct CustomText: View {
    var text: String
    var lineLimit: Int?
    var bold: Bool
    
    var textArray: [[String]]
    
    init(text: String, bold: Bool = false) {
        self.text = text
        
        textArray = []
        let lines: [String] = text.components(separatedBy: "\n")
        for line in lines {
            textArray.append(line.components(separatedBy: "**"))
        }
        
        self.bold = bold
    }
    
    init(key: String, bold: Bool = false) {
        self.text = Localization.shared.getTranslation(key: key)
        self.lineLimit = 1
        
        textArray = []
        let lines: [String] = text.components(separatedBy: "\n")
        for line in lines {
            textArray.append(line.components(separatedBy: "**"))
        }
        
        self.bold = bold
    }
    
    func isBold(index: Int) -> Bool {
        if bold {
            return true
        }
        
        if textArray.count > 1 {
            return index%2 != 0
        }
        
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(textArray.indices, id: \.self) { line in
                HStack(spacing: 0) {
                    ForEach(textArray[line].indices, id: \.self) { index in
                        Text(textArray[line][index]).font(.custom(isBold(index: index) ? "Recoleta-Bold" : "Recoleta-Regular", size: 13)).fixedSize().foregroundColor(Color("outline")).lineLimit(lineLimit)
                    }
                }
            }
        }
    }
}

struct EffectView: View {
    let effect: Effect
    let battling: Bool
    var weather: Bool = false
    
    @State var opacity: Double = 1
    
    func getBackgroundColor() -> Color {
        if !effect.positive || weather {
            return Color("button")
        } else {
            return Color("outline")
        }
    }
    
    func getFontColor() -> Color {
        if weather {
            return Color("highlight")
        }
        
        if effect.positive {
            return Color("background")
        } else {
            return Color("outline")
        }
    }
    
    func createSymbol() -> String {
        return String(Character(UnicodeScalar(effect.symbol) ?? "\u{2718}"))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(Color("background")).frame(width: 24, height: 24)
            Group {
                RoundedRectangle(cornerRadius: 5).fill(getBackgroundColor()).frame(width: 24, height: 24)
                Text(self.createSymbol()).frame(width: 24, height: 24).font(.custom("Font Awesome 5 Free", size: 13)).foregroundColor(getFontColor())
            }
            .opacity(opacity).animation(.linear(duration: 0.5).repeatForever(autoreverses: true), value: opacity)
        }
        .onChange(of: battling) { _ in
            if effect.duration == 1 {
                opacity = 0
            }
        }
    }
}

struct Views_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DetailedActionView(title: "Title", description: "Description", symbol: "#")
            RectangleFighterView(fighter: exampleFighter, isSelected: false).frame(width: 100)
            SquareFighterView(fighter: exampleFighter, isSelected: false)
            BaseOverviewView(base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, stamina: 100))
            EffectView(effect: Effect(name: "sample", symbol: 0xf6de, duration: 3, positive: true), battling: false)
        }
    }
}
