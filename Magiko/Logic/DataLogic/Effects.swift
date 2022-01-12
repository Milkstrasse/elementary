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
    var duration: Int
    
    let positive: Bool
    let damageAmount: Int
    
    init(name: String, symbol: String, duration: Int, positive: Bool, damageAmount: Int = 0) {
        self.name = name
        self.symbol = symbol
        self.duration = duration
        
        self.positive = positive
        
        self.damageAmount = damageAmount
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
    case bomb
    case blessing
    case block
    case chain
    case invigorated
    case exhausted
    
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
                return Effect(name: self.rawValue, symbol: "9", duration: 3, positive: false, damageAmount: 50)
            case .healing:
                return Effect(name: self.rawValue, symbol: "10", duration: 3, positive: true, damageAmount: -10)
            case .curse:
                return Effect(name: self.rawValue, symbol: "11", duration: 3, positive: false)
            case .bomb:
                return Effect(name: self.rawValue, symbol: "12", duration: 3, positive: false, damageAmount: 100)
            case .blessing:
                return Effect(name: self.rawValue, symbol: "13", duration: 3, positive: true)
            case .block:
                return Effect(name: self.rawValue, symbol: "14", duration: 3, positive: false)
            case .chain:
                return Effect(name: self.rawValue, symbol: "15", duration: 3, positive: false)
            case .invigorated:
                return Effect(name: self.rawValue, symbol: "16", duration: 3, positive: true)
            case .exhausted:
                return Effect(name: self.rawValue, symbol: "17", duration: 3, positive: false)
        }
    }
}
