//
//  FighterData.swift
//  Magiko
//
//  Created by Janice Hablützel on 05.01.22.
//

import Foundation

struct FighterData: Decodable {
    let name: String
    let element: String
    let skills: [String]
    
    let base: Base
}

struct Base: Decodable {
    let health: UInt
    let attack: UInt
    let defense: UInt
    let agility: UInt
    let precision: UInt
    let spAttack: UInt
}

struct GlobalData {
    static var allFighterData: [FighterData] = []
    
    static func loadFighters() {
        let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Fighters")
        if urls != nil {
            var loadedData: [FighterData] = []
            
            do {
                for url in urls! {
                    let data = try Data(contentsOf: url)
                    let fighterData = try JSONDecoder().decode(FighterData.self, from: data)
                    
                    loadedData.append(fighterData)
                }
                
                allFighterData = loadedData
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(allFighterData.count) fighters")
        }
    }
}
