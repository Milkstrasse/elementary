//
//  Witch.swift
//  Witchery
//
//  Created by Janice Hablützel on 05.01.22.
//

/// Contains all the important data of a witch.
class Witch: Hashable {
    let name: String
    let element: Element
    
    let data: WitchData
    
    let base: Base
    var currhp: Int
    
    var hexes: [Hex] = []
    
    var spells: [Spell]
    
    var loadout: Loadout
    var ability: Ability
    
    var attackMod: Int = 0
    var defenseMod: Int = 0
    var agilityMod: Int = 0
    var precisionMod: Int = 0
    
    var manaUse: Int = 2
    
    /// Creates a witch from data, this data contains all of the information that will always remain the same.
    /// - Parameter data: This contains the main data of the witch
    init(data: WitchData) {
        name = data.name
        element = GlobalData.shared.elements[data.element] ?? Element()
        
        self.data = data
        
        base = data.base
        currhp = data.base.health
        
        spells = []
        let dataSpells = data.spells.removingDuplicates()
        
        for index in dataSpells.indices {
            let spell = GlobalData.shared.spells[dataSpells[index]] ?? Spell()
            spells.append(spell)
        }
        
        loadout = Loadout()
        ability = Abilities.allCases[0].getAbility()
    }
    
    /// Calculates current stats of a witch taking the current loadout and hexes of the witch into consideration.
    /// - Returns: Returns the current stats of a witch
    func getModifiedBase() -> Base {
        let health: Int = max(base.health + loadout.healthMod, 0)
        var attack: Int = max(base.attack + attackMod + loadout.attackMod, 0)
        var defense: Int = max(base.defense + defenseMod + loadout.defenseMod, 0)
        let agility: Int = max(base.agility + agilityMod + loadout.agilityMod, 0)
        let precision: Int = max(base.precision + precisionMod + loadout.precisionMod, 0)
        let resistance: Int = max(base.resistance + loadout.resistanceMod, 0)
        
        if ability.name == Abilities.enraged.rawValue && currhp < health/4 {
            attack += 40
        } else if ability.name == Abilities.defensive.rawValue && currhp < health/4 {
            defense += 40
        }
        
        return Base(health: health, attack: attack, defense: defense, agility: agility, precision: precision, resistance: resistance)
    }
    
    /// Changes the current loadout of a witch.
    /// - Parameter loadout: The desired loadout
    func setLoadout(loadout: Int) {
        self.loadout = GlobalData.shared.loadouts[loadout]
        currhp = getModifiedBase().health
    }
    
    /// Changes the current ability of the witch.
    /// - Parameter ability: The desired ability
    func setAbility(ability: Int) {
        self.ability = Abilities.allCases[ability].getAbility()
    }
    
    /// Checks if witch has certain hex.
    /// - Parameter hexName: The name of the hex
    /// - Returns: Returns wether the witch has the hex or not
    func hasHex(hexName: String) -> Bool {
        for hex in hexes {
            if hex.name == hexName {
                return true
            }
        }
        
        return false
    }
    
    /// Tries to to apply an hex to the witch
    /// - Parameter hex: The desired hex
    /// - Returns: Returns whether the hex has been applied successfully or not
    func applyHex(hex: Hex) -> Bool {
        if !hex.positive {
            let rndm: Int = Int.random(in: 0 ..< 100)
            if rndm < getModifiedBase().resistance/10 { //chance hex will be resisted
                return false
            }
        }
        
        //checks if hex removes other hexes
        switch hex.name {
            case Hexes.blessed.rawValue:
                for hex in hexes {
                    if !hex.positive {
                        removeHex(hex: hex)
                    }
                }
            case Hexes.haunted.rawValue:
                if hasHex(hexName: Hexes.healed.rawValue) {
                    removeHex(hex: hex)
                }
            case Hexes.invigorated.rawValue:
                if hasHex(hexName: Hexes.exhausted.rawValue) {
                    removeHex(hex: hex)
                }
            case Hexes.exhausted.rawValue:
                if hasHex(hexName: Hexes.invigorated.rawValue) {
                    removeHex(hex: hex)
                }
            default:
                break
        }
        
        if hasHex(hexName: hex.name) { //refresh duration of hex if already present
            for index in hexes.indices {
                if hexes[index].name == hex.name {
                    hexes[index] = hex
                }
            }
        } else if hexes.count < 3 { //witch can only have up to three hexes
            //checks if other hex or an ability prevents the new hex
            if !hex.positive {
                if hasHex(hexName: Hexes.blessed.rawValue) {
                    return false
                } else if hex.name == Hexes.chained.rawValue && self.ability.name == Abilities.freeSpirited.rawValue {
                    return false
                } else if hex.name == Hexes.confused.rawValue && self.ability.name == Abilities.sceptic.rawValue {
                    return false
                } else if hex.name == Hexes.poisoned.rawValue && self.ability.name == Abilities.immune.rawValue {
                    return false
                } else if hex.name == Hexes.restricted.rawValue && self.ability.name == Abilities.rebellious.rawValue {
                    return false
                } else if hex.name == Hexes.confused.rawValue && self.ability.name == Abilities.confident.rawValue {
                    return false
                }
            } else if hex.name == Hexes.healed.rawValue {
                if hasHex(hexName: Hexes.haunted.rawValue) {
                    return false
                }
            }
            
            hexes.append(hex) //hex has been added
            hexes.sort {
                $0.duration < $1.duration
            }
            
            //makes changes to witch if neccessary
            switch hex.name {
                case Hexes.attackBoost.rawValue:
                    attackMod += 20
                case Hexes.attackDrop.rawValue:
                    attackMod -= 20
                case Hexes.defenseBoost.rawValue:
                    defenseMod += 20
                case Hexes.defenseDrop.rawValue:
                    defenseMod -= 20
                case Hexes.agilityBoost.rawValue:
                    agilityMod += 20
                case Hexes.agilityDrop.rawValue:
                    agilityMod -= 20
                case Hexes.precisionBoost.rawValue:
                    precisionMod += 20
                case Hexes.precisionDrop.rawValue:
                    precisionMod -= 20
                case Hexes.invigorated.rawValue:
                    manaUse = 1
                case Hexes.exhausted.rawValue:
                    manaUse = 3
                default:
                    break
            }
            
            return true
        }
        
        return false
    }
    
    /// Removes an hex from the witch and reverts changes made by the hex
    /// - Parameter hex: The hex to be removed
    func removeHex(hex: Hex) {
        hexes.removeFirst()
        
        switch hex.name {
            case Hexes.attackBoost.rawValue:
                attackMod -= 20
            case Hexes.attackDrop.rawValue:
                attackMod += 20
            case Hexes.defenseBoost.rawValue:
                defenseMod -= 20
            case Hexes.defenseDrop.rawValue:
                defenseMod += 20
            case Hexes.agilityBoost.rawValue:
                agilityMod -= 20
            case Hexes.agilityDrop.rawValue:
                agilityMod += 20
            case Hexes.precisionBoost.rawValue:
                precisionMod -= 20
            case Hexes.precisionDrop.rawValue:
                precisionMod += 20
            case Hexes.invigorated.rawValue:
                manaUse = 2
            case Hexes.exhausted.rawValue:
                manaUse = 2
            default:
                break
        }
    }
    
    /// Removes all hexes, refreshes all spells and restores the health of the witch
    func reset() {
        attackMod = 0
        defenseMod = 0
        agilityMod = 0
        precisionMod = 0
        
        currhp = getModifiedBase().health
        
        for hex in hexes {
            removeHex(hex: hex)
        }
        
        for index in spells.indices {
            spells[index].useCounter = 0
        }
    }
    
    /// Removes all hexes, refreshes all spells and restores half of the health of the witch
    func revive() {
        reset()
        currhp = getModifiedBase().health/2
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Witch, rhs: Witch) -> Bool {
        return lhs.name == rhs.name
    }
}

/// Contains all the base data of a witch. This data should always remain the same.
struct WitchData: Decodable {
    var name: String
    let element: String
    let spells: [String]
    
    let base: Base
    
    enum CodingKeys: String, CodingKey {
        case element, spells, base
    }
    
    /// Creates placeholder data for a witch.
    /// - Parameters:
    ///   - name: The name of the witch
    ///   - element: The element of the witch
    ///   - spells: The spells of the witch
    ///   - base: All the base stats of the witch
    init(name: String, element: String, spells: [String], base: Base) {
        self.name = name
        self.element = element
        self.spells = spells
        
        self.base = base
    }
    
    /// Creates data for a witch from JSON data
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownWitch" //will be overwritten by GlobalData
        element = try container.decode(String.self, forKey: .element)
        spells = try container.decode([String].self, forKey: .spells)
        
        base = try container.decode(Base.self, forKey: .base)
    }
}

/// Contains all base stat values of a witch.
struct Base: Decodable {
    let health: Int
    let attack: Int
    let defense: Int
    let agility: Int
    let precision: Int
    let resistance: Int
}
