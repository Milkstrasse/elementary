//
//  Move.swift
//  Witchery
//
//  Created by Janice Hablützel on 17.01.22.
//

/// A move is an action made by a witch. Can either be a swap with another witch or a spell.
struct Move {
    let source: Witch
    let target: Int
    
    var spell: Spell
    
    /// Creates a move.
    /// - Parameters:
    ///   - source: The witch that made the move
    ///   - target: The target for a swap, set to -1 if the move is not a swap
    ///   - spell: The spell used to make the move, set to placeholder spell f the move is a swap
    init(source: Witch, target: Int = -1, spell: Spell = Spell()) {
        self.source = source
        self.target = target
        
        self.spell = spell
    }
    
    /// Mana is subtracted from the spell.
    /// - Parameter amount: The amount of mana used on the spell
    mutating func useSpell(amount: Int) {
        if spell == Spell() { //hints that move was a swap -> no need to increase counter
            return
        }
        
        //find index of spell since spells cannot be mutated directly
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
