//
//  Skill.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

struct Skill: Decodable, Hashable {
    var name: String
    let element: String
    
    let type: String
    
    private let uses: Int
    var useCounter: Int = 0
    let skills: [SubSkill]
    
    enum CodingKeys: String, CodingKey {
        case element, type, uses, skills
    }
    
    init() {
        name = "unknownSkill"
        element = "aether"
        
        type = "default"
        
        uses = 10
        skills = []
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownSkill"
        element = try container.decode(String.self, forKey: .element)
        
        type = try container.decode(String.self, forKey: .type)
        
        uses = try container.decode(Int.self, forKey: .uses)
        skills = try container.decode([SubSkill].self, forKey: .skills)
    }
    
    func getUses(fighter: Fighter) -> Int {
        return uses + (fighter.getModifiedBase().stamina - 100)/10
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Skill, rhs: Skill) -> Bool {
        return lhs.name == rhs.name
    }
}

struct SubSkill: Decodable {
    let power: Int
    let range: Int
    
    let chance: Int
    let effect: String?
    let weatherEffect: String?
    
    let healAmount: Int
    
    enum CodingKeys: String, CodingKey {
        case power, range, chance, effect, weatherEffect, healAmount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        power = try container.decode(Int.self, forKey: .power)
        range = try container.decode(Int.self, forKey: .range)
        
        chance = try container.decodeIfPresent(Int.self, forKey: .chance) ?? 100
        effect = try container.decodeIfPresent(String.self, forKey: .effect) ?? nil
        weatherEffect = try container.decodeIfPresent(String.self, forKey: .weatherEffect) ?? nil
        
        healAmount = try container.decodeIfPresent(Int.self, forKey: .healAmount) ?? 0
    }
}
