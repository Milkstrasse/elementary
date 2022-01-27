//
//  Styles.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct BasicButton: ButtonStyle {
    var width: CGFloat
    var height: CGFloat = 40
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width, height: height, alignment: width == height ? .center : .leading)
            .offset(x: width == height ? 0 : 15)
            .background(content: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                    RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1)
                }
            })
            .font(.custom("Recoleta-Regular", size: 14))
            .foregroundColor(Color("outline"))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ClearBasicButton: ButtonStyle {
    var width: CGFloat
    var height: CGFloat
    
    var fontColor: Color = Color("outline")
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width, height: height)
            .font(.custom("Recoleta-Regular", size: 14))
            .foregroundColor(fontColor)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}

struct ClearButton: ButtonStyle {
    var width: CGFloat
    var height: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width, height: height, alignment: .bottomLeading)
            .font(.custom("Recoleta-Regular", size: 14))
            .foregroundColor(Color("outline"))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}
