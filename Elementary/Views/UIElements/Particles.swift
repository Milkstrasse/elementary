//
//  Particles.swift
//  Elementary
//
//  Created by Janice Hablützel on 22.12.22.
//

import SwiftUI

struct FireworkParticlesGeometryEffect : GeometryEffect {
    var time : Double
    var speed = Double.random(in: 50 ... 150)
    var direction = Double.random(in: -Double.pi ...  Double.pi)
    
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(direction) * time
        let yTranslation = speed * sin(direction) * time
        let affineTranslation =  CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}

struct ParticlesModifier: ViewModifier {
    @State var time = 0.0
    let duration = 1.5
    
    func body(content: Content) -> some View {
        ZStack {
            ForEach(0..<40, id: \.self) { index in
                content
                    .modifier(FireworkParticlesGeometryEffect(time: time))
                    .opacity(max(duration - time * time, 0))
            }
        }
        .onAppear {
            withAnimation (.easeOut(duration: duration)) {
                self.time = duration
            }
        }
    }
}
