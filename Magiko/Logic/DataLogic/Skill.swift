//
//  Skill.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

/// Contains info on which actions a fighter can make when using this skill, the amount of uses and the element which can give a damage bonus when attacking..
struct Skill: Decodable, Hashable {
    var name: String
    let element: Element
    
    let type: String
    
    private let uses: Int
    var useCounter: Int = 0
    let skills: [SubSkill]
    
    enum CodingKeys: String, CodingKey {
        case element, type, uses, skills
    }
    
    /// Creates placeholder skill.
    init() {
        name = "unknownSkill"
        element = Element()
        
        type = "default"
        
        uses = 10
        skills = []
    }
    
    /// Creates skill from JSON data.
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownSkill" //will be overwritten by GlobalData
        let elem = try container.decode(String.self, forKey: .element)
        element = GlobalData.shared.elements[elem] ?? Element()
        
        type = try container.decode(String.self, forKey: .type)
        
        uses = try container.decode(Int.self, forKey: .uses)
        skills = try container.decode([SubSkill].self, forKey: .skills)
    }
    
    /// Checks how many uses a skill has with taking the stamina stat into consideration.
    /// - Parameter fighter: The owner of the skill
    /// - Returns: Returns the amount of uses the skill has
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

/// Subskills are a part of a skill and contain the info for one action.
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
    
    /// Creates action from JSON data.
    /// - Parameter decoder: The JSON decoder
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
