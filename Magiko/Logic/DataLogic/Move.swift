//
//  Move.swift
//  Magiko
//
//  Created by Janice Hablützel on 17.01.22.
//

struct Move {
    let source: Fighter
    let target: Int
    
    var skill: Skill
    
    init(source: Fighter, target: Int = -1, skill: Skill = Skill()) {
        self.source = source
        self.target = target
        
        self.skill = skill
    }
    
    mutating func useSkill(amount: Int) {
        if skill == Skill() {
            return
        }
        
        var skillIndex: Int = 0
        for sourceSkill in source.skills {
            if sourceSkill == skill {
                break
            }
            
            skillIndex += 1
        }
        skill.useCounter += amount
        source.skills[skillIndex] = skill
    }
}
