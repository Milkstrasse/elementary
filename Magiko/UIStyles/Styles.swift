//
//  Styles.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct GrowingButton: ButtonStyle {
    var width: CGFloat
    var height: CGFloat = 40
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width, height: height, alignment: width == height ? .center : .leading)
            .offset(x: width == height ? 0 : 15)
            .background(content: {
                RoundedRectangle(cornerRadius: 5).fill(Color.blue)
            })
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ClearGrowingButton: ButtonStyle {
    var width: CGFloat
    var height: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width, height: height)
            .foregroundColor(.white)
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
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}
