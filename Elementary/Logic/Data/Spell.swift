//
//  Spell.swift
//  Elementary
//
//  Created by Janice Hablützel on 07.01.22.
//

/// Contains info on which actions a fighter can make when using this spell, the amount of uses and the element which can give a damage bonus when attacking..
struct Spell: Decodable, Hashable {
    var name: String
    let element: Element
    
    let typeID: Int
    let priority: Int
    
    let uses: Int
    var useCounter: Int = 0
    var subSpells: [SubSpell]
    
    enum CodingKeys: String, CodingKey {
        case element, typeID, priority, uses, subSpells
    }
    
    /// Creates placeholder spell.
    init(name: String = "unknownSpell") {
        self.name = name
        element = Element()
        
        typeID = 0
        priority = 0
        
        uses = 10
        subSpells = [SubSpell()]
    }
    
    /// Creates spell from JSON data.
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownSpell" //will be overwritten by GlobalData
        let elem = try container.decode(String.self, forKey: .element)
        element = GlobalData.shared.elements[elem] ?? Element()
        
        typeID = try container.decode(Int.self, forKey: .typeID)
        priority = try container.decodeIfPresent(Int.self, forKey: .priority) ?? 0
        
        uses = try container.decode(Int.self, forKey: .uses)
        subSpells = try container.decode([SubSpell].self, forKey: .subSpells)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Spell, rhs: Spell) -> Bool {
        return lhs.name == rhs.name
    }
}

/// Subspells are a part of a spell and contain the info for one action.
struct SubSpell: Decodable {
    let power: Int
    let range: Int
    
    let chance: Int
    let hex: String?
    let weather: String?
    
    var healAmount: Int
    
    enum CodingKeys: String, CodingKey {
        case power, range, chance, hex, weather, healAmount
    }
    
    /// Creates placeholder sub spell.
    init() {
        power = 100
        range = 1
        
        chance = 100
        hex = nil
        weather = nil
        
        healAmount = 0
    }
    
    /// Creates action from JSON data.
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        power = try container.decode(Int.self, forKey: .power)
        range = try container.decode(Int.self, forKey: .range)
        
        chance = try container.decodeIfPresent(Int.self, forKey: .chance) ?? 100
        hex = try container.decodeIfPresent(String.self, forKey: .hex) ?? nil
        weather = try container.decodeIfPresent(String.self, forKey: .weather) ?? nil
        
        healAmount = try container.decodeIfPresent(Int.self, forKey: .healAmount) ?? 0
    }
}
