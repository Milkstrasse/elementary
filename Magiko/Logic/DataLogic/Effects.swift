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
    
    init(name: String, symbol: String, duration: UInt, positive: Bool) {
        self.name = name
        self.symbol = symbol
        self.duration = duration
        
        self.positive = positive
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
        }
    }
}
