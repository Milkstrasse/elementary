//
//  Shapes.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()

        return path
    }
}

struct SmallTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()

        return path
    }
}

struct ZigZag: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX/10, y: rect.minY + 65))
        path.addLine(to: CGPoint(x: 2 * rect.maxX/10, y: rect.minY))
        path.addLine(to: CGPoint(x: 3 * rect.maxX/10, y: rect.minY + 65))
        path.addLine(to: CGPoint(x: 4 * rect.maxX/10, y: rect.minY))
        path.addLine(to: CGPoint(x: 5 * rect.maxX/10, y: rect.minY + 65))
        path.addLine(to: CGPoint(x: 6 * rect.maxX/10, y: rect.minY))
        path.addLine(to: CGPoint(x: 7 * rect.maxX/10, y: rect.minY + 65))
        path.addLine(to: CGPoint(x: 8 * rect.maxX/10, y: rect.minY))
        path.addLine(to: CGPoint(x: 9 * rect.maxX/10, y: rect.minY + 65))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()

        return path
    }
}
