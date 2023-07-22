//
//  Artifacts.swift
//  Elementary
//
//  Created by Janice Hablützel on 12.01.22.
//

/// Artifacts grant a fighter all kind of different effects during a fight.
struct Artifact {
    let name: String
    let description: String
}

/// List of all possible artifacts
enum Artifacts: String, CaseIterable {
    case noArtifact
    case amulet
    case armor
    case boots
    case charm
    case cornucopia
    case crystal
    case fetish
    case grimoire
    case hat
    case helmet
    case incense
    case mask
    case mirror
    case potion
    case ring
    case sandals
    case shield
    case sword
    case talisman
    case thread
    case wand
    case book
    case grail
    case apple
    
    /// Creates and returns an artifact.
    /// - Returns: Returns an artifact
    func getArtifact() -> Artifact {
        return Artifact(name: self.rawValue, description: self.rawValue + "Descr")
    }
}
