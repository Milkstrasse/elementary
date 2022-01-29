//
//  Loadout.swift
//  Witchery
//
//  Created by Janice Hablützel on 17.01.22.
//

struct Loadout: Decodable {
    var name: String
    
    let healthMod: Int
    let attackMod: Int
    let defenseMod: Int
    let agilityMod: Int
    let precisionMod: Int
    let resistanceMod: Int
    
    enum CodingKeys: String, CodingKey {
        case healthMod, attackMod, defenseMod, agilityMod, precisionMod, resistanceMod
    }
    
    init() {
        name = "allrounder"
        
        healthMod = 0
        attackMod = 0
        defenseMod = 0
        agilityMod = 0
        precisionMod = 0
        resistanceMod = 0
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = "unknownElement"
        
        healthMod = try container.decode(Int.self, forKey: .healthMod)
        attackMod = try container.decode(Int.self, forKey: .attackMod)
        defenseMod = try container.decode(Int.self, forKey: .defenseMod)
        agilityMod = try container.decode(Int.self, forKey: .agilityMod)
        precisionMod = try container.decode(Int.self, forKey: .precisionMod)
        resistanceMod = try container.decode(Int.self, forKey: .resistanceMod)
    }
}
