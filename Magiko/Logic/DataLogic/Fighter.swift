//
//  Fighter.swift
//  Magiko
//
//  Created by Janice Hablützel on 05.01.22.
//

class Fighter: Hashable {
    let name: String
    let element: Element
    
    let data: FighterData
    
    let base: Base
    var currhp: UInt
    
    var effects: [Effect] = []
    
    var skills: [Skill]
    
    var loadout: Loadout
    
    var attackMod: Int = 0
    var defenseMod: Int = 0
    var agilityMod: Int = 0
    var precisionMod: Int = 0
    
    init(data: FighterData) {
        name = data.name
        element = GlobalData.shared.elements[data.element] ?? Element()
        
        self.data = data
        
        base = data.base
        currhp = data.base.health
        
        skills = []
        let dataSkills = data.skills.removingDuplicates()
        
        for index in dataSkills.indices {
            let skill = GlobalData.shared.skills[dataSkills[index]] ?? Skill()
            skills.append(skill)
        }
        
        loadout = Loadout()
    }
    
    func getModifiedBase() -> Base {
        let health: Int = max(Int(base.health) + loadout.healthMod, 0)
        let attack: Int = max(Int(base.attack) + attackMod + loadout.attackMod, 0)
        let defense: Int = max(Int(base.defense) + defenseMod + loadout.defenseMod, 0)
        let agility: Int = max(Int(base.agility) + agilityMod + loadout.agilityMod, 0)
        let precision: Int = max(Int(base.precision) + precisionMod + loadout.precisionMod, 0)
        let stamina: Int = max(Int(base.stamina) + loadout.staminaMod, 0)
        
        return Base(health: UInt(health), attack: UInt(attack), defense: UInt(defense), agility: UInt(agility), precision: UInt(precision), stamina: UInt(stamina))
    }
    
    func setLoadout(loadout: Int) {
        if loadout < GlobalData.shared.loadouts.count {
            self.loadout = GlobalData.shared.loadouts[loadout]
            
            currhp = getModifiedBase().health
        }
    }
    
    func applyEffect(effect: Effect) -> Bool {
        if effects.count < 2 {
            effects.append(effect)
            effects.sort {
                $0.duration < $1.duration
            }
            
            switch effect.name {
                case "attackBoost":
                    attackMod += 40
                case "attackDrop":
                    attackMod -= 40
                case "defenseBoost":
                    defenseMod += 40
                case "defenseDrop":
                    defenseMod -= 40
                case "agilityBoost":
                    agilityMod += 40
                case "agilityDrop":
                    agilityMod -= 40
                case "precisionBoost":
                    precisionMod += 40
                case "precisionDrop":
                    precisionMod -= 40
                default:
                    break
            }
            
            return true
        }
        
        return false
    }
    
    func removeEffect(effect: Effect) {
        effects.removeFirst()
        
        switch effect.name {
            case "attackBoost":
                attackMod -= 40
            case "attackDrop":
                attackMod += 40
            case "defenseBoost":
                defenseMod -= 40
            case "defenseDrop":
                defenseMod += 40
            case "agilityBoost":
                agilityMod -= 40
            case "agilityDrop":
                agilityMod += 40
            case "precisionBoost":
                precisionMod -= 40
            case "precisionDrop":
                precisionMod += 40
            default:
                break
        }
    }
    
    func reset() {
        effects = []
        
        attackMod = 0
        defenseMod = 0
        agilityMod = 0
        precisionMod = 0
        
        currhp = getModifiedBase().health
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
    let stamina: UInt
}

struct Loadout: Decodable {
    let name: String
    
    let healthMod: Int
    let attackMod: Int
    let defenseMod: Int
    let agilityMod: Int
    let precisionMod: Int
    let staminaMod: Int
    
    init() {
        name = "Neutral"
        
        healthMod = 0
        attackMod = 0
        defenseMod = 0
        agilityMod = 0
        precisionMod = 0
        staminaMod = 0
    }
}
