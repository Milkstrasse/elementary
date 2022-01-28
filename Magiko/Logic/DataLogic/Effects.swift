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
    let symbol: UInt16
    var duration: Int
    
    let positive: Bool
    let damageAmount: Int
    
    let opposite: Effects?
    
    init(name: String, symbol: UInt16, duration: Int, positive: Bool, damageAmount: Int = 0, opposite: Effects? = nil) {
        self.name = name
        self.symbol = symbol
        self.duration = duration
        
        self.positive = positive
        
        self.damageAmount = damageAmount
        
        self.opposite = opposite
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Effect, rhs: Effect) -> Bool {
        return lhs.id == rhs.id
    }
}

enum Effects: String, CaseIterable {
    case attackBoost
    case attackDrop
    case defenseBoost
    case defenseDrop
    case agilityBoost
    case agilityDrop
    case precisionBoost
    case precisionDrop
    case poisoned
    case healed
    case confused
    case bombed
    case blessed
    case blocked
    case chained
    case invigorated
    case exhausted
    case locked
    case enlightened
    
    func getEffect() -> Effect {
        switch self {
            case .attackBoost:
                return Effect(name: self.rawValue, symbol: 0xf6de, duration: 3, positive: true, opposite: .attackDrop)
            case .attackDrop:
                return Effect(name: self.rawValue, symbol: 0xf6de, duration: 3, positive: false, opposite: .attackBoost)
            case .defenseBoost:
                return Effect(name: self.rawValue, symbol: 0xf132, duration: 3, positive: true, opposite: .defenseDrop)
            case .defenseDrop:
                return Effect(name: self.rawValue, symbol: 0xf132, duration: 3, positive: false, opposite: .defenseBoost)
            case .agilityBoost:
                return Effect(name: self.rawValue, symbol: 0xf72e, duration: 3, positive: true, opposite: .agilityDrop)
            case .agilityDrop:
                return Effect(name: self.rawValue, symbol: 0xf72e, duration: 3, positive: false, opposite: .agilityBoost)
            case .precisionBoost:
                return Effect(name: self.rawValue, symbol: 0xf05b, duration: 3, positive: true, opposite: .precisionDrop)
            case .precisionDrop:
                return Effect(name: self.rawValue, symbol: 0xf05b, duration: 3, positive: false, opposite: .precisionBoost)
            case .poisoned:
                return Effect(name: self.rawValue, symbol: 0xf54c, duration: 3, positive: false, damageAmount: 10)
            case .healed:
                return Effect(name: self.rawValue, symbol: 0xe05c, duration: 3, positive: true, damageAmount: -10)
            case .confused:
                return Effect(name: self.rawValue, symbol: 0xf074, duration: 3, positive: false)
            case .bombed:
                return Effect(name: self.rawValue, symbol: 0xf1e2, duration: 3, positive: false, damageAmount: 25)
            case .blessed:
                return Effect(name: self.rawValue, symbol: 0xf4c2, duration: 3, positive: true)
            case .blocked:
                return Effect(name: self.rawValue, symbol: 0xf05e, duration: 3, positive: false)
            case .chained:
                return Effect(name: self.rawValue, symbol: 0xf0c1, duration: 3, positive: false)
            case .invigorated:
                return Effect(name: self.rawValue, symbol: 0xf102, duration: 3, positive: true)
            case .exhausted:
                return Effect(name: self.rawValue, symbol: 0xf103, duration: 3, positive: false)
            case .locked:
                return Effect(name: self.rawValue, symbol: 0xf023, duration: 3, positive: false)
            case .enlightened:
                return Effect(name: self.rawValue, symbol: 0xf5bb, duration: 3, positive: true)
        }
    }
    
    static func getNegativeEffect() -> Effect {
        var effect: Effect = Effects.allCases[0].getEffect()
        while effect.positive {
            effect = Effects.allCases[Int.random(in: 0 ..< Effects.allCases.count)].getEffect()
        }
        
        return effect
    }
}

enum WeatherEffects: String {
    case sandstorm
    case thunderstorm
    case sunnyDay
    case smog
    case mysticWeather
    case lightRain
    case drought
    
    func getEffect(duration: Int) -> Effect {
        switch self {
            case .sandstorm:
                return Effect(name: self.rawValue, symbol: 0xf6c4, duration: duration, positive: true)
            case .thunderstorm:
                return Effect(name: self.rawValue, symbol: 0xf740, duration: duration, positive: true)
            case .sunnyDay:
                return Effect(name: self.rawValue, symbol: 0xf185, duration: duration, positive: true)
            case .smog:
                return Effect(name: self.rawValue, symbol: 0xf75f, duration: duration, positive: true)
            case .mysticWeather:
                return Effect(name: self.rawValue, symbol: 0xf75b, duration: duration, positive: true)
            case .lightRain:
                return Effect(name: self.rawValue, symbol: 0xf73d, duration: duration, positive: true)
            case .drought:
                return Effect(name: self.rawValue, symbol: 0xf5c7, duration: duration, positive: true)
        }
    }
}
