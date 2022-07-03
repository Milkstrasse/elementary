//
//  GlobalData.swift
//  Witchery
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
    
    var witches: [Witch] = []
    var savedWitches: [SavedWitchData] = []
    var tutorialWitches: [Witch] = []
    
    var textSpeed: Int = 2
    var artifactUse: Int = 0
    var teamRestricted: Bool = true
    
    /// Load data from folders.
    func loadData() {
        loadElements()
        loadSpells()
        loadWitches()
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
    
    /// Load data from witches folder.
    func loadWitches() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Witches") {
            for url in urls {
                do {
                    let data = try Data(contentsOf: url)
                    var witchData = try JSONDecoder().decode(WitchData.self, from: data)
                    witchData.name = url.deletingPathExtension().lastPathComponent
                    
                    witches.append(Witch(data: witchData))
                } catch {
                    print("error: \(error)")
                }
            }
            
            print("loaded: \(witches.count) witches")
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

    
    /// Creates an array of witches for the tutorial.
    /// - Returns: A curated selection of witches
    func getFirstTutorialHalf() -> [Witch] {
        let witch1: Witch = Witch(data: WitchData(name: "fire1", element: "fire", spells: ["fireSimpleAttack", "fireSpecialAttack", "drought", "restoration"], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        let witch2: Witch = Witch(data: WitchData(name: "aether1", element: "aether", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        let witch3: Witch = Witch(data: WitchData(name: "plant1", element: "plant", spells: ["plantSimpleAttack", "plantSpecialAttack", "poison", "attackDown"], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        let witch4: Witch = Witch(data: WitchData(name: "wind1", element: "wind", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        let witch5: Witch = Witch(data: WitchData(name: "decay1", element: "decay", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        let witch6: Witch = Witch(data: WitchData(name: "rock1", element: "rock", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        
        return [witch1, witch2, witch3, witch4, witch5, witch6]
    }
    
    /// Creates an array of witches for the tutorial.
    /// - Returns: A curated selection of witches
    func getSecondTutorialHalf() -> [Witch] {
        let witch1: Witch = Witch(data: WitchData(name: "electric1", element: "electric", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        let witch2: Witch = Witch(data: WitchData(name: "metal1", element: "metal", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        let witch3: Witch = Witch(data: WitchData(name: "wood1", element: "wood", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        let witch4: Witch = Witch(data: WitchData(name: "ice1", element: "ice", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        let witch5: Witch = Witch(data: WitchData(name: "water1", element: "water", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        let witch6: Witch = Witch(data: WitchData(name: "ground1", element: "ground", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, resistance: 100)))
        
        return [witch1, witch2, witch3, witch4, witch5, witch6]
    }
    
    /// Returns the first half of the list of all witches.
    /// - Returns: Returns an array of witches
    func getFirstHalf() -> [Witch] {
        if witches.count%2 == 0 {
            let rowArray: ArraySlice<Witch> = GlobalData.shared.witches[0 ..< GlobalData.shared.witches.count/2]
            return Array(rowArray)
        } else {
            let rowArray: ArraySlice<Witch> = GlobalData.shared.witches[0 ..< GlobalData.shared.witches.count/2 + 1]
            return Array(rowArray)
        }
    }
    
    /// Returns the second half of the list of all witches.
    /// - Returns: Returns an array of witches
    func getSecondHalf() -> [Witch] {
        if witches.count%2 == 0 {
            let rowArray: ArraySlice<Witch> = witches[GlobalData.shared.witches.count/2 ..< witches.count]
            return Array(rowArray)
        } else {
            let rowArray: ArraySlice<Witch> = witches[witches.count/2 + 1 ..< witches.count]
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
    
    /// Store witch in favourites.
    /// - Parameter witch: The witch to be stored
    func saveWitch(witch: SavedWitchData) {
        if savedWitches.count < 8 {
            if !isSaved(witch: witch) {
                savedWitches.append(witch)
            }
        }
    }
    
    /// Remove witch from favourites.
    /// - Parameter witch: The witch to be removed
    func removeWitch(witch: SavedWitchData) {
        for (index, savedWitch) in savedWitches.enumerated() {
            if witch == savedWitch {
                savedWitches.remove(at: index)
                return
            }
        }
    }
    
    /// Check if witch has already been stored in favourites.
    /// - Parameter witch: The desired witch
    func isSaved(witch: SavedWitchData) -> Bool {
        for savedWitch in savedWitches {
            if witch == savedWitch {
                return true
            }
        }
        
        return false
    }
    
    /// Returns the first half of the list of all favourited witches.
    /// - Returns: Returns an array of witches
    func getFirstSavedHalf() -> [Witch] {
        var array: [Witch] = []
        
        if savedWitches.count%2 == 0 {
            let rowArray: ArraySlice<SavedWitchData> = savedWitches[0 ..< savedWitches.count/2]
            for savedWitch in rowArray {
                array.append(savedWitch.toWitch())
            }
        } else {
            let rowArray: ArraySlice<SavedWitchData> = savedWitches[0 ..< savedWitches.count/2 + 1]
            for savedWitch in rowArray {
                array.append(savedWitch.toWitch())
            }
        }
        
        return array
    }
    
    /// Returns the second half of the list of all favourited witches.
    /// - Returns: Returns an array of witches
    func getSecondSavedHalf() -> [Witch] {
        var array: [Witch] = []
        
        if savedWitches.count%2 == 0 {
            let rowArray: ArraySlice<SavedWitchData> = savedWitches[savedWitches.count/2 ..< savedWitches.count]
            for savedWitch in rowArray {
                array.append(savedWitch.toWitch())
            }
        } else {
            let rowArray: ArraySlice<SavedWitchData> = savedWitches[savedWitches.count/2 + 1 ..< savedWitches.count]
            for savedWitch in rowArray {
                array.append(savedWitch.toWitch())
            }
        }
        
        return array
    }
}
