//
//  Move.swift
//  Elementary
//
//  Created by Janice Hablützel on 17.01.22.
//

/// A move is an action made by a fighter. Can either be a swap with another fighter or a spell.
struct Move {
    private let source: Fighter
    let index: Int
    
    var spell: Spell
    let type: MoveType
    
    /// Creates a move.
    /// - Parameters:
    ///   - source: The fighter that made the move
    ///   - index: The target for a swap or the spell index
    ///   - spell: The spell used to make the move, set to placeholder spell f the move is a swap
    ///   - type: The type of move
    init(source: Fighter, index: Int, spell: Spell, type: MoveType) {
        self.source = source
        self.index = index
        
        self.spell = spell
        self.type = type
    }
    
    /// Mana is subtracted from the spell.
    /// - Parameter amount: The amount of mana used on the spell
    mutating func useSpell(amount: Int) {
        if spell.name == "unknownSpell" { //placeholder spell -> no need to increase counter
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

enum MoveType {
    case swap
    case spell
    case hex
    case artifact
    case special
}
