//
//  Effects.swift
//  Elementary
//
//  Created by Janice Hablützel on 04.01.23.
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func modifier(amount: CGFloat) -> CGFloat {
        return 10 * sin(amount * .pi * 2)
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX: (10 + modifier(amount: animatableData)) * animatableData, y: 0))
    }
}
