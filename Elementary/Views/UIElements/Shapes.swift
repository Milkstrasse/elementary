//
//  Shapes.swift
//  Elementary
//
//  Created by Janice Hablützel on 14.11.22.
//

import SwiftUI

struct TitlePanel: Shape {
    func path(in rect: CGRect) -> Path {
        var path: Path = Path()

        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.maxY/3.35, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()

        return path
    }
}

struct TriangleA: Shape {
    func path(in rect: CGRect) -> Path {
        var path: Path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxY * 1.65, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

struct TriangleB: Shape {
    func path(in rect: CGRect) -> Path {
        var path: Path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - rect.maxX/3.3))
        path.closeSubpath()

        return path
    }
}

struct ZigZag: Shape {
    func path(in rect: CGRect) -> Path {
        let points: CGFloat = 8
        let height: CGFloat = 50
        
        var path: Path = Path()

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
