//
//  Abilities.swift
//  Magiko
//
//  Created by Janice Hablützel on 12.01.22.
//

struct Ability {
    let name: String
    let description: String
}

enum Abilities: String, CaseIterable {
    case freeSpirit
    case sceptic
    case immune
    case rebellious
    case confident
    case ethereal
    case weatherFrog
    case contrarian
    case coward
    
    func getAbility() -> Ability {
        return Ability(name: self.rawValue, description: self.rawValue + "Descr")
    }
}
