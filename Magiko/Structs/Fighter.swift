//
//  Fighter.swift
//  Magiko
//
//  Created by Janice Hablützel on 05.01.22.
//

import Foundation
import CloudKit

struct Fighter: Hashable {
    let name: String
    let element: String
    
    let base: Base
    var currhp: UInt
    
    var skills: [Skill]
    
    var attackMod: Int = 0
    var defenseMod: Int = 0
    var agilityMod: Int = 0
    var precisionMod: Int = 0
    var spAttackMod: Int = 0
    
    init(data: FighterData) {
        name = data.name
        element = data.element
        
        base = data.base
        currhp = data.base.health
        
        skills = []
        let dataSkills = data.skills.removingDuplicates()
        
        for index in dataSkills.indices {
            let skill = GlobalData.allSkills[dataSkills[index]] ?? Skill(name: "Unknown Skill", description: "Missing", element: "Aether", power: 0)
            skills.append(skill)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Fighter, rhs: Fighter) -> Bool {
        return lhs.name == rhs.name
    }
}

struct FighterData: Decodable {
    let name: String
    let element: String
    let skills: [String]
    
    let base: Base
}

struct Base: Decodable {
    let health: UInt
    let attack: UInt
    let defense: UInt
    let agility: UInt
    let precision: UInt
    let spAttack: UInt
}

struct Element {
    let name: String
    
    let strengths: [ElementData]
    let weaknesses: [ElementData]
}

struct ElementData: Decodable {
    let name: String
    
    let strengths: [String]
    let weaknesses: [String]
}

struct Skill: Decodable, Hashable {
    let name: String
    let description: String
    
    let element: String
    
    let power: UInt
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
