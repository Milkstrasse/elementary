//
//  Fighter.swift
//  Magiko
//
//  Created by Janice Hablützel on 05.01.22.
//

/// Contains all the important data of a fighter.
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
    
    /// Creates a fighter from data, this data contains all of the information that will always remain the same.
    /// - Parameter data: This contains the main data of the fighter
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
    
    /// Calculates current stats of a fighter taking the current loadout and effects of the fighter into consideration.
    /// - Returns: Returns the current stats of a fighter
    func getModifiedBase() -> Base {
        let health: Int = max(base.health + loadout.healthMod, 0)
        var attack: Int = max(base.attack + attackMod + loadout.attackMod, 0)
        var defense: Int = max(base.defense + defenseMod + loadout.defenseMod, 0)
        let agility: Int = max(base.agility + agilityMod + loadout.agilityMod, 0)
        let precision: Int = max(base.precision + precisionMod + loadout.precisionMod, 0)
        let stamina: Int = max(base.stamina + loadout.staminaMod, 0)
        
        if ability.name == Abilities.enraged.rawValue && currhp < health/4 {
            attack += 40
        } else if ability.name == Abilities.defensive.rawValue && currhp < health/4 {
            defense += 40
        }
        
        return Base(health: health, attack: attack, defense: defense, agility: agility, precision: precision, stamina: stamina)
    }
    
    /// Changes the current loadout of a fighter.
    /// - Parameter loadout: The desired loadout
    func setLoadout(loadout: Int) {
        self.loadout = GlobalData.shared.loadouts[loadout]
        currhp = getModifiedBase().health
    }
    
    /// Changes the current ability of the fighter.
    /// - Parameter ability: The desired ability
    func setAbility(ability: Int) {
        self.ability = Abilities.allCases[ability].getAbility()
    }
    
    /// Checks if fighter has certain effect.
    /// - Parameter effectName: The name of the effect
    /// - Returns: Returns wether the fighter has the effect or not
    func hasEffect(effectName: String) -> Bool {
        for effect in effects {
            if effect.name == effectName {
                return true
            }
        }
        
        return false
    }
    
    /// Tries to to apply an effect to the fighter
    /// - Parameter effect: The desired effect
    /// - Returns: Returns whether the effect has been applied successfully or not
    func applyEffect(effect: Effect) -> Bool {
        //checks if effect removes other effects
        switch effect.name {
            case Effects.blessed.rawValue:
                for effect in effects {
                    if !effect.positive {
                        removeEffect(effect: effect)
                    }
                }
            case Effects.haunted.rawValue:
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
        
        if hasEffect(effectName: effect.name) { //refresh duration of effect if already present
            for index in effects.indices {
                if effects[index].name == effect.name {
                    effects[index] = effect
                }
            }
        } else if effects.count < 3 { //fighter can only have up to three effects
            //checks if other effect or an ability prevents the new effect
            if !effect.positive {
                if hasEffect(effectName: Effects.blessed.rawValue) {
                    return false
                } else if effect.name == Effects.chained.rawValue && self.ability.name == Abilities.freeSpirited.rawValue {
                    return false
                } else if effect.name == Effects.confused.rawValue && self.ability.name == Abilities.sceptic.rawValue {
                    return false
                } else if effect.name == Effects.poisoned.rawValue && self.ability.name == Abilities.immune.rawValue {
                    return false
                } else if effect.name == Effects.restricted.rawValue && self.ability.name == Abilities.rebellious.rawValue {
                    return false
                } else if effect.name == Effects.confused.rawValue && self.ability.name == Abilities.confident.rawValue {
                    return false
                }
            } else if effect.name == Effects.healed.rawValue {
                if hasEffect(effectName: Effects.haunted.rawValue) {
                    return false
                }
            }
            
            effects.append(effect) //effect has been added
            effects.sort {
                $0.duration < $1.duration
            }
            
            //makes changes to fighter if neccessary
            switch effect.name {
                case Effects.attackBoost.rawValue:
                    attackMod += 20
                case Effects.attackDrop.rawValue:
                    attackMod -= 20
                case Effects.defenseBoost.rawValue:
                    defenseMod += 20
                case Effects.defenseDrop.rawValue:
                    defenseMod -= 20
                case Effects.agilityBoost.rawValue:
                    agilityMod += 20
                case Effects.agilityDrop.rawValue:
                    agilityMod -= 20
                case Effects.precisionBoost.rawValue:
                    precisionMod += 20
                case Effects.precisionDrop.rawValue:
                    precisionMod -= 20
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
    
    /// Removes an effect from the fighter and reverts changes made by the effect
    /// - Parameter effect: The effect to be removed
    func removeEffect(effect: Effect) {
        effects.removeFirst()
        
        switch effect.name {
            case Effects.attackBoost.rawValue:
                attackMod -= 20
            case Effects.attackDrop.rawValue:
                attackMod += 20
            case Effects.defenseBoost.rawValue:
                defenseMod -= 20
            case Effects.defenseDrop.rawValue:
                defenseMod += 20
            case Effects.agilityBoost.rawValue:
                agilityMod -= 20
            case Effects.agilityDrop.rawValue:
                agilityMod += 20
            case Effects.precisionBoost.rawValue:
                precisionMod -= 20
            case Effects.precisionDrop.rawValue:
                precisionMod += 20
            case Effects.invigorated.rawValue:
                staminaUse = 2
            case Effects.exhausted.rawValue:
                staminaUse = 2
            default:
                break
        }
    }
    
    /// Removes all effects, refreshes all skills and restores the health of the fighter
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
    
    /// Removes all effects, refreshes all skills and restores half of the health of the fighter
    func revive() {
        reset()
        currhp = getModifiedBase().health/2
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Fighter, rhs: Fighter) -> Bool {
        return lhs.name == rhs.name
    }
}

/// Contains all the base data of a fighter. This data should always remain the same.
struct FighterData: Decodable {
    var name: String
    let element: String
    let skills: [String]
    
    let base: Base
    
    enum CodingKeys: String, CodingKey {
        case element, skills, base
    }
    
    /// Creates placeholder data for a fighter.
    /// - Parameters:
    ///   - name: The name of the fighter
    ///   - element: The element of the fighter
    ///   - skills: The skills of the fighter
    ///   - base: All the base stats of the fighter
    init(name: String, element: String, skills: [String], base: Base) {
        self.name = name
        self.element = element
        self.skills = skills
        
        self.base = base
    }
    
    /// Creates data for a fighter from JSON data
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownFighter" //will be overwritten by GlobalData
        element = try container.decode(String.self, forKey: .element)
        skills = try container.decode([String].self, forKey: .skills)
        
        base = try container.decode(Base.self, forKey: .base)
    }
}

/// Contains all base stat values of a fighter.
struct Base: Decodable {
    let health: Int
    let attack: Int
    let defense: Int
    let agility: Int
    let precision: Int
    let stamina: Int
}
