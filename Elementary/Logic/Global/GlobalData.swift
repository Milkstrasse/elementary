//
//  GlobalData.swift
//  Elementary
//
//  Created by Janice Hablützel on 05.01.22.
//

import Foundation

/// Loads and stores data from folders.
class GlobalData {
    static let shared: GlobalData = GlobalData()
    
    var elements: Dictionary<String, Element> = [:]
    var elementArray: [Element] = []
    
    var spells: Dictionary<String, Spell> = [:]
    var natures: [Nature] = []
    
    var fighters: [Fighter] = []
    var savedFighters: [SavedFighterData] = []
    
    var textSpeed: Int = 2
    var artifactUse: Int = 0
    var teamLimit: Int = 1
    
    var playerProgress: PlayerProgress = PlayerProgress()
    
    /// Load data from folders.
    func loadData() {
        loadElements()
        loadSpells()
        loadFighters()
        loadNatures()
    }
    
    /// Load data from elements folder.
    func loadElements() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Elements") {
            for url in urls {
                do {
                    let data = try Data(contentsOf: url)
                    var elementData = try JSONDecoder().decode(Element.self, from: data)
                    elementData.name = url.deletingPathExtension().lastPathComponent
                    
                    elements.updateValue(elementData, forKey: elementData.name)
                    elementArray.append(elementData)
                } catch {
                    print("error: \(error)")
                }
            }
            
            print("loaded: \(elements.count) elements")
        }
    }
    
    /// Load data from spells folder.
    func loadSpells() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Spells") {
            for url in urls {
                do {
                    let data = try Data(contentsOf: url)
                    var spellData = try JSONDecoder().decode(Spell.self, from: data)
                    spellData.name = url.deletingPathExtension().lastPathComponent
                    
                    spells.updateValue(spellData, forKey: spellData.name)
                } catch {
                    print("error: \(error)")
                }
            }
            
            print("loaded: \(spells.count) spells")
        }
    }
    
    /// Load data from fighters folder.
    func loadFighters() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Fighters") {
            for url in urls {
                do {
                    let data = try Data(contentsOf: url)
                    var fighterData = try JSONDecoder().decode(FighterData.self, from: data)
                    fighterData.name = url.deletingPathExtension().lastPathComponent
                    
                    fighters.append(Fighter(data: fighterData))
                } catch {
                    print("error: \(error)")
                }
            }
            
            print("loaded: \(fighters.count) fighter")
        }
    }
    
    /// Load data from natures folder.
    func loadNatures() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Natures") {
            for url in urls {
                do {
                    let data = try Data(contentsOf: url)
                    var natureData = try JSONDecoder().decode(Nature.self, from: data)
                    natureData.name = url.deletingPathExtension().lastPathComponent
                    
                    natures.append(natureData)
                } catch {
                    print("error: \(error)")
                }
            }
            
            print("loaded: \(natures.count) natures")
        }
    }
    
    /// Returns the first half of the list of all fighters.
    /// - Returns: Returns an array of fighters
    func getFirstHalf() -> [Fighter] {
        if fighters.count%2 == 0 {
            let rowArray: ArraySlice<Fighter> = GlobalData.shared.fighters[0 ..< GlobalData.shared.fighters.count/2]
            return Array(rowArray)
        } else {
            let rowArray: ArraySlice<Fighter> = GlobalData.shared.fighters[0 ..< GlobalData.shared.fighters.count/2 + 1]
            return Array(rowArray)
        }
    }
    
    /// Returns the second half of the list of all fighters.
    /// - Returns: Returns an array of fighters
    func getSecondHalf() -> [Fighter] {
        if fighters.count%2 == 0 {
            let rowArray: ArraySlice<Fighter> = fighters[GlobalData.shared.fighters.count/2 ..< fighters.count]
            return Array(rowArray)
        } else {
            let rowArray: ArraySlice<Fighter> = fighters[fighters.count/2 + 1 ..< fighters.count]
            return Array(rowArray)
        }
    }
    
    /// Returns the amount of delay between the text.
    /// - Returns: Returns the amount of delay between the text
    func getTextSpeed() -> Double {
        let x: Float = Float(textSpeed)
        let y: Float = 5 - x
        
        let speed: Double = Double(y * 0.5 - (y - 1) * 0.1)
        return round(100 * speed)/100
    }
    
    /// Store fighter in favorites.
    /// - Parameter fighter: The fighter to be stored
    func saveFighter(fighter: SavedFighterData) {
        if savedFighters.count < 8 {
            if !isSaved(fighter: fighter) {
                savedFighters.append(fighter)
            }
        }
    }
    
    /// Remove fighter from favorites.
    /// - Parameter fighter: The fighter to be removed
    func removeFighter(fighter: SavedFighterData) {
        for (index, savedFighter) in savedFighters.enumerated() {
            if fighter == savedFighter {
                savedFighters.remove(at: index)
                return
            }
        }
    }
    
    /// Check if fighter has already been stored in favorites.
    /// - Parameter fighter: The desired fighter
    func isSaved(fighter: SavedFighterData) -> Bool {
        for savedFighter in savedFighters {
            if fighter == savedFighter {
                return true
            }
        }
        
        return false
    }
    
    /// Returns the first half of the list of all favorited fighters.
    /// - Returns: Returns an array of fighters
    func getFirstSavedHalf() -> [Fighter] {
        var array: [Fighter] = []
        
        if savedFighters.count%2 == 0 {
            let rowArray: ArraySlice<SavedFighterData> = savedFighters[0 ..< savedFighters.count/2]
            for savedFighter in rowArray {
                array.append(savedFighter.toFighter())
            }
        } else {
            let rowArray: ArraySlice<SavedFighterData> = savedFighters[0 ..< savedFighters.count/2 + 1]
            for savedFighter in rowArray {
                array.append(savedFighter.toFighter())
            }
        }
        
        return array
    }
    
    /// Returns the second half of the list of all favorited fighters.
    /// - Returns: Returns an array of fighters
    func getSecondSavedHalf() -> [Fighter] {
        var array: [Fighter] = []
        
        if savedFighters.count%2 == 0 {
            let rowArray: ArraySlice<SavedFighterData> = savedFighters[savedFighters.count/2 ..< savedFighters.count]
            for savedFighter in rowArray {
                array.append(savedFighter.toFighter())
            }
        } else {
            let rowArray: ArraySlice<SavedFighterData> = savedFighters[savedFighters.count/2 + 1 ..< savedFighters.count]
            for savedFighter in rowArray {
                array.append(savedFighter.toFighter())
            }
        }
        
        return array
    }
}
