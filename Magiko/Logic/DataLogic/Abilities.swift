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
    
    func getAbility() -> Ability {
        switch self {
            case .freeSpirit:
                return Ability(name: self.rawValue, description: "Fighter can’t be chained.")
            case .sceptic:
                return Ability(name: self.rawValue, description: "Fighter can’t be cursed.")
            case .immune:
                return Ability(name: self.rawValue, description: "Fighter can’t be poisoned.")
            case .rebellious:
                return Ability(name: self.rawValue, description: "Fighter can’t be locked.")
            case .confident:
                return Ability(name: self.rawValue, description: "Fighter can’t become confused.")
            case .ethereal:
                return Ability(name: self.rawValue, description: "Removes fighter’s element.")
            case .weatherFrog:
                return Ability(name: self.rawValue, description: "Extend weather skills.")
        }
    }
}
