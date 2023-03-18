//
//  Element.swift
//  Elementary
//
//  Created by Janice Hablützel on 08.01.22.
//

/// Contains info on element.
struct Element: Decodable {
    var name: String
    let symbol: String
    let color: String
    
    let strengths: [String]
    let weaknesses: [String]
    
    enum CodingKeys: String, CodingKey {
        case symbol, color, strengths, weaknesses
    }
    
    /// Creates default element with no strengths or weaknesses.
    init() {
        name = "unknownElement"
        symbol = "0xf128"
        color = "#000000"
        
        strengths = []
        weaknesses = []
    }
    
    /// Creates element from JSON data.
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownElement" //will be overwritten by GlobalData
        symbol = try container.decode(String.self, forKey: .symbol)
        color = try container.decode(String.self, forKey: .color)
        
        strengths = try container.decode([String].self, forKey: .strengths)
        weaknesses = try container.decode([String].self, forKey: .weaknesses)
    }
    
    /// Checks if element is strong against the compared element.
    /// - Parameters:
    ///   - element: The element to compare to
    ///   - weather: The current weather of the fight
    /// - Returns: Returns wether the element is strong against the compared element
    func hasAdvantage(element: Element, weather: Hex?) -> Bool {
        if weather?.name == Weather.magneticStorm.rawValue { //flips elements
            return weaknesses.contains(element.name)
        } else if weather?.name == Weather.denseFog.rawValue {
            return false
        } else {
            return strengths.contains(element.name)
        }
    }
    
    /// Checks if element is weak against the compared element.
    /// - Parameters:
    ///   - element: The element to compare to
    ///   - weather: The current weather of the fight
    /// - Returns: Returns wether the element is weak against the compared element
    func hasDisadvantage(element: Element, weather: Hex?) -> Bool {
        if weather?.name == Weather.magneticStorm.rawValue { //flips elements
            return strengths.contains(element.name)
        } else if weather?.name == Weather.denseFog.rawValue {
            return false
        } else {
            return weaknesses.contains(element.name)
        }
    }
}
