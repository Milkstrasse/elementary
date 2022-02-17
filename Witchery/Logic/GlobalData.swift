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
    var natures: [Nature] = []
    
    var textSpeed: Int = 2
    var artifactUse: Int = 0
    
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
            do {
                for url in urls {
                    let data = try Data(contentsOf: url)
                    var elementData = try JSONDecoder().decode(Element.self, from: data)
                    elementData.name = url.deletingPathExtension().lastPathComponent
                    
                    elements[elementData.name] = elementData
                    elementArray.append(elementData)
                }
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(elements.count) elements")
        }
    }
    
    /// Load data from spells folder.
    func loadSpells() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Spells") {
            do {
                for url in urls {
                    let data = try Data(contentsOf: url)
                    var spellData = try JSONDecoder().decode(Spell.self, from: data)
                    spellData.name = url.deletingPathExtension().lastPathComponent
                    
                    spells[spellData.name] = spellData
                }
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(spells.count) spells")
        }
    }
    
    /// Load data from witches folder.
    func loadWitches() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Witches") {
            do {
                for url in urls {
                    let data = try Data(contentsOf: url)
                    var witchData = try JSONDecoder().decode(WitchData.self, from: data)
                    witchData.name = url.deletingPathExtension().lastPathComponent
                    
                    witches.append(Witch(data: witchData))
                }
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(witches.count) witches")
        }
    }
    
    /// Load data from natures folder.
    func loadNatures() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Natures") {
            do {
                for url in urls {
                    let data = try Data(contentsOf: url)
                    var natureData = try JSONDecoder().decode(Nature.self, from: data)
                    natureData.name = url.deletingPathExtension().lastPathComponent
                    
                    natures.append(natureData)
                }
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(natures.count) natures")
        }
    }
    
    /// Returns the  first half of the list of all witches.
    /// - Returns: Returns an array of witches
    func getFirstHalf() -> [Witch?] {
        if GlobalData.shared.witches.count%2 == 0 {
            let rowArray = GlobalData.shared.witches[0 ..< GlobalData.shared.witches.count/2]
            return Array(rowArray)
        } else {
            let rowArray = GlobalData.shared.witches[0 ..< GlobalData.shared.witches.count/2 + 1]
            return Array(rowArray)
        }
    }
    
    /// Returns the second half of the list of all witches.
    /// - Returns: Returns an array of witches
    func getSecondHalf() -> [Witch?] {
        if GlobalData.shared.witches.count%2 == 0 {
            let rowArray = GlobalData.shared.witches[GlobalData.shared.witches.count/2 ..< GlobalData.shared.witches.count]
            return Array(rowArray)
        } else {
            let rowArray = GlobalData.shared.witches[GlobalData.shared.witches.count/2 + 1 ..< GlobalData.shared.witches.count]
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
}
