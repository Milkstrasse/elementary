//
//  Hexes.swift
//  Witchery
//
//  Created by Janice Hablützel on 11.01.22.
//

import SwiftUI

/// Affects a witch during multiple rounds.
class Hex: Hashable {
    let id = UUID()
    let name: String
    let symbol: UInt16
    var duration: Int
    
    let positive: Bool
    let damageAmount: Int
    
    let opposite: Hexes?
    
    /// Creates a hex.
    /// - Parameters:
    ///   - name: The name of the hex
    ///   - symbol: The symbol of the hex
    ///   - duration: The duration of the hex
    ///   - positive: If the hex has a positive effect
    ///   - damageAmount: The amount of damage the hex does
    ///   - opposite: The opposite of the hex if available
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

/// List of all possible hexes
enum Hexes: String, CaseIterable {
    case attackBoost
    case attackDrop
    case defenseBoost
    case defenseDrop
    case agilityBoost
    case agilityDrop
    case precisionBoost
    case precisionDrop
    case resistanceBoost
    case resistanceDrop
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
    
    /// Creates and returns a hex.
    /// - Parameter duration: The duration of the hex
    /// - Returns: Returns a hex
    func getHex(duration: Int = 3) -> Hex {
        switch self {
            case .attackBoost:
                return Hex(name: self.rawValue, symbol: 0xf6de, duration: duration, positive: true, opposite: .attackDrop)
            case .attackDrop:
                return Hex(name: self.rawValue, symbol: 0xf6de, duration: duration, positive: false, opposite: .attackBoost)
            case .defenseBoost:
                return Hex(name: self.rawValue, symbol: 0xf3ed, duration: duration, positive: true, opposite: .defenseDrop)
            case .defenseDrop:
                return Hex(name: self.rawValue, symbol: 0xf3ed, duration: duration, positive: false, opposite: .defenseBoost)
            case .agilityBoost:
                return Hex(name: self.rawValue, symbol: 0xf72e, duration: duration, positive: true, opposite: .agilityDrop)
            case .agilityDrop:
                return Hex(name: self.rawValue, symbol: 0xf72e, duration: duration, positive: false, opposite: .agilityBoost)
            case .precisionBoost:
                return Hex(name: self.rawValue, symbol: 0xf05b, duration: duration, positive: true, opposite: .precisionDrop)
            case .precisionDrop:
                return Hex(name: self.rawValue, symbol: 0xf05b, duration: duration, positive: false, opposite: .precisionBoost)
            case .resistanceBoost:
                return Hex(name: self.rawValue, symbol: 0xe05d, duration: duration, positive: true, opposite: .resistanceDrop)
            case .resistanceDrop:
                return Hex(name: self.rawValue, symbol: 0xe05d, duration: duration, positive: false, opposite: .resistanceBoost)
            case .poisoned:
                return Hex(name: self.rawValue, symbol: 0xf54c, duration: duration, positive: false, damageAmount: 10, opposite: .healed)
            case .healed:
                return Hex(name: self.rawValue, symbol: 0xe05c, duration: duration, positive: true, damageAmount: -10, opposite: .poisoned)
            case .confused:
                return Hex(name: self.rawValue, symbol: 0xf074, duration: duration, positive: false)
            case .bombed:
                return Hex(name: self.rawValue, symbol: 0xf1e2, duration: duration, positive: false, damageAmount: 25)
            case .blessed:
                return Hex(name: self.rawValue, symbol: 0xf4c2, duration: duration, positive: true)
            case .haunted:
                return Hex(name: self.rawValue, symbol: 0xf05e, duration: duration, positive: false)
            case .chained:
                return Hex(name: self.rawValue, symbol: 0xf0c1, duration: duration, positive: false)
            case .invigorated:
                return Hex(name: self.rawValue, symbol: 0xf102, duration: duration, positive: true, opposite: .exhausted)
            case .exhausted:
                return Hex(name: self.rawValue, symbol: 0xf103, duration: duration, positive: false, opposite: .invigorated)
            case .restricted:
                return Hex(name: self.rawValue, symbol: 0xf023, duration: duration, positive: false)
        }
    }
    
    /// Returns a random negative hex to create a curse.
    /// - Returns: Returns a random negative hex
    static func getNegativeHex() -> Hex {
        var hex: Hex = Hexes.allCases[0].getHex()
        while hex.positive {
            hex = Hexes.allCases[Int.random(in: 0 ..< Hexes.allCases.count)].getHex()
        }
        
        return hex
    }
}

/// Weather hexes boost different elements during multiple rounds. This is the list containing all available weather hexes.
enum Weather: String {
    case sandstorm
    case thunderstorm
    case sunnyDay
    case smog
    case mysticWeather
    case lightRain
    case drought
    
    /// Creates and returns a weather hex.
    /// - Parameter duration: The duration of the hex
    /// - Returns: Returns a hex
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
