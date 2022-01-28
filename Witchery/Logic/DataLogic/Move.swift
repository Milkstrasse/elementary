//
//  Move.swift
//  Witchery
//
//  Created by Janice Hablützel on 17.01.22.
//

struct Move {
    let source: Witch
    let target: Int
    
    var spell: Spell
    
    init(source: Witch, target: Int = -1, spell: Spell = Spell()) {
        self.source = source
        self.target = target
        
        self.spell = spell
    }
    
    mutating func useSpell(amount: Int) {
        if spell == Spell() {
            return
        }
        
        var spellIndex: Int = 0
        for sourceSpell in source.spells {
            if sourceSpell == spell {
                break
            }
            
            spellIndex += 1
        }
        spell.useCounter += amount
        source.spells[spellIndex] = spell
    }
}
