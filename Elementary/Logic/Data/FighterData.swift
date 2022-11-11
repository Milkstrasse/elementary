//
//  FighterData.swift
//  Elementary
//
//  Created by Janice Hablützel on 21.02.22.
//

/// Contains all the base data of a fighter. This data should always remain the same.
struct FighterData: Decodable {
    var name: String
    let title: String
    
    let element: String
    let base: Base
    let spells: [String]
    
    let skins: [String]
    
    enum CodingKeys: String, CodingKey {
        case title, element, spells, base, skins
    }
    
    /// Creates placeholder data for a fighter.
    /// - Parameters:
    ///   - name: The name of the fighter
    ///   - element: The element of the fighter
    ///   - spells: The spells of the fighter
    ///   - base: All the base stats of the fighter
    init(name: String, title: String, element: String, base: Base, spells: [String], skins: [String]) {
        self.name = name
        self.title = title
        
        self.element = element
        self.base = base
        self.spells = spells
        
        self.skins = skins
    }
    
    /// Creates data for a fighter from JSON data
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownFighter" //will be overwritten by GlobalData
        title = try container.decode(String.self, forKey: .title)
        
        element = try container.decode(String.self, forKey: .element)
        base = try container.decode(Base.self, forKey: .base)
        spells = try container.decode([String].self, forKey: .spells)
        
        skins = try container.decode([String].self, forKey: .skins)
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
    let title: String
    
    let element: String
    let base: Base
    let spells: [String]
    
    let nature: String
    let artifact: String
    
    let skinIndex: Int
    let skins: [String]
    
    /// Stores data of a fighter.
    /// - Parameter fighter: The desired fighter
    init(fighter: Fighter) {
        name = fighter.name
        title = fighter.title
        element = fighter.getElement().name
        spells = fighter.data.spells
        
        nature = fighter.nature.name
        artifact = fighter.getArtifact().name
        
        base = fighter.base
        
        skinIndex = fighter.skinIndex
        skins = fighter.data.skins
    }
    
    /// Creates fighter from data.
    /// - Returns: Returns the fighter created by the data
    func toFighter() -> Fighter {
        let fighter: Fighter = Fighter(data: FighterData(name: name, title: title, element: element, base: base, spells: spells, skins: skins), skinIndex: skinIndex)
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
                    if lhs.skinIndex == rhs.skinIndex {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}
