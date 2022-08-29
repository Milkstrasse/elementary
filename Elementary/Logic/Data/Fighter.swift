//
//  Fighter.swift
//  Elementary
//
//  Created by Janice Hablützel on 05.01.22.
//

/// Contains all the important data of a fighter.
class Fighter: Hashable, Equatable {
    let name: String
    private let element: Element
    private var elementOverride: Element?
    
    let data: FighterData
    
    let base: Base
    var currhp: Int
    
    var hexes: [Hex] = []
    
    var spells: [Spell]
    var lastMove: Move?
    var tauntCounter: Int = 0
    
    var nature: Nature
    private var artifact: Artifact
    private var artifactOverride: Artifact?
    
    private var attackMod: Int = 0
    private var defenseMod: Int = 0
    private var agilityMod: Int = 0
    private var precisionMod: Int = 0
    private var resistanceMod: Int = 0
    
    var manaUse: Int = 2
    
    /// Creates a fighter from data, this data contains all of the information that will always remain the same.
    /// - Parameter data: This contains the main data of the fighter
    init(data: FighterData) {
        name = data.name
        element = GlobalData.shared.elements[data.element] ?? Element()
        
        self.data = data
        
        base = data.base
        currhp = data.base.health
        
        spells = []
        let dataSpells = data.spells
        
        for index in dataSpells.indices {
            let spell = GlobalData.shared.spells[dataSpells[index]] ?? Spell()
            spells.append(spell)
        }
        
        nature = Nature()
        artifact = Artifacts.allCases[0].getArtifact()
    }
    
    /// Returns the current element of a fighter checking if the permanent element is overriden by another.
    /// - Returns: Returns the current active element
    func getElement() -> Element {
        return elementOverride ?? element
    }
    
    /// Changes the temporary element of a fighter.
    /// - Parameter artifact: The desired element
    func overrideElement(newElement: Element) {
        self.elementOverride = newElement
    }
    
    /// Calculates current stats of a fighter taking the current nature and hexes of the fighter into consideration.
    /// - Returns: Returns the current stats of a fighter
    func getModifiedBase() -> Base {
        let health: Int = max(base.health + nature.healthMod, 0)
        var attack: Int = max(base.attack + attackMod + nature.attackMod, 0)
        var defense: Int = max(base.defense + defenseMod + nature.defenseMod, 0)
        var agility: Int = max(base.agility + agilityMod + nature.agilityMod, 0)
        let precision: Int = max(base.precision + precisionMod + nature.precisionMod, 0)
        let resistance: Int = max(base.resistance + resistanceMod + nature.resistanceMod, 0)
        
        if getArtifact().name == Artifacts.wand.rawValue && currhp < health/4 {
            attack += 40
        } else if getArtifact().name == Artifacts.charm.rawValue && currhp < health/4 {
            defense += 40
        } else if getArtifact().name == Artifacts.sevenLeague.rawValue && currhp < health/4 {
            agility += 40
        } else if getArtifact().name == Artifacts.corset.rawValue || getArtifact().name == Artifacts.sword.rawValue {
            attack += 40
        }
        
        return Base(health: health, attack: attack, defense: defense, agility: agility, precision: precision, resistance: resistance)
    }
    
    /// Changes the current nature of a fighter.
    /// - Parameter nature: The desired nature
    func setNature(nature: Int) {
        self.nature = GlobalData.shared.natures[nature]
        currhp = getModifiedBase().health
    }
    
    /// Changes the current artifact of a fighter.
    /// - Parameter artifact: The desired artifact
    func setArtifact(artifact: Int) {
        self.artifact = Artifacts.allCases[artifact].getArtifact()
    }
    
    /// Changes the temporary artifact of a fighter.
    /// - Parameter artifact: The desired artifact
    func overrideArtifact(artifact: Artifact) {
        self.artifactOverride = artifact
    }
    
    /// Returns the current artifact of a fighter checking if the permanent artifact is overriden by another.
    /// - Returns: Returns the current active artifact
    func getArtifact() -> Artifact {
        return artifactOverride ?? artifact
    }
    
    /// Checks if fighter has certain hex.
    /// - Parameter hexName: The name of the hex
    /// - Returns: Returns wether the fighter has the hex or not
    func hasHex(hexName: String) -> Bool {
        for hex in hexes {
            if hex.name == hexName {
                return true
            }
        }
        
        return false
    }
    
    /// Get the duration of a certain hex.
    /// - Parameter hexName: The name of the hex
    /// - Returns: Returns the duration of the hex
    func getHexDuration(hexName: String) -> Int {
        for hex in hexes {
            if hex.name == hexName {
                return hex.duration
            }
        }
        
        return 0
    }
    
    /// Tries to to apply an hex to the fighter
    /// - Parameter hex: The desired hex
    /// - Returns: Returns whether the hex has been applied successfully or not
    func applyHex(hex: Hex, resistable: Bool = true) -> Bool {
        if resistable { //chance hex will be resisted
            let chance: Int = Int.random(in: 0 ..< 100)
            if chance < getModifiedBase().resistance/10 {
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
            case Hexes.blocked.rawValue:
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
        
        if hexes.count < 3 { //fighter can only have up to three hexes
            //checks if other hex or an artifact prevents the new hex
            if !hex.positive {
                if hasHex(hexName: Hexes.blessed.rawValue) {
                    return false
                }
            } else if hex.name == Hexes.healed.rawValue {
                if hasHex(hexName: Hexes.blocked.rawValue) {
                    return false
                }
            }
            
            hexes.append(hex) //hex has been added
            
            var bonus: Int = 0
            if getArtifact().name == Artifacts.incense.rawValue {
                bonus = 15
            }
            
            //makes changes to fighter if neccessary
            switch hex.name {
                case Hexes.attackBoost.rawValue:
                    attackMod += (25 + bonus)
                    return true
                case Hexes.attackDrop.rawValue:
                    attackMod -= (25 + bonus)
                    return true
                case Hexes.defenseBoost.rawValue:
                    defenseMod += (25 + bonus)
                    return true
                case Hexes.defenseDrop.rawValue:
                    defenseMod -= (25 + bonus)
                    return true
                case Hexes.agilityBoost.rawValue:
                    agilityMod += (25 + bonus)
                    return true
                case Hexes.agilityDrop.rawValue:
                    agilityMod -= (25 + bonus)
                    return true
                case Hexes.precisionBoost.rawValue:
                    precisionMod += (25 + bonus)
                    return true
                case Hexes.precisionDrop.rawValue:
                    precisionMod -= (25 + bonus)
                    return true
                case Hexes.resistanceBoost.rawValue:
                    resistanceMod += (25 + bonus)
                    return true
                case Hexes.resistanceDrop.rawValue:
                    resistanceMod -= (25 + bonus)
                    return true
                case Hexes.invigorated.rawValue:
                    manaUse = 1
                    return true
                case Hexes.exhausted.rawValue:
                    manaUse = 3
                    return true
                default:
                    return true
            }
        }
        
        return false
    }
    
    /// Removes an hex from the fighter and reverts changes made by the hex
    /// - Parameter hex: The hex to be removed
    func removeHex(hex: Hex) {
        for (index, currHex) in hexes.enumerated() {
            if hex == currHex {
                hexes.remove(at: index)
                break
            }
        }
        
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
    
    /// Removes all hexes and reverts any changes made by the hexes
    func removeAllHexes() {
        attackMod = 0
        defenseMod = 0
        agilityMod = 0
        precisionMod = 0
        
        manaUse = 2
        
        hexes = []
    }
    
    /// Removes all hexes, refreshes all spells and restores the health of the fighter
    func reset() {
        currhp = getModifiedBase().health
        tauntCounter = 0
        
        removeAllHexes()
        
        elementOverride = nil
        artifactOverride = nil
        
        for index in spells.indices {
            spells[index].useCounter = 0
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Fighter, rhs: Fighter) -> Bool {
        if lhs.name == rhs.name {
            if lhs.nature.name == rhs.nature.name {
                if lhs.artifact.name == rhs.artifact.name {
                    return true
                }
            }
        }
        
        return false
    }
}
