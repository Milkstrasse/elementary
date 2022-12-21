//
//  TeamManager.swift
//  Elementary
//
//  Created by Janice Hablützel on 10.11.22.
//

/// Manages teams of fighters.
struct TeamManager {
    /// Selects random fighters to create a team.
    static func selectRandom(opponents: [Fighter?]) -> [Fighter] {
        //let maxSize: Int = min(4, GlobalData.shared.fighters.count)
        let maxSize: Int = 4
        
        var fighters: [Fighter] = []
        
        var rndmFighters: [Int] = []
        switch GlobalData.shared.teamLimit {
        case 1: //only unique fighters on one team
            var fighterSet = Set<Int>()
            
            while fighterSet.count < maxSize {
                fighterSet.insert(Int.random(in: 0 ..< GlobalData.shared.fighters.count))
            }
            
            rndmFighters = Array(fighterSet)
        case 2: //only unique fighters on both teams
            while fighters.count < maxSize {
                let rndmFighter: Fighter = GlobalData.shared.getRandomFighter()
                
                var fighterFound: Bool = false
                for fighter in fighters {
                    if fighter.name == rndmFighter.name {
                        fighterFound = true
                        break
                    }
                }
                
                if !fighterFound {
                    for opponent in opponents {
                        if opponent?.name == rndmFighter.name {
                            fighterFound = true
                            break
                        }
                    }
                    
                    if !fighterFound {
                        fighters.append(rndmFighter)
                    }
                }
            }
        default: //no restrictions
            while rndmFighters.count < maxSize {
                rndmFighters.append(Int.random(in: 0 ..< GlobalData.shared.fighters.count))
            }
        }
        
        var rndmArtifacts: [Int] = []
        switch GlobalData.shared.artifactUse {
        case 0:
            while rndmArtifacts.count < maxSize {
                rndmArtifacts.append(Int.random(in: 0 ..< Artifacts.allCases.count))
            }
        case 1:
            var artifactSet = Set<Int>()
            
            while artifactSet.count < maxSize {
                artifactSet.insert(Int.random(in: 0 ..< Artifacts.allCases.count))
            }
            rndmArtifacts = Array(artifactSet)
        default:
            break
        }
        
        for index in 0 ..< maxSize {
            if !rndmFighters.isEmpty {
                fighters.append(SavedFighterData(fighter: GlobalData.shared.fighters[rndmFighters[index]]).toFighter(images: GlobalData.shared.fighters[rndmFighters[index]].images)) //make copy
            }
            
            if GlobalData.shared.artifactUse != 2 {
                fighters[index].setArtifact(artifact: rndmArtifacts[index])
            }
        }
        
        return fighters
    }
    
    /// Checks if selected teams contains atleast one fighter.
    /// - Parameter array: The selection of fighters to check
    /// - Returns: Returns wether atleast one fighter was selected or not
    static func isArrayEmpty(array: [Fighter?]) -> Bool {
        for fighter in array {
            if fighter != nil {
                return false
            }
        }
        
        return true
    }
    
    /// Reset each fighter in both teams to make them ready for a fight.
    static func resetFighters(topFighters: [Fighter?], bottomFighters: [Fighter?]) {
        for fighter in topFighters {
            fighter?.reset()
        }
        
        for fighter in bottomFighters {
            fighter?.reset()
        }
    }
}
