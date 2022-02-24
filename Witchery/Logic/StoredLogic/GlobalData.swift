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
    var witches: [Witch] = []
    var savedWitches: [SavedWitchData] = []
    var natures: [Nature] = []
    
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
    
    /// Returns the  first half of the list of all witches.
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
    
    func saveWitch(witch: SavedWitchData) {
        if savedWitches.count < 8 {
            if !isSaved(witch: witch) {
                savedWitches.append(witch)
            }
        }
    }
    
    func removeWitch(witch: SavedWitchData) {
        for (index, savedWitch) in savedWitches.enumerated() {
            if witch == savedWitch {
                savedWitches.remove(at: index)
                return
            }
        }
    }
    
    func isSaved(witch: SavedWitchData) -> Bool {
        for savedWitch in savedWitches {
            if witch == savedWitch {
                return true
            }
        }
        
        return false
    }
    
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
