//
//  Witch.swift
//  Witchery
//
//  Created by Janice Hablützel on 05.01.22.
//

/// Contains all the important data of a witch.
class Witch: Hashable {
    let name: String
    private let element: Element
    private var elementOverride: Element?
    
    let data: WitchData
    
    private let base: Base
    var currhp: Int
    
    var hexes: [Hex] = []
    
    var spells: [Spell]
    
    var nature: Nature
    private var artifact: Artifact
    private var artifactOverride: Artifact?
    
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
        
        nature = Nature()
        artifact = Artifacts.allCases[0].getArtifact()
    }
    
    /// Returns the current element of a witch checking if the permanent element is overriden by another.
    /// - Returns: Returns the current active element
    func getElement() -> Element {
        var currElement: Element = element
        
        if getArtifact().name == Artifacts.ring.rawValue {
            currElement = Element()
        }
        
        return elementOverride ?? currElement
    }
    
    /// Changes the temporary element of a witch.
    /// - Parameter artifact: The desired element
    func overrideElement(newElement: Element) {
        self.elementOverride = newElement
    }
    
    /// Calculates current stats of a witch taking the current nature and hexes of the witch into consideration.
    /// - Returns: Returns the current stats of a witch
    func getModifiedBase() -> Base {
        let health: Int = max(base.health + nature.healthMod, 0)
        var attack: Int = max(base.attack + attackMod + nature.attackMod, 0)
        var defense: Int = max(base.defense + defenseMod + nature.defenseMod, 0)
        var agility: Int = max(base.agility + agilityMod + nature.agilityMod, 0)
        let precision: Int = max(base.precision + precisionMod + nature.precisionMod, 0)
        let resistance: Int = max(base.resistance + nature.resistanceMod, 0)
        
        if getArtifact().name == Artifacts.wand.rawValue && currhp < health/4 {
            attack += 40
        } else if getArtifact().name == Artifacts.charm.rawValue && currhp < health/4 {
            defense += 40
        } else if getArtifact().name == Artifacts.sevenLeague.rawValue && currhp < health/4 {
            agility += 40
        } else if getArtifact().name == Artifacts.corset.rawValue {
            attack += 40
        }
        
        return Base(health: health, attack: attack, defense: defense, agility: agility, precision: precision, resistance: resistance)
    }
    
    /// Changes the current nature of a witch.
    /// - Parameter nature: The desired nature
    func setNature(nature: Int) {
        self.nature = GlobalData.shared.natures[nature]
        currhp = getModifiedBase().health
    }
    
    /// Changes the current artifact of a witch.
    /// - Parameter artifact: The desired artifact
    func setArtifact(artifact: Int) {
        self.artifact = Artifacts.allCases[artifact].getArtifact()
    }
    
    /// Changes the temporary artifact of a witch.
    /// - Parameter artifact: The desired artifact
    func overrideArtifact(artifact: Artifact) {
        if artifact.name == Artifacts.corset.rawValue {
            removeHex(hex: Hexes.restricted.getHex())
        }
        
        self.artifactOverride = artifact
    }
    
    /// Returns the current artifact of a witch checking if the permanent artifact is overriden by another.
    /// - Returns: Returns the current active artifact
    func getArtifact() -> Artifact {
        return artifactOverride ?? artifact
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
    
    func getHexDuration(hexName: String) -> Int {
        for hex in hexes {
            if hex.name == hexName {
                return hex.duration
            }
        }
        
        return 0
    }
    
    /// Tries to to apply an hex to the witch
    /// - Parameter hex: The desired hex
    /// - Returns: Returns whether the hex has been applied successfully or not
    func applyHex(hex: Hex) -> Bool {
        if getArtifact().name == Artifacts.talisman.rawValue { //witch can't be hexed
            return false
        }
        
        if !hex.positive && hex.duration >= 0 { //hex with -1 duration are created by an artifact
            let chance: Int = Int.random(in: 0 ..< 100)
            if chance < getModifiedBase().resistance/10 { //chance hex will be resisted
                return false
            }
        }
        
        //checks if hex removes other hexes
        switch hex.name {
            case Hexes.blessed.rawValue:
                for hex in hexes {
                    if !hex.positive && hex.duration >= 0 { //hex with -1 duration are permanent
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
        
        if hexes.count < 3 { //witch can only have up to three hexes
            //checks if other hex or an artifact prevents the new hex
            if !hex.positive {
                if hasHex(hexName: Hexes.blessed.rawValue) {
                    return false
                }
            } else if hex.name == Hexes.healed.rawValue {
                if hasHex(hexName: Hexes.haunted.rawValue) {
                    return false
                }
            }
            
            hexes.append(hex) //hex has been added
            
            var bonus: Int = 0
            if getArtifact().name == Artifacts.incense.rawValue {
                bonus = 10
            }
            
            //makes changes to witch if neccessary
            switch hex.name {
                case Hexes.attackBoost.rawValue:
                    attackMod += 20 + bonus
                case Hexes.attackDrop.rawValue:
                    attackMod -= 20 + bonus
                case Hexes.defenseBoost.rawValue:
                    defenseMod += 20 + bonus
                case Hexes.defenseDrop.rawValue:
                    defenseMod -= 20 + bonus
                case Hexes.agilityBoost.rawValue:
                    agilityMod += 20 + bonus
                case Hexes.agilityDrop.rawValue:
                    agilityMod -= 20 + bonus
                case Hexes.precisionBoost.rawValue:
                    precisionMod += 20 + bonus
                case Hexes.precisionDrop.rawValue:
                    precisionMod -= 20 + bonus
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
        for (index, currHex) in hexes.enumerated() {
            if hex.name == currHex.name {
                hexes.remove(at: index)
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
    
    func removeAllHexes() {
        attackMod = 0
        defenseMod = 0
        agilityMod = 0
        precisionMod = 0
        
        manaUse = 2
        
        hexes = []
    }
    
    /// Removes all hexes, refreshes all spells and restores the health of the witch
    func reset() {
        currhp = getModifiedBase().health
        
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
