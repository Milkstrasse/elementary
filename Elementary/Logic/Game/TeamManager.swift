//
//  TeamManager.swift
//  Elementary
//
//  Created by Janice Hablützel on 10.11.22.
//

/// Manages teams of fighters.
struct TeamManager {
    /// Selects random fighters to create a team.
    /// - Parameter opponents: The opposing fighters
    /// - Returns: Returns a team consisting of random fighters
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
        case 0: //random artifacts
            while rndmArtifacts.count < maxSize {
                rndmArtifacts.append(Int.random(in: 0 ..< Artifacts.allCases.count))
            }
        case 1: //unique artifacts
            var artifactSet = Set<Int>()
            
            while artifactSet.count < maxSize {
                artifactSet.insert(Int.random(in: 0 ..< Artifacts.allCases.count))
            }
            rndmArtifacts = Array(artifactSet)
        default: //no artifacts
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
    
    /// Checks if team fulfills all requirements to fight.
    ///   - Parameter fighters: The fighters of the team
    /// - Returns: Returns if team fulfills all fight requirements
    static func isTeamValid(fighters: [Fighter?]) -> Bool {
        var counter: Int = 0
        for fighter in fighters {
            if fighter != nil {
                counter += 1
            }
        }
        
        return counter > 0 && counter <= 4
    }
    
    /// Resets each fighter in both teams to make them ready for a fight.
    /// - Parameters:
    ///   - topFighters: The team of player 1
    ///   - bottomFighters: The team of player 2
    static func resetFighters(topFighters: [Fighter?], bottomFighters: [Fighter?]) {
        for fighter in topFighters {
            fighter?.reset()
        }
        
        for fighter in bottomFighters {
            fighter?.reset()
        }
    }
    
    /// Returns a random fighter.
    /// - Parameters:
    ///   - fighters: The fighters of the own team
    ///   - opponents: The fighters of the other team
    /// - Returns: Returns a random fighter
    static func getRandomFighter(fighters: [Fighter?], opponents: [Fighter?]) -> Fighter {
        var rndmFighter: Fighter = GlobalData.shared.fighters[0]
        var uniqueNotFound: Bool = true
        
        switch GlobalData.shared.teamLimit {
        case 1: //only unique fighters on one team
            while uniqueNotFound {
                rndmFighter = GlobalData.shared.getRandomFighter()
                var fighterFound: Bool = false
                
                for fighter in fighters {
                    if fighter?.name == rndmFighter.name {
                        fighterFound = true
                        break
                    }
                }
                
                uniqueNotFound = fighterFound
            }
        case 2: //only unique fighters on both teams
            while uniqueNotFound {
                rndmFighter = GlobalData.shared.getRandomFighter()
                var fighterFound: Bool = false
                
                for fighter in fighters {
                    if fighter?.name == rndmFighter.name {
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
                }
                
                uniqueNotFound = fighterFound
            }
        default: //no restrictions
            rndmFighter  = GlobalData.shared.getRandomFighter()
        }
        
        uniqueNotFound = true
        
        if GlobalData.shared.artifactUse != 2 {
            if GlobalData.shared.artifactUse == 1 { //unique artifacts
                var rndmArtifact: Int
                var artifactFound: Bool = false
                
                while uniqueNotFound {
                    rndmArtifact = Int.random(in: 0 ..< Artifacts.allCases.count)
                    
                    for fighter in fighters {
                        if fighter?.getArtifact().name == Artifacts.allCases[rndmArtifact].rawValue {
                            artifactFound = true
                            break
                        }
                    }
                    
                    uniqueNotFound = artifactFound
                }
                
                rndmFighter.setArtifact(artifact: Int.random(in: 0 ..< Artifacts.allCases.count))
            } else { //unique artifacts
                rndmFighter.setArtifact(artifact: Int.random(in: 0 ..< Artifacts.allCases.count))
            }
        }
        
        return rndmFighter
    }
}
