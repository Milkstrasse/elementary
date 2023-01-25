//
//  General.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.08.22.
//

import SwiftUI

struct General {
    static let outerPadding: CGFloat = 15
    static let innerPadding: CGFloat = 10

    static let borderWidth: CGFloat = 1

    static let largeHeight: CGFloat = 50
    static let smallHeight: CGFloat = 40

    static let largeFont: CGFloat = 20
    static let mediumFont: CGFloat = 16
    static let smallFont: CGFloat = 14
    
    /// Converts a symbol to the correct display format.
    ///  - Parameter int: Symbol in String format
    /// - Returns: Returns the symbol in the correct format
    static func createSymbol(string: String) -> String {
        let icon: UInt16 = UInt16(Float64(string) ?? 0xf52d)
        return createSymbol(int: icon)
    }
    
    /// Converts a symbol to the correct display format.
    ///  - Parameter int: Symbol in UInt16 format
    /// - Returns: Returns the symbol in the correct format
    static func createSymbol(int: UInt16) -> String {
        return String(Character(UnicodeScalar(int) ?? "\u{2718}"))
    }
}
