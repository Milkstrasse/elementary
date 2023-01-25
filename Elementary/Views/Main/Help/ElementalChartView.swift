//
//  ElementalChartView.swift
//  Elementary
//
//  Created by Janice Hablützel on 20.08.22.
//

import SwiftUI

struct ElementalChartView: View {
    var body: some View {
        VStack(spacing: General.innerPadding/2) {
            ForEach(GlobalData.shared.elementArray, id: \.self.name) { element in
                HStack(spacing: General.innerPadding/2) {
                    ForEach(element.weaknesses.indices, id: \.self) { index in
                        if let temp = GlobalData.shared.elements[element.weaknesses[index]] {
                            ZStack {
                                Rectangle().fill(Color(hex: temp.color))
                                Text(General.createSymbol(string: temp.symbol)).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color.white)
                            }
                        }
                    }
                    Text(General.createSymbol(string:"0xf061")).frame(maxWidth: .infinity).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color.white)
                    ZStack {
                        Rectangle().fill(Color(hex: element.color))
                        Text(General.createSymbol(string: element.symbol)).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color.white)
                    }
                    Text(General.createSymbol(string:"0xf061")).frame(maxWidth: .infinity).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color.white)
                    ForEach(element.strengths.indices, id: \.self) { index in
                        if let temp = GlobalData.shared.elements[element.strengths[index]] {
                            ZStack {
                                Rectangle().fill(Color(hex: temp.color))
                                Text(General.createSymbol(string: temp.symbol)).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color.white)
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
