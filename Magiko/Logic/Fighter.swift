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
    let element: Element
    
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
        element = GlobalData.shared.elements[data.element] ?? Element()
        
        base = data.base
        currhp = data.base.health
        
        skills = []
        let dataSkills = data.skills.removingDuplicates()
        
        for index in dataSkills.indices {
            let skill = GlobalData.shared.skills[dataSkills[index]] ?? Skill()
            skills.append(skill)
        }
    }
    
    func getModifiedBase() -> Base {
        let attack: Int = Int(base.attack) + attackMod
        let defense: Int = Int(base.defense) + defenseMod
        let agility: Int = Int(base.agility) + agilityMod
        let precision: Int = Int(base.precision) + precisionMod
        let spAttack: Int = Int(base.spAttack) + spAttackMod
        
        return Base(health: base.health, attack: UInt(attack), defense: UInt(defense), agility: UInt(agility), precision: UInt(precision), spAttack: UInt(spAttack))
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
