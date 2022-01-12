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
    case ethereal
    
    func getAbility() -> Ability {
        switch self {
            case .freeSpirit:
                return Ability(name: self.rawValue, description: "Fighter can’t be chained.")
            case .ethereal:
                return Ability(name: self.rawValue, description: "Removes fighter’s typing")
        }
    }
}
