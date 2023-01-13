//
//  Move.swift
//  Elementary
//
//  Created by Janice Hablützel on 17.01.22.
//

/// A move is an action made by a fighter. Can either be a swap with another fighter or a spell.
struct Move {
    let source: Fighter
    let index: Int
    var target: Fighter
    
    var spell: Int
    let type: MoveType
    
    /// Creates a move.
    /// - Parameters:
    ///   - source: The fighter that made the move
    ///   - index: The target for a swap or the spell index
    ///   - spell: The spell used to make the move, set to placeholder spell f the move is a swap
    ///   - type: The type of move
    init(source: Fighter, index: Int, target: Fighter, spell: Int, type: MoveType) {
        self.source = source
        self.index = index
        self.target = target
        
        self.spell = spell
        self.type = type
    }
    
    /// Mana is subtracted from the spell.
    /// - Parameter amount: The amount of mana used on the spell
    /// - Parameter singleMode: Indicates the category of the spell
    mutating func useSpell(amount: Int, singleMode: Bool) {
        if singleMode {
            if source.singleSpells[spell].name == "unknownSpell" { //placeholder spell -> no need to increase counter
                return
            }
            
            source.singleSpells[spell].useCounter += amount
        } else {
            if source.multiSpells[spell].name == "unknownSpell" { //placeholder spell -> no need to increase counter
                return
            }
            
            source.multiSpells[spell].useCounter += amount
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
