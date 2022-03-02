//
//  SaveLogic.swift
//  Witchery
//
//  Created by Janice Hablützel on 24.02.22.
//

import Foundation
import SwiftUI

/// Saves data in a file and loads this data.
class SaveLogic {
    static let shared: SaveLogic = SaveLogic()
    
    static let fileManager: FileManager = FileManager.default
    static let fileName: String = "SavedData.json"
    
    /// Save data into save file
    func save() {
        let saveData: SaveData = SaveData(langCode: Localization.shared.currentLang, musicVolume: AudioPlayer.shared.musicVolume, soundVolume: AudioPlayer.shared.soundVolume, voiceVolume: AudioPlayer.shared.voiceVolume, hapticToggle: AudioPlayer.shared.hapticToggle, textSpeed: GlobalData.shared.textSpeed, teamRestricted: GlobalData.shared.teamRestricted, artifactUse: GlobalData.shared.artifactUse, savedWitches: GlobalData.shared.savedWitches)
        
        do {
            let data: Data = try JSONEncoder().encode(saveData)
            if let url = makeURL(forFileNamed: SaveLogic.fileName) {
                try data.write(to: url, options: [.atomic])
            }
        } catch {
            print("error: \(error)")
        }
    }
    
    /// Loads and stores the data of the save file.
    func load() {
        if let url = makeURL(forFileNamed: SaveLogic.fileName) {
            if SaveLogic.fileManager.fileExists(atPath: url.path) {
                do {
                    let data: Data = try Data(contentsOf: url)
                    let savedData: SaveData = try JSONDecoder().decode(SaveData.self, from: data)
                    
                    Localization.shared.currentLang = savedData.langCode
                    AudioPlayer.shared.musicVolume = savedData.musicVolume
                    AudioPlayer.shared.soundVolume = savedData.soundVolume
                    AudioPlayer.shared.voiceVolume = savedData.voiceVolume
                    AudioPlayer.shared.hapticToggle = savedData.hapticToggle
                    
                    GlobalData.shared.textSpeed = savedData.textSpeed
                    GlobalData.shared.teamRestricted = savedData.teamRestricted
                    GlobalData.shared.artifactUse = savedData.artifactUse
                    
                    GlobalData.shared.savedWitches = savedData.savedWitches
                } catch {
                    print("error: \(error)")
                }
            } else { //no save file found -> create file and necessary folders
                let langCode: String = String(Locale.preferredLanguages[0].prefix(2))
                Localization.shared.currentLang = langCode
                
                if let url = SaveLogic.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    do {
                        try SaveLogic.fileManager.createDirectory(atPath: url.path + "/mods/assets", withIntermediateDirectories: true, attributes: nil)
                        try SaveLogic.fileManager.createDirectory(atPath: url.path + "/mods/elements", withIntermediateDirectories: true, attributes: nil)
                        try SaveLogic.fileManager.createDirectory(atPath: url.path + "/mods/languages", withIntermediateDirectories: true, attributes: nil)
                        try SaveLogic.fileManager.createDirectory(atPath: url.path + "/mods/spells", withIntermediateDirectories: true, attributes: nil)
                        try SaveLogic.fileManager.createDirectory(atPath: url.path + "/mods/witches", withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("error: \(error)")
                    }
                }
                
                save()
            }
        }
        
        overwrite()
    }
    
    /// Get the URL to the correct location of a file.
    /// - Parameter fileName: The name of the file
    /// - Returns: Returns the URL to the location of the file
    private func makeURL(forFileNamed fileName: String) -> URL? {
        if let url = SaveLogic.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent(fileName)
        } else {
            return nil
        }
    }

    private func overwrite() {
        overwriteElements()
        overwriteSpells()
        overwriteWitches()
    }
    
    private func overwriteElements() {
        if let mainURL = SaveLogic.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let paths: [String]
            do {
                paths = try SaveLogic.fileManager.contentsOfDirectory(atPath: mainURL.path + "/mods/elements")
            } catch {
                print("error: \(error)")
                return
            }
            
            for path in paths {
                let url = URL.init(fileURLWithPath: mainURL.path + "/mods/elements/" + path)
                
                do {
                    let data = try Data(contentsOf: url)
                    var elementData = try JSONDecoder().decode(Element.self, from: data)
                    elementData.name = url.deletingPathExtension().lastPathComponent
                    
                    if GlobalData.shared.elements[elementData.name] == nil { //adds new element
                        GlobalData.shared.elementArray.append(elementData)
                    }
                    
                    GlobalData.shared.elements.updateValue(elementData, forKey: elementData.name)
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func overwriteSpells() {
        if let mainURL = SaveLogic.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let paths: [String]
            do {
                paths = try SaveLogic.fileManager.contentsOfDirectory(atPath: mainURL.path + "/mods/spells")
            } catch {
                print("error: \(error)")
                return
            }
            
            for path in paths {
                do {
                    let url = URL.init(fileURLWithPath: mainURL.path + "/mods/spells/" + path)

                    let data = try Data(contentsOf: url)
                    var spellData = try JSONDecoder().decode(Spell.self, from: data)
                    spellData.name = url.deletingPathExtension().lastPathComponent
                    
                    //adds new spell or replaces spell
                    GlobalData.shared.spells.updateValue(spellData, forKey: spellData.name)
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func overwriteWitches() {
        if let mainURL = SaveLogic.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let paths: [String]
            do {
                paths = try SaveLogic.fileManager.contentsOfDirectory(atPath: mainURL.path + "/mods/witches")
            } catch {
                print("error: \(error)")
                return
            }
            
            for path in paths {
                do {
                    let url = URL.init(fileURLWithPath: mainURL.path + "/mods/witches/" + path)

                    let data = try Data(contentsOf: url)
                    var witchData = try JSONDecoder().decode(WitchData.self, from: data)
                    witchData.name = url.deletingPathExtension().lastPathComponent
                    
                    for (index, witch) in GlobalData.shared.witches.enumerated() {
                        if witch.data.name == witchData.name {
                            GlobalData.shared.witches[index] = Witch(data: witchData) //replaces witch
                            return
                        }
                    }
                    
                    //adds new witch
                    GlobalData.shared.witches.append(Witch(data: witchData))
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
    
    func addTranslations(language: String) -> [String:String]  {
        if let mainURL = SaveLogic.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = URL.init(fileURLWithPath: mainURL.path + "/mods/languages/" + language + ".json")
            
            if SaveLogic.fileManager.fileExists(atPath: url.path) {
                do {
                    let data = try Data(contentsOf: url)
                    let translations: [String:String] = try JSONDecoder().decode([String:String].self, from: data)
                    
                    return translations
                } catch {
                    print("error: \(error)")
                }
            }
        }
        
        return [:]
    }
}
