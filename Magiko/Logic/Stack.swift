//
//  Stack.swift
//  Magiko
//
//  Created by Janice Hablützel on 07.01.22.
//

struct MoveStack {
    private var items: [Move] = []
    
    mutating func push(move: Move) {
        items.insert(move, at: 0)
    }
    
    mutating func pop() -> Move {
        return items.removeFirst()
    }
}
