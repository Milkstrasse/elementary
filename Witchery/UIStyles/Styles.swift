//
//  Styles.swift
//  Witchery
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

let tinyFontSize: CGFloat = 13
let smallFontSize: CGFloat = 14
let mediumFontSize: CGFloat = 16
let largeFontSize: CGFloat = 18

struct BasicButton: ButtonStyle {
    var width: CGFloat
    var height: CGFloat = 45
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width, height: height, alignment: width == height ? .center : .leading)
            .offset(x: width == height ? 0 : 15)
            .background(content: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color(red: 0.24, green: 0.22, blue: 0.35))
                }
            })
            .foregroundColor(Color.white)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ClearBasicButton: ButtonStyle {
    var width: CGFloat
    var height: CGFloat = 45
    
    var fontColor: Color = Color("outline")
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width, height: height)
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
            .frame(width: width, height: height, alignment: .bottomTrailing)
            .font(.custom("KGMissKindyChunky", size: smallFontSize))
            .foregroundColor(Color("outline"))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}
