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
    
    /// Checks how a stat was changed.
    /// - Parameters:
    ///   - index: The index of the stat
    ///   - value: The new value of the stat
    /// - Returns: Returns +1 if stat has increased and -1 if stat has decreased
    func compareValues(index: Int, value: Int) -> Int {
        switch index {
        case 1:
            if attack > value {
                return -1
            } else if attack < value {
                return 1
            } else {
                return 0
            }
        case 2:
            if defense > value {
                return -1
            } else if defense < value {
                return 1
            } else {
                return 0
            }
        case 3:
            if agility > value {
                return -1
            } else if agility < value {
                return 1
            } else {
                return 0
            }
        case 4:
            if precision > value {
                return -1
            } else if precision < value {
                return 1
            } else {
                return 0
            }
        case 5:
            if resistance > value {
                return -1
            } else if resistance < value {
                return 1
            } else {
                return 0
            }
        default:
            if health > value {
                return -1
            } else if health < value {
                return 1
            } else {
                return 0
            }
        }
    }
}
