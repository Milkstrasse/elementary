//
//  StatusModifier.swift
//  Magiko
//
//  Created by Janice Hablützel on 10.01.22.
//

struct StatusModifier {
    static let shared: StatusModifier = StatusModifier()
    
    func modifyStatus(attacker: Fighter, defender: Fighter, skill: SubSkill, skillElement: String, skillName: String?) -> String {
        var text: String = ""
        
        if skill.range == 0 && attacker.status.element.name == States.fine.getStatus().element.name {
            let chance: Int = Int.random(in: 0 ..< 100)
            if chance < skill.statusChance {
                attacker.status = States.fine.getStatus(element: skillElement)
                text = attacker.name + " became " + attacker.status.name + ".\n"
            } else {
                text = "It failed.\n"
            }
            
            if skillName != nil {
                text = attacker.name + " used " + skillName! + ". " + text
            }
        } else if skill.range == 1 && defender.status.element.name == States.fine.getStatus().element.name {
            let chance: Int = Int.random(in: 0 ..< 100)
            if chance < skill.statusChance {
                defender.status = States.fine.getStatus(element: skillElement)
                text = defender.name + " became " + defender.status.name + ".\n"
            } else {
                text = "It failed.\n"
            }
            
            if skillName != nil {
                text = attacker.name + " used " + skillName! + ". " + text
            }
        }
        
        return text
    }
}
