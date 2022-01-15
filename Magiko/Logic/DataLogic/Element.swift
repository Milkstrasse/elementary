//
//  Element.swift
//  Magiko
//
//  Created by Janice Hablützel on 08.01.22.
//

struct Element: Decodable {
    var name: String
    let color: String
    
    let strengths: [String]
    let weaknesses: [String]
    
    enum CodingKeys: String, CodingKey {
        case color, strengths, weaknesses
    }
    
    init() {
        name = "aether"
        color = "#929292"
        strengths = []
        weaknesses = []
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownElement"
        color = try container.decode(String.self, forKey: .color)
        
        strengths = try container.decode([String].self, forKey: .strengths)
        weaknesses = try container.decode([String].self, forKey: .weaknesses)
    }
    
    func hasAdvantage(element: Element) -> Bool {
        return strengths.contains(element.name)
    }
    
    func hasDisadvantage(element: Element) -> Bool {
        return weaknesses.contains(element.name)
    }
}
