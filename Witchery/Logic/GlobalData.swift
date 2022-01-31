//
//  GlobalData.swift
//  Witchery
//
//  Created by Janice Hablützel on 05.01.22.
//

import Foundation

class GlobalData {
    static let shared: GlobalData = GlobalData()
    
    var elements: Dictionary<String, Element> = [:]
    var elementArray: [Element] = []
    
    var spells: Dictionary<String, Spell> = [:]
    var witches: [Witch] = []
    var natures: [Nature] = []
    
    var textSpeed: Int = 2
    
    func loadData() {
        loadElements()
        loadSpells()
        loadWitches()
        loadNatures()
    }
    
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
    
    func getTextSpeed() -> Double {
        let x: Float = Float(textSpeed)
        let y: Float = 5 - x
        
        let speed: Double = Double(y * 0.5 - (y - 1) * 0.1)
        return round(100 * speed)/100
    }
}
