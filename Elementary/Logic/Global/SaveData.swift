//
//  SaveData.swift
//  Elementary
//
//  Created by Janice Hablützel on 24.02.22.
//

import SwiftUI

/// Contains all values of a save file.
struct SaveData: Codable {
    let langCode: String
    
    var generalVolume: Float
    let musicVolume: Float
    let soundVolume: Float
    let voiceVolume: Float
    
    let hapticToggle: Bool
    let textSpeed: Int
    
    let teamRestricted: Int
    let artifactUse: Int
    
    let attackModifier: Float
    let criticalModifier: Float
    let elementalModifier: Float
    let weatherModifier: Float
    let deviation: Int
    
    let savedFighters: [SavedFighterData]
    
    let userProgress: UserProgress
    
    static let fileManager: FileManager = FileManager.default
    static let fileName: String = "savedData.json"
    
    init() {
        generalVolume = AudioPlayer.shared.generalVolume
        musicVolume = AudioPlayer.shared.musicVolume
        soundVolume = AudioPlayer.shared.soundVolume
        voiceVolume = AudioPlayer.shared.voiceVolume
        hapticToggle = AudioPlayer.shared.hapticToggle
        
        langCode = Localization.shared.currentLang
        textSpeed = GlobalData.shared.textSpeed
        
        teamRestricted = GlobalData.shared.teamLimit
        artifactUse = GlobalData.shared.artifactUse
        
        attackModifier = GlobalData.shared.attackModifier
        criticalModifier = GlobalData.shared.criticalModifier
        elementalModifier = GlobalData.shared.elementalModifier
        weatherModifier = GlobalData.shared.weatherModifier
        deviation = GlobalData.shared.deviation
        
        savedFighters = GlobalData.shared.savedFighters
        
        userProgress = GlobalData.shared.userProgress
    }
    
    /// Save data into save file.
    static func save() {
        let saveData: SaveData = SaveData()
        
        do {
            let data: Data = try JSONEncoder().encode(saveData)
            if let url = makeURL(forFileNamed: SaveData.fileName) {
                try data.write(to: url, options: [.atomic])
            }
        } catch {
            print("error: \(error)")
        }
    }
    
    /// Loads and stores the data of the save file.
    static func load() {
        if let url = makeURL(forFileNamed: SaveData.fileName) {
            if SaveData.fileManager.fileExists(atPath: url.path) {
                do {
                    let data: Data = try Data(contentsOf: url)
                    let savedData: SaveData = try JSONDecoder().decode(SaveData.self, from: data)
                    
                    Localization.shared.currentLang = savedData.langCode
                    AudioPlayer.shared.generalVolume = savedData.generalVolume
                    AudioPlayer.shared.musicVolume = savedData.musicVolume
                    AudioPlayer.shared.soundVolume = savedData.soundVolume
                    AudioPlayer.shared.voiceVolume = savedData.voiceVolume
                    AudioPlayer.shared.hapticToggle = savedData.hapticToggle
                    
                    Localization.shared.currentLang = savedData.langCode
                    GlobalData.shared.textSpeed = savedData.textSpeed
                    
                    GlobalData.shared.teamLimit = savedData.teamRestricted
                    GlobalData.shared.artifactUse = savedData.artifactUse
                    
                    GlobalData.shared.attackModifier = savedData.attackModifier
                    GlobalData.shared.criticalModifier = savedData.criticalModifier
                    GlobalData.shared.elementalModifier = savedData.elementalModifier
                    GlobalData.shared.weatherModifier = savedData.weatherModifier
                    GlobalData.shared.deviation = savedData.deviation
                    
                    GlobalData.shared.savedFighters = savedData.savedFighters
                    
                    GlobalData.shared.userProgress = savedData.userProgress
                } catch {
                    print("error: \(error)")
                }
            } else { //no save file found -> create file and necessary folders
                let langCode: String = String(Locale.preferredLanguages[0].prefix(2))
                Localization.shared.currentLang = langCode
                
                if let url = SaveData.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    do {
                        try SaveData.fileManager.createDirectory(atPath: url.path + "/mods/assets", withIntermediateDirectories: true, attributes: nil)
                        try SaveData.fileManager.createDirectory(atPath: url.path + "/mods/elements", withIntermediateDirectories: true, attributes: nil)
                        try SaveData.fileManager.createDirectory(atPath: url.path + "/mods/languages", withIntermediateDirectories: true, attributes: nil)
                        try SaveData.fileManager.createDirectory(atPath: url.path + "/mods/spells", withIntermediateDirectories: true, attributes: nil)
                        try SaveData.fileManager.createDirectory(atPath: url.path + "/mods/fighters", withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("error: \(error)")
                    }
                }
                
                save()
            }
        }
    }
    
    /// Save latest fight data into save file
    static func saveFight() {
        do {
            if let url = makeURL(forFileNamed: FightLog.fileName) {
                try FightLog.shared.fightLog.write(to: url, atomically: true, encoding: .utf8)
            }
        } catch {
            print("error: \(error)")
        }
    }
    
    /// Get the URL to the correct location of a file.
    /// - Parameter fileName: The name of the file
    /// - Returns: Returns the URL to the location of the file
    private static func makeURL(forFileNamed fileName: String) -> URL? {
        if let url = SaveData.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent(fileName)
        } else {
            return nil
        }
    }
}
