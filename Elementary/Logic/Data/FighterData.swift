//
//  FighterData.swift
//  Elementary
//
//  Created by Janice Hablützel on 21.02.22.
//

import SwiftUI

/// Contains all the base data of a fighter. This data should always remain the same.
struct FighterData: Decodable {
    var name: String
    
    let element: String
    let base: Base
    let singleSpells: [String]
    let multiSpells: [String]
    
    let outfits: [Outfit]
    
    enum CodingKeys: String, CodingKey {
        case title, element, singleSpells, multiSpells, base, outfits
    }
    
    /// Creates placeholder data for a fighter.
    /// - Parameters:
    ///   - name: The name of the fighter
    ///   - element: The element of the fighter
    ///   - singleSpells: The spells of the fighter
    ///   - base: All the base stats of the fighter
    init(name: String, element: String, base: Base, singleSpells: [String], multiSpells: [String], outfits: [Outfit]) {
        self.name = name
        
        self.element = element
        self.base = base
        self.singleSpells = singleSpells
        self.multiSpells = multiSpells
        
        self.outfits = outfits
    }
    
    /// Creates data for a fighter from JSON data
    /// - Parameter decoder: The JSON decoder
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownFighter" //will be overwritten by GlobalData
        
        element = try container.decode(String.self, forKey: .element)
        base = try container.decode(Base.self, forKey: .base)
        singleSpells = try container.decode([String].self, forKey: .singleSpells)
        multiSpells = try container.decode([String].self, forKey: .multiSpells)
        
        outfits = try container.decode([Outfit].self, forKey: .outfits)
    }
}

/// Contains all the data of a fighter. This struct is used to save a fighter in favorites.
struct SavedFighterData: Codable, Equatable {
    let name: String
    
    let element: String
    let base: Base
    let singleSpells: [String]
    let multiSpells: [String]
    
    let nature: String
    let artifact: String
    
    let outfitIndex: Int
    let outfits: [Outfit]
    
    /// Stores data of a fighter.
    /// - Parameter fighter: The desired fighter
    init(fighter: Fighter) {
        name = fighter.name
        element = fighter.getElement().name
        singleSpells = fighter.data.singleSpells
        multiSpells = fighter.data.multiSpells
        
        nature = fighter.nature.name
        artifact = fighter.getArtifact().name
        
        base = fighter.base
        
        outfitIndex = fighter.outfitIndex
        outfits = fighter.data.outfits
    }
    
    /// Creates fighter from data.
    /// - Parameter images: The images corresponding to the fighter. Avoids the process of splitting the base image again
    /// - Returns: Returns the fighter created by the data
    func toFighter(images: [[Image]] = []) -> Fighter {
        let fighter: Fighter = Fighter(data: FighterData(name: name, element: element, base: base, singleSpells: singleSpells, multiSpells: multiSpells, outfits: outfits), outfitIndex: outfitIndex, images: images)
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
                    if lhs.outfitIndex == rhs.outfitIndex {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}
