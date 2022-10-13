//
//  ElementalChartView.swift
//  Elementary
//
//  Created by Janice Hablützel on 20.08.22.
//

import SwiftUI

struct ElementalChartView: View {
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol(symbol: String) -> String {
        let icon: UInt16 = UInt16(Float64(symbol) ?? 0xf52d)
        return String(Character(UnicodeScalar(icon) ?? "\u{2718}"))
    }
    
    var body: some View {
        VStack(spacing: innerPadding/2) {
            ForEach(GlobalData.shared.elementArray, id: \.self.name) { element in
                HStack(spacing: innerPadding/2) {
                    ForEach(element.weaknesses.indices, id: \.self) { index in
                        if let temp = GlobalData.shared.elements[element.weaknesses[index]] {
                            ZStack {
                                Rectangle().fill(Color(hex: temp.color))
                                Text(createSymbol(symbol: temp.symbol)).font(.custom("Font Awesome 5 Pro", size: 14)).foregroundColor(Color.white)
                            }
                        }
                    }
                    Text(createSymbol(symbol:"0xf061")).frame(maxWidth: .infinity).font(.custom("Font Awesome 5 Pro", size: 14)).foregroundColor(Color.white)
                    ZStack {
                        Rectangle().fill(Color(hex: element.color))
                        Text(createSymbol(symbol: element.symbol)).font(.custom("Font Awesome 5 Pro", size: 14)).foregroundColor(Color.white)
                    }
                    Text(createSymbol(symbol:"0xf061")).frame(maxWidth: .infinity).font(.custom("Font Awesome 5 Pro", size: 14)).foregroundColor(Color.white)
                    ForEach(element.strengths.indices, id: \.self) { index in
                        if let temp = GlobalData.shared.elements[element.strengths[index]] {
                            ZStack {
                                Rectangle().fill(Color(hex: temp.color))
                                Text(createSymbol(symbol: temp.symbol)).font(.custom("Font Awesome 5 Pro", size: 14)).foregroundColor(Color.white)
                            }
                        }
                    }
                }
                .frame(height: 30)
            }
        }
    }
}

struct ElementalChartView_Previews: PreviewProvider {
    static var previews: some View {
        ElementalChartView()
    }
}
