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
    
    let generalVolume: Float
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
    
    static let fileManager: FileManager = FileManager.default
    static let settingsName: String = "settings.json"
    static let userName: String = "user.json"
    
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
    }
    
    /// Save settings into a json file.
    static func saveSettings() {
        let saveData: SaveData = SaveData()
        
        do {
            let encoder: JSONEncoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data: Data = try encoder.encode(saveData)
            if let url = makeURL(forFileNamed: SaveData.settingsName) {
                try data.write(to: url, options: [.atomic])
            }
        } catch {
            print("\(error)")
        }
    }
    
    /// Save user prgress as a json file.
    static func saveProgress() {
        let progress: UserProgress = GlobalData.shared.userProgress
        
        do {
            let data: Data = try JSONEncoder().encode(progress)
            if let url = makeURL(forFileNamed: SaveData.userName) {
                try data.write(to: url, options: [.atomic])
            }
        } catch {
            print("\(error)")
        }
    }
    
    /// Loads and stores the data of the save file.
    static func load() {
        if let url = makeURL(forFileNamed: SaveData.settingsName) {
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
                } catch {
                    print("\(error)")
                }
            } else { //no save file found -> create file and necessary folders
                let langCode: String = String(Locale.preferredLanguages[0].prefix(2))
                Localization.shared.currentLang = langCode
                
                saveSettings()
            }
        }
        
        if let url = makeURL(forFileNamed: SaveData.userName) {
            if SaveData.fileManager.fileExists(atPath: url.path) {
                do {
                    let data: Data = try Data(contentsOf: url)
                    let progress: UserProgress = try JSONDecoder().decode(UserProgress.self, from: data)
                    GlobalData.shared.userProgress = progress
                } catch {
                    print("\(error)")
                }
            } else { //no save file found -> create file and necessary folders
                let langCode: String = String(Locale.preferredLanguages[0].prefix(2))
                Localization.shared.currentLang = langCode
                
                saveProgress()
            }
        }
        
        if let url = SaveData.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let modUrl = URL.init(fileURLWithPath: url.path + "/mods")
            if !fileManager.directoryExists(atUrl: modUrl) {
                do {
                    try SaveData.fileManager.createDirectory(atPath: url.path + "/mods/assets", withIntermediateDirectories: true, attributes: nil)
                    try SaveData.fileManager.createDirectory(atPath: url.path + "/mods/elements", withIntermediateDirectories: true, attributes: nil)
                    try SaveData.fileManager.createDirectory(atPath: url.path + "/mods/languages", withIntermediateDirectories: true, attributes: nil)
                    try SaveData.fileManager.createDirectory(atPath: url.path + "/mods/spells", withIntermediateDirectories: true, attributes: nil)
                    try SaveData.fileManager.createDirectory(atPath: url.path + "/mods/fighters", withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("\(error)")
                }
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
            print("\(error)")
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

extension FileManager {
    /// Checks if directory exists.
    /// - Parameter url: The url of the directory
    /// - Returns: Return wether directory exists  or not
    func directoryExists(atUrl url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = self.fileExists(atPath: url.path, isDirectory:&isDirectory)
        return exists && isDirectory.boolValue
    }
}
