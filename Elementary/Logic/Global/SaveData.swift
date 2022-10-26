//
//  SaveData.swift
//  Elementary
//
//  Created by Janice Hablützel on 24.02.22.
//

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
    
    let savedFighters: [SavedFighterData]
    
    let userProgress: UserProgress
    
    init() {
        langCode = Localization.shared.currentLang
        
        generalVolume = AudioPlayer.shared.generalVolume
        musicVolume = AudioPlayer.shared.musicVolume
        soundVolume = AudioPlayer.shared.soundVolume
        voiceVolume = AudioPlayer.shared.voiceVolume
        
        hapticToggle = AudioPlayer.shared.hapticToggle
        textSpeed = GlobalData.shared.textSpeed
        
        teamRestricted = GlobalData.shared.teamLimit
        artifactUse = GlobalData.shared.artifactUse
        
        savedFighters = GlobalData.shared.savedFighters
        
        userProgress = GlobalData.shared.userProgress
    }
}
