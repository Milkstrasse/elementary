//
//  Element.swift
//  Magiko
//
//  Created by Janice Hablützel on 08.01.22.
//

/// Contains info on element.
struct Element: Decodable {
    var name: String
    let symbol: String
    
    let strengths: [String]
    let weaknesses: [String]
    
    enum CodingKeys: String, CodingKey {
        case symbol, strengths, weaknesses
    }
    
    /// Creates default element with no strengths or weaknesses.
    init() {
        name = "aether"
        symbol = "0xf52d"
        
        strengths = []
        weaknesses = []
    }
    
    /// Creates element from JSON data.
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownElement" //will be overwritten by GlobalData
        symbol = try container.decode(String.self, forKey: .symbol)
        
        strengths = try container.decode([String].self, forKey: .strengths)
        weaknesses = try container.decode([String].self, forKey: .weaknesses)
    }
    
    /// Checks if element is strong against the compared element.
    /// - Parameter element: The element to compare to
    /// - Returns: Returns wether the element is strong against the compared element
    func hasAdvantage(element: Element) -> Bool {
        return strengths.contains(element.name)
    }
    
    /// Checks if element is weak against the compared element.
    /// - Parameter element: The element to compare to
    /// - Returns: Returns wether the element is weak against the compared element
    func hasDisadvantage(element: Element) -> Bool {
        return weaknesses.contains(element.name)
    }
}
