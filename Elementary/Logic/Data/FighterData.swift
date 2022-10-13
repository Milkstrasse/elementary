//
//  FighterData.swift
//  Elementary
//
//  Created by Janice Hablützel on 21.02.22.
//

/// Contains all the base data of a fighter. This data should always remain the same.
struct FighterData: Decodable {
    var name: String
    let element: String
    let spells: [String]
    
    let base: Base
    
    enum CodingKeys: String, CodingKey {
        case element, spells, base
    }
    
    /// Creates placeholder data for a fighter.
    /// - Parameters:
    ///   - name: The name of the fighter
    ///   - element: The element of the fighter
    ///   - spells: The spells of the fighter
    ///   - base: All the base stats of the fighter
    init(name: String, element: String, spells: [String], base: Base) {
        self.name = name
        self.element = element
        self.spells = spells
        
        self.base = base
    }
    
    /// Creates data for a fighter from JSON data
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownFighter" //will be overwritten by GlobalData
        element = try container.decode(String.self, forKey: .element)
        spells = try container.decode([String].self, forKey: .spells)
        
        base = try container.decode(Base.self, forKey: .base)
    }
}

/// Contains all base stat values of a fighter.
struct Base: Codable {
    let health: Int
    let attack: Int
    let defense: Int
    let agility: Int
    let precision: Int
    let resistance: Int
}

/// Contains all the data of a fighter. This struct is used to save a fighter in favorites.
struct SavedFighterData: Codable, Equatable {
    let name: String
    let element: String
    let spells: [String]
    
    let nature: String
    let artifact: String
    
    let base: Base
    
    /// Stores data of a fighter.
    /// - Parameter fighter: The desired fighter
    init(fighter: Fighter) {
        name = fighter.name
        element = fighter.getElement().name
        spells = fighter.data.spells
        
        nature = fighter.nature.name
        artifact = fighter.getArtifact().name
        
        base = fighter.base
    }
    
    /// Creates which from data.
    /// - Returns: Returns the fighter crated by the data
    func toFighter() -> Fighter {
        let fighter: Fighter = Fighter(data: FighterData(name: name, element: element, spells: spells, base: base))
        for nat in GlobalData.shared.natures {
            if nat.name == nature {
                fighter.nature = nat
                break
            }
        }
        
        for (index, artfct) in Artifacts.allCases.enumerated() {
            if artfct.rawValue == artifact {
                fighter.setArtifact(artifact: index)
                return fighter
            }
        }
        
        return fighter
    }
    
    static func == (lhs: SavedFighterData, rhs: SavedFighterData) -> Bool {
        if lhs.name == rhs.name {
            if lhs.nature == rhs.nature {
                if lhs.artifact == rhs.artifact {
                    return true
                }
            }
        }
        
        return false
    }
}
