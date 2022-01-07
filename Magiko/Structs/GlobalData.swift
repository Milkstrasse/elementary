//
//  GlobalData.swift
//  Magiko
//
//  Created by Janice Hablützel on 05.01.22.
//

import Foundation

class GlobalData {
    static let shared = GlobalData()
    
    var allFighter: [Fighter] = []
    var allSkills: Dictionary<String, Skill> = [:]
    
    var languages: [String] = []
    var translations: Dictionary<String, String> = [:]
    
    func loadData() {
        loadSkills()
        loadFighters()
    }
    
    func loadFighters() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Fighters") {
            do {
                for url in urls {
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
    
    func loadSkills() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Skills") {
            do {
                for url in urls {
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
    
    func getLanguages() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Languages") {
            for url in urls {
                languages.append(url.deletingPathExtension().lastPathComponent)
            }
            
            print(languages)
        }
    }
    
    func loadLanguage(language: String) {
        if let url = Bundle.main.url(forResource: language, withExtension: "json", subdirectory: "Languages") {
            do {
                let data = try Data(contentsOf: url)
                translations = try JSONDecoder().decode([String:String].self, from: data)
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(translations.count) strings")
        }
    }
    
    func getTranslation(key: String) -> String {
        return translations[key] ?? key
    }
}
