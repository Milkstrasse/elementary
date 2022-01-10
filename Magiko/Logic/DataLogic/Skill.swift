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
    
    let statusChance: Int
    
    let attackMod: Int
    let defenseMod: Int
    let agilityMod: Int
    let precisionMod: Int
    let spAttackMod: Int
    
    enum CodingKeys: String, CodingKey {
        case power, range, statusChance, attackMod, defenseMod, agilityMod, precisionMod, spAttackMod
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        power = try container.decode(UInt.self, forKey: .power)
        range = try container.decode(Int.self, forKey: .range)
        
        statusChance = try container.decodeIfPresent(Int.self, forKey: .statusChance) ?? 0
        
        attackMod = try container.decodeIfPresent(Int.self, forKey: .attackMod) ?? 0
        defenseMod = try container.decodeIfPresent(Int.self, forKey: .defenseMod) ?? 0
        agilityMod = try container.decodeIfPresent(Int.self, forKey: .agilityMod) ?? 0
        precisionMod = try container.decodeIfPresent(Int.self, forKey: .precisionMod) ?? 0
        spAttackMod = try container.decodeIfPresent(Int.self, forKey: .spAttackMod) ?? 0
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
