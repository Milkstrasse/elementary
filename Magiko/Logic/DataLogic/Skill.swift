//
//  Skill.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import Foundation

struct Skill: Decodable, Hashable {
    let name: String
    let description: String?
    let element: String
    
    let skills: [SubSkill]
    
    enum CodingKeys: String, CodingKey {
        case name, description, element, skills
    }
    
    init() {
        name = "Unknown Skill"
        description = nil
        element = "Aether"
        
        skills = []
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        element = try container.decode(String.self, forKey: .element)
        
        skills = try container.decode([SubSkill].self, forKey: .skills)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Skill, rhs: Skill) -> Bool {
        return lhs.name == rhs.name
    }
}

struct SubSkill: Decodable {
    let power: UInt
    let range: Int
    
    let effect: String?
    
    enum CodingKeys: String, CodingKey {
        case power, range, effect
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        power = try container.decode(UInt.self, forKey: .power)
        range = try container.decode(Int.self, forKey: .range)
        
        effect = try container.decodeIfPresent(String.self, forKey: .effect) ?? nil
    }
}

struct Move {
    let source: Fighter
    let target: Int
    
    let skill: Skill
    
    init(source: Fighter, target: Int = -1, skill: Skill = Skill()) {
        self.source = source
        self.target = target
        
        self.skill = skill
    }
}
