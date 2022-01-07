//
//  Skill.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

import Foundation

struct Skill: Decodable, Hashable {
    let name: String
    let description: String
    let element: String
    
    let skills: [SubSkill]
    
    /*enum CodingKeys: String, CodingKey {
        case name, description, element, power
    }*/
    
    init() {
        name = "Unknown Skill"
        description = "Missing"
        element = "Aether"
        
        skills = []
    }

    /*init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        element = try container.decode(String.self, forKey: .element)
        
        //target = try container.decodeIfPresent(Target.self, forKey: .target) ?? .other
        
        power = try container.decode(UInt.self, forKey: .power)
    }*/
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Skill, rhs: Skill) -> Bool {
        return lhs.name == rhs.name
    }
}

struct SubSkill: Decodable {
    var power: UInt
    var range: Int
}

struct Move {
    let source: Fighter
    let target: Fighter?
    
    let skill: Skill
    
    init(source: Fighter, target: Fighter?, skill: Skill = Skill()) {
        self.source = source
        self.target = target
        
        self.skill = skill
    }
}
