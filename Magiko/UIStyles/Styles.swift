//
//  Styles.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct GrowingButton: ButtonStyle {
    var width: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: width, height: 40, alignment: .leading)
            .offset(x: 15)
            .background(content: {
                RoundedRectangle(cornerRadius: 5).fill(Color.blue)
            })
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
