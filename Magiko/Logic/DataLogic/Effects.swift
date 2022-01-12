//
//  Effects.swift
//  Magiko
//
//  Created by Janice Hablützel on 11.01.22.
//

import SwiftUI

class Effect: Hashable {
    let id = UUID()
    let name: String
    let symbol: String
    var duration: UInt
    
    let positive: Bool
    let damageDivisor: Int
    
    init(name: String, symbol: String, duration: UInt, positive: Bool, damageDivisor: Int = 0) {
        self.name = name
        self.symbol = symbol
        self.duration = duration
        
        self.positive = positive
        
        self.damageDivisor = damageDivisor
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Effect, rhs: Effect) -> Bool {
        return lhs.id == rhs.id
    }
}

enum Effects: String {
    case attackBoost
    case attackDrop
    case defenseBoost
    case defenseDrop
    case agilityBoost
    case agilityDrop
    case precisionBoost
    case precisionDrop
    case poison
    case healing
    case curse
    
    func getEffect() -> Effect {
        switch self {
            case .attackBoost:
            return Effect(name: self.rawValue, symbol: "1", duration: 3, positive: true)
            case .attackDrop:
                return Effect(name: self.rawValue, symbol: "2", duration: 3, positive: false)
            case .defenseBoost:
                return Effect(name: self.rawValue, symbol: "3", duration: 3, positive: true)
            case .defenseDrop:
                return Effect(name: self.rawValue, symbol: "4", duration: 3, positive: false)
            case .agilityBoost:
                return Effect(name: self.rawValue, symbol: "5", duration: 3, positive: true)
            case .agilityDrop:
                return Effect(name: self.rawValue, symbol: "6", duration: 3, positive: false)
            case .precisionBoost:
                return Effect(name: self.rawValue, symbol: "7", duration: 3, positive: true)
            case .precisionDrop:
                return Effect(name: self.rawValue, symbol: "8", duration: 3, positive: false)
            case .poison:
                return Effect(name: self.rawValue, symbol: "9", duration: 3, positive: false, damageDivisor: 2)
            case .healing:
                return Effect(name: self.rawValue, symbol: "10", duration: 3, positive: false, damageDivisor: -10)
            case .curse:
                return Effect(name: self.rawValue, symbol: "11", duration: 3, positive: false)
        }
    }
}
