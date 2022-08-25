//
//  Hexes.swift
//  Elementary
//
//  Created by Janice Hablützel on 11.01.22.
//

import SwiftUI

/// Affects a fighter during multiple rounds.
class Hex: Hashable {
    private let id = UUID()
    
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
        return lhs.name == rhs.name && lhs.duration == rhs.duration
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
    case blocked
    case chained
    case invigorated
    case exhausted
    case restricted
    
    /// Creates and returns a hex.
    /// - Parameter duration: The duration of the hex
    /// - Returns: Returns a hex
    func getHex() -> Hex {
        switch self {
            case .attackBoost:
                return Hex(name: self.rawValue, symbol: 0xf6de, duration: 5, positive: true, opposite: .attackDrop)
            case .attackDrop:
                return Hex(name: self.rawValue, symbol: 0xf6de, duration: 5, positive: false, opposite: .attackBoost)
            case .defenseBoost:
                return Hex(name: self.rawValue, symbol: 0xf3ed, duration: 5, positive: true, opposite: .defenseDrop)
            case .defenseDrop:
                return Hex(name: self.rawValue, symbol: 0xf3ed, duration: 5, positive: false, opposite: .defenseBoost)
            case .agilityBoost:
                return Hex(name: self.rawValue, symbol: 0xf72e, duration: 5, positive: true, opposite: .agilityDrop)
            case .agilityDrop:
                return Hex(name: self.rawValue, symbol: 0xf72e, duration: 5, positive: false, opposite: .agilityBoost)
            case .precisionBoost:
                return Hex(name: self.rawValue, symbol: 0xf05b, duration: 5, positive: true, opposite: .precisionDrop)
            case .precisionDrop:
                return Hex(name: self.rawValue, symbol: 0xf05b, duration: 5, positive: false, opposite: .precisionBoost)
            case .resistanceBoost:
                return Hex(name: self.rawValue, symbol: 0xe05d, duration: 5, positive: true, opposite: .resistanceDrop)
            case .resistanceDrop:
                return Hex(name: self.rawValue, symbol: 0xe05d, duration: 5, positive: false, opposite: .resistanceBoost)
            case .poisoned:
                return Hex(name: self.rawValue, symbol: 0xf54c, duration: 3, positive: false, damageAmount: 10, opposite: .healed)
            case .healed:
                return Hex(name: self.rawValue, symbol: 0xe05c, duration: 3, positive: true, damageAmount: -10, opposite: .poisoned)
            case .confused:
                return Hex(name: self.rawValue, symbol: 0xf074, duration: 3, positive: false)
            case .bombed:
                return Hex(name: self.rawValue, symbol: 0xf1e2, duration: 3, positive: false, damageAmount: 25)
            case .blessed:
                return Hex(name: self.rawValue, symbol: 0xf665, duration: 3, positive: true)
            case .blocked:
                return Hex(name: self.rawValue, symbol: 0xf05e, duration: 3, positive: false)
            case .chained:
                return Hex(name: self.rawValue, symbol: 0xf0c1, duration: 3, positive: false)
            case .invigorated:
                return Hex(name: self.rawValue, symbol: 0xf102, duration: 3, positive: true, opposite: .exhausted)
            case .exhausted:
                return Hex(name: self.rawValue, symbol: 0xf103, duration: 3, positive: false, opposite: .invigorated)
            case .restricted:
                return Hex(name: self.rawValue, symbol: 0xf023, duration: 3, positive: false)
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
    case blizzard
    case drought
    case fullMoon
    case mysticWeather
    case rain
    case sandstorm
    
    /// Creates and returns a weather hex.
    /// - Parameter duration: The duration of the hex
    /// - Returns: Returns a hex
    func getHex(duration: Int) -> Hex {
        switch self {
            case .blizzard:
                return Hex(name: self.rawValue, symbol: 0xf740, duration: duration, positive: true)
            case .drought:
                return Hex(name: self.rawValue, symbol: 0xf185, duration: duration, positive: true)
            case .fullMoon:
                return Hex(name: self.rawValue, symbol: 0xf186, duration: duration, positive: true)
            case .mysticWeather:
                return Hex(name: self.rawValue, symbol: 0xf75b, duration: duration, positive: true)
            case .rain:
                return Hex(name: self.rawValue, symbol: 0xf73d, duration: duration, positive: true)
            case .sandstorm:
                return Hex(name: self.rawValue, symbol: 0xf75f, duration: duration, positive: true)
        }
    }
}
