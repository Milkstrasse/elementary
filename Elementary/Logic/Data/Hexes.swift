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
    case taunted
    case doomed
    
    /// Creates and returns a hex.
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
            return Hex(name: self.rawValue, symbol: 0xf102, duration: 5, positive: true, opposite: .exhausted)
        case .exhausted:
            return Hex(name: self.rawValue, symbol: 0xf103, duration: 5, positive: false, opposite: .invigorated)
        case .restricted:
            return Hex(name: self.rawValue, symbol: 0xf023, duration: 3, positive: false)
        case .taunted:
            return Hex(name: self.rawValue, symbol: 0xf06d, duration: 3, positive: false)
        case .doomed:
            return Hex(name: self.rawValue, symbol: 0xf7a9, duration: 10, positive: false, damageAmount: 100)
        }
    }
}

/// Weather hexes boost different elements during multiple rounds. This is the list containing all available weather hexes.
enum Weather: String, CaseIterable {
    case snowstorm
    case sunnyDay
    case overcastSky
    case mysticWeather
    case lightRain
    case sandstorm
    case magneticStorm
    case denseFog
    case heavyStorm
    case extremeHeat
    case volcanicStorm
    case springWeather
    
    /// Creates and returns a weather hex.
    /// - Parameter duration: The duration of the hex
    /// - Returns: Returns a hex
    func getHex(duration: Int) -> Hex {
        switch self {
        case .snowstorm:
            return Hex(name: self.rawValue, symbol: 0xf739, duration: duration, positive: true)
        case .sunnyDay:
            return Hex(name: self.rawValue, symbol: 0xf185, duration: duration, positive: true)
        case .overcastSky:
            return Hex(name: self.rawValue, symbol: 0xf6c3, duration: duration, positive: true)
        case .mysticWeather:
            return Hex(name: self.rawValue, symbol: 0xf75b, duration: duration, positive: true)
        case .lightRain:
            return Hex(name: self.rawValue, symbol: 0xf75c, duration: duration, positive: true)
        case .sandstorm:
            return Hex(name: self.rawValue, symbol: 0xf6c4, duration: duration, positive: true)
        case .magneticStorm:
            return Hex(name: self.rawValue, symbol: 0xf076, duration: duration, positive: true)
        case .denseFog:
            return Hex(name: self.rawValue, symbol: 0xf760, duration: duration, positive: true)
        case .heavyStorm:
            return Hex(name: self.rawValue, symbol: 0xf751, duration: duration, positive: true)
        case .extremeHeat:
            return Hex(name: self.rawValue, symbol: 0xf765, duration: duration, positive: true)
        case .volcanicStorm:
            return Hex(name: self.rawValue, symbol: 0xf76c, duration: duration, positive: true)
        case .springWeather:
            return Hex(name: self.rawValue, symbol: 0xf4d8, duration: duration, positive: true)
        }
    }
    
    /// Checks if weather effect is beneficial to fighter.
    /// - Parameters:
    ///   - weather: The potential weather
    ///   - attacker: The fighter changing the weather
    ///   - defender: The targeted fighter
    /// - Returns: Returns wether the weather is beneficial or not
    static func isBeneficial(weather: String, attacker: Fighter, defender: Fighter) -> Bool {
        switch weather {
        case "snowstorm":
            return true
        case "sunnyDay":
            return true
        case "overcastSky":
            return true
        case "mysticWeather":
            return true
        case "lightRain":
            return true
        case "sandstorm":
            return true
        case "magneticStorm":
            if attacker.getElement().hasAdvantage(element: defender.getElement(), weather: nil) {
                return false
            } else {
                return true
            }
        case "denseFog":
            if attacker.getElement().hasAdvantage(element: defender.getElement(), weather: nil) {
                return false
            } else {
                return true
            }
        case "extremeHeat":
            if attacker.getModifiedBase().attack < attacker.getModifiedBase().defense {
                return true
            } else {
                return false
            }
        case "springWeather":
            if attacker.hasHex(hexName: "healed") {
                return false
            } else if defender.hasHex(hexName: "doomed") && !attacker.hasHex(hexName: "doomed") {
                return false
            } else {
                return true
            }
        default:
            return false
        }
    }
}
