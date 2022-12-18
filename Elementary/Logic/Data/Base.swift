//
//  Base.swift
//  Elementary
//
//  Created by Janice Hablützel on 18.12.22.
//

/// Contains all base stat values of a fighter.
struct Base: Codable {
    let health: Int
    let attack: Int
    let defense: Int
    let agility: Int
    let precision: Int
    let resistance: Int
}
