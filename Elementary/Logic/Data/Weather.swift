//
//  Weather.swift
//  Elementary
//
//  Created by Janice Hablützel on 05.02.23.
//

/// Weather hexes boost different elements during multiple rounds. This is the list containing all available weather hexes.
enum Weather: String, CaseIterable {
    case blizzard
    case sunnyDay
    case overcastSky
    case lightRain
    case sandstorm
    case thunderstorm
    case magneticStorm
    case denseFog
    case heavyStorm
    case extremeHeat
    case mysticWeather
    case springWeather
    
    /// Creates and returns a weather hex.
    /// - Parameter duration: The duration of the hex
    /// - Returns: Returns a hex
    func getHex(duration: Int) -> Hex {
        switch self {
        case .blizzard:
            return Hex(name: self.rawValue, symbol: 0xf739, duration: duration, element: GlobalData.shared.elements["ice"]!, positive: true)
        case .sunnyDay:
            return Hex(name: self.rawValue, symbol: 0xf185, duration: duration, element: GlobalData.shared.elements["plant"]!, positive: true)
        case .overcastSky:
            return Hex(name: self.rawValue, symbol: 0xf6c3, duration: duration, element: GlobalData.shared.elements["aether"]!, positive: true)
        case .lightRain:
            return Hex(name: self.rawValue, symbol: 0xf75c, duration: duration, element: GlobalData.shared.elements["water"]!, positive: true)
        case .sandstorm:
            return Hex(name: self.rawValue, symbol: 0xf6c4, duration: duration, element: GlobalData.shared.elements["ground"]!, positive: true)
        case .thunderstorm:
            return Hex(name: self.rawValue, symbol: 0xf76c, duration: duration, element: GlobalData.shared.elements["electric"]!, positive: true)
        case .magneticStorm:
            return Hex(name: self.rawValue, symbol: 0xf076, duration: duration, element: GlobalData.shared.elements["metal"]!, positive: true)
        case .denseFog:
            return Hex(name: self.rawValue, symbol: 0xf760, duration: duration, element: GlobalData.shared.elements["rock"]!, positive: true)
        case .heavyStorm:
            return Hex(name: self.rawValue, symbol: 0xf751, duration: duration, element: GlobalData.shared.elements["wind"]!, positive: true)
        case .extremeHeat:
            return Hex(name: self.rawValue, symbol: 0xf765, duration: duration, element: GlobalData.shared.elements["fire"]!, positive: true)
        case .mysticWeather:
            return Hex(name: self.rawValue, symbol: 0xf770, duration: duration, element: GlobalData.shared.elements["time"]!, positive: true)
        case .springWeather:
            return Hex(name: self.rawValue, symbol: 0xf4d8, duration: duration, element: GlobalData.shared.elements["wood"]!, positive: true)
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
        case "blizzard":
            return true
        case "sunnyDay":
            return true
        case "overcastSky":
            return true
        case "lightRain":
            return true
        case "sandstorm":
            return true
        case "thunderstorm":
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
    
    /// Goes through all weather hexes to find a weather hex matching the element.
    /// - Parameter element: An element
    /// - Returns: Return the matching weather
    static func getWeather(element: Element) -> Hex? {
        for weather in Weather.allCases {
            let tempWeather: Hex = weather.getHex(duration: 5)
            if tempWeather.element.name == element.name {
                return tempWeather
            }
        }
        
        return nil
    }
}
