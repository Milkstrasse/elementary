//
//  SaveData.swift
//  Witchery
//
//  Created by Janice Hablützel on 24.02.22.
//

struct SaveData: Codable {
    let langCode: String
    
    let musicVolume: Float
    let soundVolume: Float
    let voiceVolume: Float
    
    let hapticToggle: Bool
    let textSpeed: Int
    
    let teamRestricted: Bool
    let artifactUse: Int
    
    let savedWitches: [SavedWitchData]
}
