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
    
    let opposite: Effects?
    
    init(name: String, symbol: String, duration: Int, positive: Bool, damageAmount: Int = 0, opposite: Effects? = nil) {
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
    case alerted
    
    func getEffect() -> Effect {
        switch self {
            case .attackBoost:
                return Effect(name: self.rawValue, symbol: "1", duration: 3, positive: true, opposite: .attackDrop)
            case .attackDrop:
                return Effect(name: self.rawValue, symbol: "2", duration: 3, positive: false, opposite: .attackBoost)
            case .defenseBoost:
                return Effect(name: self.rawValue, symbol: "3", duration: 3, positive: true, opposite: .defenseDrop)
            case .defenseDrop:
                return Effect(name: self.rawValue, symbol: "4", duration: 3, positive: false, opposite: .defenseBoost)
            case .agilityBoost:
                return Effect(name: self.rawValue, symbol: "5", duration: 3, positive: true, opposite: .agilityDrop)
            case .agilityDrop:
                return Effect(name: self.rawValue, symbol: "6", duration: 3, positive: false, opposite: .agilityBoost)
            case .precisionBoost:
                return Effect(name: self.rawValue, symbol: "7", duration: 3, positive: true, opposite: .precisionDrop)
            case .precisionDrop:
                return Effect(name: self.rawValue, symbol: "8", duration: 3, positive: false, opposite: .precisionBoost)
            case .poisoned:
                return Effect(name: self.rawValue, symbol: "9", duration: 3, positive: false, damageAmount: 50)
            case .healed:
                return Effect(name: self.rawValue, symbol: "10", duration: 3, positive: true, damageAmount: -10)
            case .confused:
                return Effect(name: self.rawValue, symbol: "11", duration: 3, positive: false)
            case .bombed:
                return Effect(name: self.rawValue, symbol: "12", duration: 3, positive: false, damageAmount: 100)
            case .blessed:
                return Effect(name: self.rawValue, symbol: "13", duration: 3, positive: true)
            case .blocked:
                return Effect(name: self.rawValue, symbol: "14", duration: 3, positive: false)
            case .chained:
                return Effect(name: self.rawValue, symbol: "15", duration: 3, positive: false)
            case .invigorated:
                return Effect(name: self.rawValue, symbol: "16", duration: 3, positive: true)
            case .exhausted:
                return Effect(name: self.rawValue, symbol: "17", duration: 3, positive: false)
            case .locked:
                return Effect(name: self.rawValue, symbol: "18", duration: 3, positive: false)
            case .enlightened:
                return Effect(name: self.rawValue, symbol: "19", duration: 3, positive: true)
            case .alerted:
                return Effect(name: self.rawValue, symbol: "20", duration: 3, positive: true)
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
                return Effect(name: self.rawValue, symbol: "A", duration: duration, positive: true)
            case .thunderstorm:
                return Effect(name: self.rawValue, symbol: "B", duration: duration, positive: true)
            case .sunnyDay:
                return Effect(name: self.rawValue, symbol: "C", duration: duration, positive: true)
            case .smog:
                return Effect(name: self.rawValue, symbol: "D", duration: duration, positive: true)
            case .mysticWeather:
                return Effect(name: self.rawValue, symbol: "E", duration: duration, positive: true)
            case .lightRain:
                return Effect(name: self.rawValue, symbol: "F", duration: duration, positive: true)
            case .drought:
                return Effect(name: self.rawValue, symbol: "G", duration: duration, positive: true)
        }
    }
}
