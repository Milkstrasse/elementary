//
//  ZigZag.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.08.22.
//

import SwiftUI

struct ZigZag: Shape {
    func path(in rect: CGRect) -> Path {
        let points: CGFloat = 8
        let height: CGFloat = 50
        
        var path = Path()

        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        for index in (1 ..< Int(points)) {
            if index%2 == 0 {
                path.addLine(to: CGPoint(x: CGFloat(index) * rect.maxX/points, y: rect.minY))
            } else {
                path.addLine(to: CGPoint(x: CGFloat(index) * rect.maxX/points, y: rect.minY + height))
            }
        }
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()

        return path
    }
}
