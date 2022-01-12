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
    
    let uses: Int
    var useCounter: Int = 0
    
    let skills: [SubSkill]
    
    enum CodingKeys: String, CodingKey {
        case name, description, element, uses, skills
    }
    
    init() {
        name = "Unknown Skill"
        description = nil
        element = "Aether"
        
        uses = 10
        
        skills = []
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        element = try container.decode(String.self, forKey: .element)
        
        uses = try container.decode(Int.self, forKey: .uses)
        
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
    let power: Int
    let range: Int
    
    let chance: Int
    let effect: String?
    let healAmount: Int
    
    enum CodingKeys: String, CodingKey {
        case power, range, chance, effect, healAmount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        power = try container.decode(Int.self, forKey: .power)
        range = try container.decode(Int.self, forKey: .range)
        
        chance = try container.decodeIfPresent(Int.self, forKey: .chance) ?? 100
        effect = try container.decodeIfPresent(String.self, forKey: .effect) ?? nil
        healAmount = try container.decodeIfPresent(Int.self, forKey: .healAmount) ?? 0
    }
}

struct Move {
    let source: Fighter
    let target: Int
    
    var skill: Skill
    
    init(source: Fighter, target: Int = -1, skill: Skill = Skill()) {
        self.source = source
        self.target = target
        
        self.skill = skill
    }
    
    mutating func useSkill(amount: Int) {
        var skillIndex: Int = 0
        for sourceSkill in source.skills {
            if sourceSkill == skill {
                break
            }
            
            skillIndex += 1
        }
        skill.useCounter += amount
        source.skills[skillIndex] = skill
    }
}
