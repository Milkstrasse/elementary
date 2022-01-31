//
//  Artifacts.swift
//  Witchery
//
//  Created by Janice Hablützel on 12.01.22.
//

struct Artifact {
    let name: String
    let description: String
}

enum Artifacts: String, CaseIterable {
    case noArtifact
    case amulet
    case book
    case charm
    case cornucopia
    case corset
    case crystal
    case grimoire
    case mask
    case mirror
    case ring
    case talaria
    case talisman
    case wand
    case lastWill
    
    func getArtifact() -> Artifact {
        return Artifact(name: self.rawValue, description: self.rawValue + "Descr")
    }
}
