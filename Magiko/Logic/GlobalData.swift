//
//  GlobalData.swift
//  Magiko
//
//  Created by Janice Hablützel on 05.01.22.
//

import Foundation

class GlobalData {
    static let shared = GlobalData()
    
    var elements: Dictionary<String, Element> = [:]
    var elementArray: [Element] = []
    
    var skills: Dictionary<String, Skill> = [:]
    var fighters: [Fighter] = []
    var loadouts: [Loadout] = []
    
    var languages: [String] = []
    var translations: Dictionary<String, String> = [:]
    
    func loadData() {
        loadElements()
        loadSkills()
        loadFighters()
        loadLoadouts()
    }
    
    func loadElements() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Elements") {
            do {
                for url in urls {
                    let data = try Data(contentsOf: url)
                    let elementData = try JSONDecoder().decode(Element.self, from: data)
                    
                    elements[elementData.name] = elementData
                    elementArray.append(elementData)
                }
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(elements.count) elements")
        }
    }
    
    func loadSkills() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Skills") {
            do {
                for url in urls {
                    let data = try Data(contentsOf: url)
                    let skillData = try JSONDecoder().decode(Skill.self, from: data)
                    
                    skills[url.deletingPathExtension().lastPathComponent] = skillData
                }
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(skills.count) skills")
        }
    }
    
    func loadFighters() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Fighters") {
            do {
                for url in urls {
                    let data = try Data(contentsOf: url)
                    let fighterData = try JSONDecoder().decode(FighterData.self, from: data)
                    
                    fighters.append(Fighter(data: fighterData))
                }
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(fighters.count) fighters")
        }
    }
    
    func loadLoadouts() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Loadouts") {
            do {
                for url in urls {
                    let data = try Data(contentsOf: url)
                    let loadoutData = try JSONDecoder().decode(Loadout.self, from: data)
                    
                    loadouts.append(loadoutData)
                }
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(loadouts.count) loadouts")
        }
    }
    
    func getLanguages() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Languages") {
            for url in urls {
                languages.append(url.deletingPathExtension().lastPathComponent)
            }
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
