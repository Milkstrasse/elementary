//
//  GlobalData.swift
//  Magiko
//
//  Created by Janice Hablützel on 05.01.22.
//

import Foundation

struct GlobalData {
    static var allFighter: [Fighter] = []
    static var allSkills: Dictionary<String, Skill> = [:]
    
    static func loadData() {
        loadSkills()
        loadFighters()
    }
    
    static func loadFighters() {
        let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Fighters")
        if urls != nil {
            do {
                for url in urls! {
                    let data = try Data(contentsOf: url)
                    let fighterData = try JSONDecoder().decode(FighterData.self, from: data)
                    
                    allFighter.append(Fighter(data: fighterData))
                }
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(allFighter.count) fighters")
        }
    }
    
    static func loadSkills() {
        let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Skills")
        if urls != nil {
            do {
                for url in urls! {
                    let data = try Data(contentsOf: url)
                    let skillData = try JSONDecoder().decode(Skill.self, from: data)
                    
                    allSkills[url.deletingPathExtension().lastPathComponent] = skillData
                }
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(allSkills.count) skills")
        }
    }
}
