//
//  MissionManager.swift
//  Elementary
//
//  Created by Janice Hablützel on 05.07.23.
//

import Foundation

struct MissionManager {
    var quests: [Mission]
    var milestones: [Mission]
    
    var unclaimedRewards: Int
    
    init() {
        quests = []
        milestones = []
        
        unclaimedRewards = 0
    }
    
    mutating func addQuests(userProgress: UserProgress) {
        var tempRequirements: [NSPredicate] = []
        for n in 1 ... 5 {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "dailyFightCounter", NSNumber(value: n)))
        }
        quests.append(Mission(title: "fightMission", params: ["5"], requirements: tempRequirements, isSpecial: false, reward: 5))
        
        quests.append(Mission(title: "winUsingMission", params: [userProgress.getDailyElement().name], requirements: [NSPredicate(format: "%K == %@", "dailyElementWin", NSNumber(value: true))], isSpecial: false, reward: 10))
        
        tempRequirements = []
        for n in 1 ... 2 {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "dailyWinCounter", NSNumber(value: n)))
        }
        quests.append(Mission(title: "winMission", params: ["2"], requirements: tempRequirements, isSpecial: false, reward: 10))
        
        quests.append(Mission(title: "useArtifactMission", requirements: [NSPredicate(format: "%K == %@", "dailyArtifactUsed", NSNumber(value: true))], isSpecial: false, reward: 5))
    }
    
    mutating func addMilestones(userProgress: UserProgress) {
        var tempRequirements: [NSPredicate] = []
        for n in 1 ... 25 {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "fightCounter", NSNumber(value: n)))
        }
        milestones.append(Mission(title: "fightMission", params: ["25"], requirements: tempRequirements, isSpecial: true, reward: 25))
        
        for n in 26 ... 50 {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "fightCounter", NSNumber(value: n)))
        }
        milestones.append(Mission(title: "fightMission", params: ["50"], requirements: tempRequirements, isSpecial: true, reward: 50))
        
        for n in 51 ... 100 {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "fightCounter", NSNumber(value: n)))
        }
        milestones.append(Mission(title: "fightMission", params: ["100"], requirements: tempRequirements, isSpecial: true, reward: 100))
        
        tempRequirements = []
        for n in 1 ... 5 {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "winStreak", NSNumber(value: n)))
        }
        milestones.append(Mission(title: "winStreakMission", params: ["5"], requirements: tempRequirements, isSpecial: true, reward: 35))
        
        for n in 6 ... 10 {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "winStreak", NSNumber(value: n)))
        }
        milestones.append(Mission(title: "winStreakMission", params: ["10"], requirements: tempRequirements, isSpecial: true, reward: 70))
        
        for n in 11 ... 25 {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "winStreak", NSNumber(value: n)))
        }
        milestones.append(Mission(title: "winStreakMission", params: ["25"], requirements: tempRequirements, isSpecial: true, reward: 175))
        
        milestones.append(Mission(title: "winAliveMission", requirements: [NSPredicate(format: "%K == %@", "winAllAlive", NSNumber(value: true))], isSpecial: false, reward: 20))
        
        tempRequirements = []
        for n in 1 ... userProgress.weatherUses.count {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "weatherCounter", NSNumber(value: n)))
        }
        milestones.append(Mission(title: "weatherMission", requirements: tempRequirements, isSpecial: false, reward: userProgress.weatherUses.count * 5))
        
        tempRequirements = []
        for n in 1 ... userProgress.hexUses.count {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "hexCounter", NSNumber(value: n)))
        }
        milestones.append(Mission(title: "hexMission", requirements: tempRequirements, isSpecial: false, reward: userProgress.hexUses.count * 10))
        
        tempRequirements = []
        for n in 1 ... userProgress.artifactsUses.count {
            tempRequirements.append(NSPredicate(format: "%K >= %@", "artifactCounter", NSNumber(value: n)))
        }
        milestones.append(Mission(title: "artifactMission", requirements: tempRequirements, isSpecial: false, reward: userProgress.artifactsUses.count * 5))
    }
    
    mutating func checkMissions(value: UserProgress) {
        unclaimedRewards = 0
        for index in quests.indices {
            quests[index].updateCompletion(value: value)
            if quests[index].completion >= 100 && !value.questCollected[index] {
                unclaimedRewards += 1
            }
        }
        
        for index in milestones.indices {
            milestones[index].updateCompletion(value: value)
            if milestones[index].completion >= 100 && !value.milestoneCollected[index] {
                unclaimedRewards += 1
            }
        }
    }
    
    mutating func resetDaily(userProgress: UserProgress) {
        quests = []
        addQuests(userProgress: userProgress)
    }
    
    mutating func resetAll(userProgress: UserProgress) {
        quests = []
        addQuests(userProgress: userProgress)
        
        milestones = []
        addMilestones(userProgress: userProgress)
    }
}

struct Mission {
    let title: String
    let params: [String]
    let requirements: [NSPredicate]
    var completion: Int
    var isClaimed: Bool
    var isSpecial: Bool
    
    let reward: Int
    
    init(title: String, params: [String] = [], requirements: [NSPredicate], isSpecial: Bool, reward: Int) {
        self.title = title
        self.params = params
        self.requirements = requirements
        
        completion = 0
        isClaimed = false
        
        self.isSpecial = isSpecial
        
        self.reward = reward
    }
    
    mutating func updateCompletion(value: UserProgress) {
        if completion >= 100 {
            return
        }
        
        if !isSpecial {
            var counter: Float = 0
            for requirement in requirements {
                if requirementIsMet(requirement: requirement,value: value) {
                    counter += 1
                }
            }
            
            completion = Int(roundf(counter/Float(requirements.count) * 100))
        } else {
            var checkValue: Int = requirements.count
            var check: Bool = requirementIsMet(requirement: requirements[checkValue - 1], value: value)
            
            if !check {
                check = requirementIsMet(requirement: requirements[0], value: value)
                
                if check {
                    var lastTrueValue: Int = 1
                    var lastFalseValue: Int = requirements.count
                    
                    while true {
                        checkValue = (lastTrueValue + lastFalseValue)/2
                        
                        if checkValue == lastTrueValue {
                            break
                        }
                        
                        check = requirementIsMet(requirement: requirements[checkValue - 1], value: value)
                        
                        if check {
                            lastTrueValue = checkValue
                        } else {
                            lastFalseValue = checkValue
                        }
                    }
                } else {
                    checkValue = 0
                }
            }
            
            completion = Int(roundf(Float(checkValue)/Float(requirements.count) * 100))
        }
    }
    
    func requirementIsMet(requirement: NSPredicate, value: NSObject) -> Bool {
        return requirement.evaluate(with: value)
    }
}
