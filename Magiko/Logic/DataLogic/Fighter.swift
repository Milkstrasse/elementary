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
    var currhp: Int
    
    var effects: [Effect] = []
    
    var skills: [Skill]
    
    var loadout: Loadout
    var ability: Ability
    
    var attackMod: Int = 0
    var defenseMod: Int = 0
    var agilityMod: Int = 0
    var precisionMod: Int = 0
    
    var staminaUse: Int = 2
    
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
        ability = Abilities.allCases[0].getAbility()
    }
    
    func getModifiedBase() -> Base {
        let health: Int = max(base.health + loadout.healthMod, 0)
        let attack: Int = max(base.attack + attackMod + loadout.attackMod, 0)
        let defense: Int = max(base.defense + defenseMod + loadout.defenseMod, 0)
        let agility: Int = max(base.agility + agilityMod + loadout.agilityMod, 0)
        let precision: Int = max(base.precision + precisionMod + loadout.precisionMod, 0)
        let stamina: Int = max(base.stamina + loadout.staminaMod, 0)
        
        return Base(health: health, attack: attack, defense: defense, agility: agility, precision: precision, stamina: stamina)
    }
    
    func setLoadout(loadout: Int) {
        self.loadout = GlobalData.shared.loadouts[loadout]
        currhp = getModifiedBase().health
    }
    
    func setAbility(ability: Int) {
        self.ability = Abilities.allCases[ability].getAbility()
    }
    
    func hasEffect(effectName: String) -> Bool {
        for effect in effects {
            if effect.name == effectName {
                return true
            }
        }
        
        return false
    }
    
    func applyEffect(effect: Effect) -> Bool {
        switch effect.name {
            case Effects.blessed.rawValue:
                for effect in effects {
                    if !effect.positive {
                        removeEffect(effect: effect)
                    }
                }
            case Effects.blocked.rawValue:
                if hasEffect(effectName: Effects.healed.rawValue) {
                    removeEffect(effect: effect)
                }
            case Effects.invigorated.rawValue:
                if hasEffect(effectName: Effects.exhausted.rawValue) {
                    removeEffect(effect: effect)
                }
            case Effects.exhausted.rawValue:
                if hasEffect(effectName: Effects.invigorated.rawValue) {
                    removeEffect(effect: effect)
                }
            default:
                break
        }
        
        if effects.count < 2 {
            if !effect.positive {
                if hasEffect(effectName: Effects.blessed.rawValue) {
                    return false
                } else if effect.name == Effects.chained.rawValue && self.ability.name == Abilities.freeSpirit.rawValue {
                    return false
                } else if effect.name == Effects.confused.rawValue && self.ability.name == Abilities.sceptic.rawValue {
                    return false
                } else if effect.name == Effects.poisoned.rawValue && self.ability.name == Abilities.immune.rawValue {
                    return false
                } else if effect.name == Effects.locked.rawValue && self.ability.name == Abilities.rebellious.rawValue {
                    return false
                } else if effect.name == Effects.confused.rawValue && self.ability.name == Abilities.confident.rawValue {
                    return false
                }
            } else if effect.name == Effects.healed.rawValue {
                if hasEffect(effectName: Effects.blocked.rawValue) {
                    return false
                }
            }
            
            effects.append(effect)
            effects.sort {
                $0.duration < $1.duration
            }
            
            switch effect.name {
                case Effects.attackBoost.rawValue:
                    attackMod += 40
                case Effects.attackDrop.rawValue:
                    attackMod -= 40
                case Effects.defenseBoost.rawValue:
                    defenseMod += 40
                case Effects.defenseDrop.rawValue:
                    defenseMod -= 40
                case Effects.agilityBoost.rawValue:
                    agilityMod += 40
                case Effects.agilityDrop.rawValue:
                    agilityMod -= 40
                case Effects.precisionBoost.rawValue:
                    precisionMod += 40
                case Effects.precisionDrop.rawValue:
                    precisionMod -= 40
                case Effects.invigorated.rawValue:
                    staminaUse = 1
                case Effects.exhausted.rawValue:
                    staminaUse = 3
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
            case Effects.attackBoost.rawValue:
                attackMod -= 40
            case Effects.attackDrop.rawValue:
                attackMod += 40
            case Effects.defenseBoost.rawValue:
                defenseMod -= 40
            case Effects.defenseDrop.rawValue:
                defenseMod += 40
            case Effects.agilityBoost.rawValue:
                agilityMod -= 40
            case Effects.agilityDrop.rawValue:
                agilityMod += 40
            case Effects.precisionBoost.rawValue:
                precisionMod -= 40
            case Effects.precisionDrop.rawValue:
                precisionMod += 40
            case Effects.invigorated.rawValue:
                staminaUse = 2
            case Effects.exhausted.rawValue:
                staminaUse = 2
            default:
                break
        }
    }
    
    func reset() {
        attackMod = 0
        defenseMod = 0
        agilityMod = 0
        precisionMod = 0
        
        currhp = getModifiedBase().health
        
        for effect in effects {
            removeEffect(effect: effect)
        }
        
        for index in skills.indices {
            skills[index].useCounter = 0
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
    let health: Int
    let attack: Int
    let defense: Int
    let agility: Int
    let precision: Int
    let stamina: Int
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
