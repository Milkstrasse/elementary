//
//  Fighter.swift
//  Elementary
//
//  Created by Janice Hablützel on 05.01.22.
//

import CoreImage
import SwiftUI

/// Contains all the important data of a fighter.
class Fighter: Hashable, Equatable {
    let name: String
    let title: String
    
    let element: Element
    private var elementOverride: Element?
    
    let data: FighterData
    
    let base: Base
    var currhp: Int
    
    var hexes: [Hex] = []
    
    var singleSpells: [Spell]
    var multiSpells: [Spell]
    var lastSpell: Int
    
    var hasSwapped: Bool = false
    
    var nature: Nature
    private(set) var artifact: Artifact
    private var artifactOverride: Artifact?
    
    private var attackMod: Int = 0
    private var defenseMod: Int = 0
    private var agilityMod: Int = 0
    private var precisionMod: Int = 0
    private var resistanceMod: Int = 0
    
    var manaUse: Int = 2
    
    var outfitIndex: Int = 0
    var images: [[Image]]
    
    /// Creates a fighter from data, this data contains all of the information that will always remain the same.
    /// - Parameter data: This contains the main data of the fighter
    init(data: FighterData, outfitIndex: Int = 0, images: [[Image]] = []) {
        name = data.name
        title = data.title
        
        element = GlobalData.shared.elements[data.element] ?? Element()
        
        self.data = data
        
        base = data.base
        currhp = data.base.health
        
        singleSpells = []
        var dataSpells: [String] = data.singleSpells
        lastSpell = -1
        
        for index in dataSpells.indices {
            let spell = GlobalData.shared.spells[dataSpells[index]] ?? Spell()
            singleSpells.append(spell)
        }
        
        multiSpells = []
        dataSpells = data.multiSpells
        
        for index in dataSpells.indices {
            let spell = GlobalData.shared.spells[dataSpells[index]] ?? Spell()
            multiSpells.append(spell)
        }
        
        nature = Nature()
        artifact = Artifacts.allCases[0].getArtifact()
        
        self.outfitIndex = outfitIndex
        
        self.images = images
        
        if images.isEmpty {
            self.images = createImageArray()
        }
    }
    
    /// Returns the current element of a fighter checking if the permanent element is overriden by another.
    /// - Returns: Returns the current active element
    func getElement() -> Element {
        return elementOverride ?? element
    }
    
    /// Changes the temporary element of a fighter.
    /// - Parameter newElement: The desired element
    func overrideElement(newElement: Element) {
        self.elementOverride = newElement
    }
    
    /// Calculates current stats of a fighter taking the current nature and hexes of the fighter into consideration.
    /// - Parameter weather: The current weather of the fight
    /// - Returns: Returns the current stats of a fighter
    func getModifiedBase(weather: Hex? = nil) -> Base {
        let health: Int = max(base.health + nature.healthMod, 0)
        var attack: Int = max(base.attack + getHexBonus(hex: attackMod) + nature.attackMod, 0)
        var defense: Int = max(base.defense + getHexBonus(hex: defenseMod) + nature.defenseMod, 0)
        var agility: Int = max(base.agility + getHexBonus(hex: agilityMod) + nature.agilityMod, 0)
        let precision: Int = max(base.precision + getHexBonus(hex: precisionMod) + nature.precisionMod, 0)
        let resistance: Int = max(base.resistance + getHexBonus(hex: resistanceMod) + nature.resistanceMod, 0)
        
        if weather?.name != Weather.volcanicStorm.rawValue {
            if getArtifact().name == Artifacts.wand.rawValue && currhp < health/4 {
                attack += 40
            } else if getArtifact().name == Artifacts.charm.rawValue && currhp < health/4 {
                defense += 40
            } else if getArtifact().name == Artifacts.sevenLeague.rawValue && currhp < health/4 {
                agility += 40
            } else if getArtifact().name == Artifacts.armor.rawValue || getArtifact().name == Artifacts.sword.rawValue {
                attack += 40
            } else if  getArtifact().name == Artifacts.fetish.rawValue {
                for hex in hexes {
                    if !hex.positive {
                        attack += 25
                    }
                }
            }
        }
        
        if weather?.name == Weather.extremeHeat.rawValue {
            return Base(health: health, attack: defense, defense: attack, agility: agility, precision: precision, resistance: resistance)
        } else if weather?.name == Weather.heavyStorm.rawValue {
            return Base(health: health, attack: attack, defense: defense, agility: -agility, precision: precision, resistance: resistance)
        } else {
            return Base(health: health, attack: attack, defense: defense, agility: agility, precision: precision, resistance: resistance)
        }
    }
    
    /// Calculates the stat change caused by  hexes
    /// - Parameter hex: Category of hexes
    /// - Returns: Returns stat change caused by  hexes
    func getHexBonus(hex: Int) -> Int {
        var bonus: Int = 0
        if getArtifact().name == Artifacts.incense.rawValue {
            bonus = 20
        }
        
        return Int(round(sin(Float(hex)/2) * Float(40 + bonus)))
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
    
    /// Splits image into 5 parts.
    /// - Returns: Array of images
    func createImageArray() -> [[Image]] {
        var tempImages: [[Image]] = [[]]
        
        for outfitIndex in data.outfits.indices {
            tempImages.append([])
            
            let wholeImage: UIImage?
            
            if outfitIndex == 0 {
                wholeImage = UIImage(fileName: name)
            } else {
                wholeImage = UIImage(fileName: name + "_" + data.outfits[outfitIndex].name)
            }
            
            if wholeImage != nil {
                let imgFrames: [CGRect] = [CGRectMake(0, 1200, 600, 600), CGRectMake(600, 1200, 600, 600), CGRectMake(1200, 1200, 600, 600), CGRectMake(0, 600, 600, 600), CGRectMake(600, 600, 600, 600), CGRectMake(1200, 600, 600, 600), CGRectMake(0, 0, 600, 600)]
                
                for imgFrame in imgFrames {
                    let context = CIContext()
                    if let ciImage: CIImage = CIImage(image: wholeImage!) {
                        if let splitImage = context.createCGImage(ciImage, from: imgFrame) {
                            let uiImage = UIImage(cgImage: splitImage)
                            tempImages[outfitIndex].append(Image(uiImage: uiImage))
                        }
                    }
                }
            }
        }
        
        return tempImages
    }
    
    /// Returns the corresponding image for the outfit and state.
    /// - Parameters:
    ///   - index: Index of outfit
    ///   - blinking: Indicates wether the fighter is blinking
    ///   - state: The state of the fighter
    /// - Returns: Returns the corresponding image for the outfit and state
    func getImage(index: Int = -1, blinking: Bool, state: PlayerState) -> Image {
        var outfit: Int = index
        if index < 0 {
            outfit = outfitIndex
        }
        
        switch state {
        case .neutral:
            if !blinking {
                return images[outfit][0]
            } else {
                return images[outfit][1]
            }
        case .healing:
            return images[outfit][2]
        case .hurting:
            return images[outfit][3]
        case .hexNegative:
            return images[outfit][4]
        case .hexPositive:
            return images[outfit][5]
        case .attacking:
            return images[outfit][6]
        }
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
    /// - Parameters:
    ///   - hex: The desired hex
    ///   - resistable: Indicates wether the hex can be resisted or not
    /// - Returns: Returns a numbered outcome, 0 = success, 1 = failure, 2 = resistance
    func applyHex(hex: Hex, resistable: Bool = true) -> Int {
        if resistable { //chance hex will be resisted
            let chance: Int = Int.random(in: 0 ..< 100)
            if chance < (getModifiedBase().resistance/10 * getModifiedBase().resistance/10)/10 {
                return 2
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
        case Hexes.cursed.rawValue:
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
                    return 1
                }
            } else if hex.name == Hexes.healed.rawValue {
                if hasHex(hexName: Hexes.cursed.rawValue) {
                    return 1
                }
            }
            
            hexes.append(hex) //hex has been added
            
            //makes changes to fighter if neccessary
            switch hex.name {
            case Hexes.attackBoost.rawValue:
                attackMod += 1
                return 0
            case Hexes.attackDrop.rawValue:
                attackMod -= 1
                return 0
            case Hexes.defenseBoost.rawValue:
                defenseMod += 1
                return 0
            case Hexes.defenseDrop.rawValue:
                defenseMod -= 1
                return 0
            case Hexes.agilityBoost.rawValue:
                agilityMod += 1
                return 0
            case Hexes.agilityDrop.rawValue:
                agilityMod -= 1
                return 0
            case Hexes.precisionBoost.rawValue:
                precisionMod += 1
                return 0
            case Hexes.precisionDrop.rawValue:
                precisionMod -= 1
                return 0
            case Hexes.resistanceBoost.rawValue:
                resistanceMod += 1
                return 0
            case Hexes.resistanceDrop.rawValue:
                resistanceMod -= 1
                return 0
            case Hexes.invigorated.rawValue:
                manaUse = 1
                return 0
            case Hexes.exhausted.rawValue:
                manaUse = 3
                return 0
            default:
                return 0
            }
        }
        
        return 1
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
            attackMod -= 1
        case Hexes.attackDrop.rawValue:
            attackMod += 1
        case Hexes.defenseBoost.rawValue:
            defenseMod -= 1
        case Hexes.defenseDrop.rawValue:
            defenseMod += 1
        case Hexes.agilityBoost.rawValue:
            agilityMod -= 1
        case Hexes.agilityDrop.rawValue:
            agilityMod += 1
        case Hexes.precisionBoost.rawValue:
            precisionMod -= 1
        case Hexes.precisionDrop.rawValue:
            precisionMod += 1
        case Hexes.resistanceBoost.rawValue:
            resistanceMod -= 1
        case Hexes.resistanceDrop.rawValue:
            resistanceMod += 1
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
        resistanceMod = 0
        
        manaUse = 2
        
        hexes = []
    }
    
    /// Removes all hexes, refreshes all spells and restores the health of the fighter
    func reset() {
        currhp = getModifiedBase().health
        
        removeAllHexes()
        
        elementOverride = nil
        artifactOverride = nil
        
        lastSpell = -1
        
        for index in singleSpells.indices {
            singleSpells[index].useCounter = 0
        }
        
        for index in multiSpells.indices {
            multiSpells[index].useCounter = 0
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
