//
//  Hexes.swift
//  Witchery
//
//  Created by Janice Hablützel on 11.01.22.
//

import SwiftUI

class Hex: Hashable {
    let id = UUID()
    let name: String
    let symbol: UInt16
    var duration: Int
    
    let positive: Bool
    let damageAmount: Int
    
    let opposite: Hexes?
    
    init(name: String, symbol: UInt16, duration: Int, positive: Bool, damageAmount: Int = 0, opposite: Hexes? = nil) {
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
    
    static func == (lhs: Hex, rhs: Hex) -> Bool {
        return lhs.id == rhs.id
    }
}

enum Hexes: String, CaseIterable {
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
    case haunted
    case chained
    case invigorated
    case exhausted
    case restricted
    case enlightened
    
    func getHex() -> Hex {
        switch self {
            case .attackBoost:
                return Hex(name: self.rawValue, symbol: 0xf6de, duration: 3, positive: true, opposite: .attackDrop)
            case .attackDrop:
                return Hex(name: self.rawValue, symbol: 0xf6de, duration: 3, positive: false, opposite: .attackBoost)
            case .defenseBoost:
                return Hex(name: self.rawValue, symbol: 0xf132, duration: 3, positive: true, opposite: .defenseDrop)
            case .defenseDrop:
                return Hex(name: self.rawValue, symbol: 0xf132, duration: 3, positive: false, opposite: .defenseBoost)
            case .agilityBoost:
                return Hex(name: self.rawValue, symbol: 0xf72e, duration: 3, positive: true, opposite: .agilityDrop)
            case .agilityDrop:
                return Hex(name: self.rawValue, symbol: 0xf72e, duration: 3, positive: false, opposite: .agilityBoost)
            case .precisionBoost:
                return Hex(name: self.rawValue, symbol: 0xf05b, duration: 3, positive: true, opposite: .precisionDrop)
            case .precisionDrop:
                return Hex(name: self.rawValue, symbol: 0xf05b, duration: 3, positive: false, opposite: .precisionBoost)
            case .poisoned:
                return Hex(name: self.rawValue, symbol: 0xf54c, duration: 3, positive: false, damageAmount: 10)
            case .healed:
                return Hex(name: self.rawValue, symbol: 0xe05c, duration: 3, positive: true, damageAmount: -10)
            case .confused:
                return Hex(name: self.rawValue, symbol: 0xf074, duration: 3, positive: false)
            case .bombed:
                return Hex(name: self.rawValue, symbol: 0xf1e2, duration: 3, positive: false, damageAmount: 25)
            case .blessed:
                return Hex(name: self.rawValue, symbol: 0xf4c2, duration: 3, positive: true)
            case .haunted:
                return Hex(name: self.rawValue, symbol: 0xf05e, duration: 3, positive: false)
            case .chained:
                return Hex(name: self.rawValue, symbol: 0xf0c1, duration: 3, positive: false)
            case .invigorated:
                return Hex(name: self.rawValue, symbol: 0xf102, duration: 3, positive: true)
            case .exhausted:
                return Hex(name: self.rawValue, symbol: 0xf103, duration: 3, positive: false)
            case .restricted:
                return Hex(name: self.rawValue, symbol: 0xf023, duration: 3, positive: false)
            case .enlightened:
                return Hex(name: self.rawValue, symbol: 0xf5bb, duration: 3, positive: true)
        }
    }
    
    static func getNegativeHex() -> Hex {
        var hex: Hex = Hexes.allCases[0].getHex()
        while hex.positive {
            hex = Hexes.allCases[Int.random(in: 0 ..< Hexes.allCases.count)].getHex()
        }
        
        return hex
    }
}

enum Weather: String {
    case sandstorm
    case thunderstorm
    case sunnyDay
    case smog
    case mysticWeather
    case lightRain
    case drought
    
    func getHex(duration: Int) -> Hex {
        switch self {
            case .sandstorm:
                return Hex(name: self.rawValue, symbol: 0xf6c4, duration: duration, positive: true)
            case .thunderstorm:
                return Hex(name: self.rawValue, symbol: 0xf740, duration: duration, positive: true)
            case .sunnyDay:
                return Hex(name: self.rawValue, symbol: 0xf185, duration: duration, positive: true)
            case .smog:
                return Hex(name: self.rawValue, symbol: 0xf75f, duration: duration, positive: true)
            case .mysticWeather:
                return Hex(name: self.rawValue, symbol: 0xf75b, duration: duration, positive: true)
            case .lightRain:
                return Hex(name: self.rawValue, symbol: 0xf73d, duration: duration, positive: true)
            case .drought:
                return Hex(name: self.rawValue, symbol: 0xf5c7, duration: duration, positive: true)
        }
    }
}
