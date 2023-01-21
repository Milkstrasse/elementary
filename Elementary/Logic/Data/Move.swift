//
//  Move.swift
//  Elementary
//
//  Created by Janice Hablützel on 17.01.22.
//

/// A move is an action made by a fighter. Can either be a swap with another fighter or a spell.
struct Move {
    let source: Int
    let index: Int
    var target: Int
    
    var spell: Int
    let type: MoveType
    
    /// Creates a move.
    /// - Parameters:
    ///   - source: The fighter that made the move
    ///   - index: The target for a swap or the spell index
    ///   - spell: The spell used to make the move, set to placeholder spell f the move is a swap
    ///   - type: The type of move
    init(source: Int, index: Int, target: Int, spell: Int, type: MoveType) {
        self.source = source
        self.index = index
        self.target = target
        
        self.spell = spell
        self.type = type
    }
    
    /// Mana is subtracted from the spell.
    /// - Parameters:
    ///   - fighter: The fighter using the spell
    ///   - singleMode: Indicates the category of the spell
    mutating func useSpell(fighter: Fighter, singleMode: Bool) {
        if singleMode {
            if fighter.singleSpells[spell].name == "unknownSpell" { //placeholder spell -> no need to increase counter
                return
            }
            
            fighter.singleSpells[spell].useCounter += fighter.manaUse
        } else {
            if fighter.multiSpells[spell].name == "unknownSpell" { //placeholder spell -> no need to increase counter
                return
            }
            
            fighter.multiSpells[spell].useCounter += fighter.manaUse
        }
    }
}

/// The type of move a player can make.
enum MoveType: String {
    case swap
    case spell
    case hex
    case artifact
    case special
}
