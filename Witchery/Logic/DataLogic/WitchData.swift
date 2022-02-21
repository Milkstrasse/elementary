//
//  WitchData.swift
//  Witchery
//
//  Created by Janice Hablützel on 21.02.22.
//

/// Contains all the base data of a witch. This data should always remain the same.
struct WitchData: Decodable {
    var name: String
    let element: String
    let spells: [String]
    
    let base: Base
    
    enum CodingKeys: String, CodingKey {
        case element, spells, base
    }
    
    /// Creates placeholder data for a witch.
    /// - Parameters:
    ///   - name: The name of the witch
    ///   - element: The element of the witch
    ///   - spells: The spells of the witch
    ///   - base: All the base stats of the witch
    init(name: String, element: String, spells: [String], base: Base) {
        self.name = name
        self.element = element
        self.spells = spells
        
        self.base = base
    }
    
    /// Creates data for a witch from JSON data
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownWitch" //will be overwritten by GlobalData
        element = try container.decode(String.self, forKey: .element)
        spells = try container.decode([String].self, forKey: .spells)
        
        base = try container.decode(Base.self, forKey: .base)
    }
}

/// Contains all base stat values of a witch.
struct Base: Decodable {
    let health: Int
    let attack: Int
    let defense: Int
    let agility: Int
    let precision: Int
    let resistance: Int
}
