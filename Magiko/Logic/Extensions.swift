//
//  Extensions.swift
//  Magiko
//
//  Created by Janice Hablützel on 06.01.22.
//

import SwiftUI

//https://www.hackingwithswift.com/example-code/language/how-to-remove-duplicate-items-from-an-array
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}

//https://stackoverflow.com/questions/56874133/use-hex-color-in-swiftui
//https://developer.apple.com/forums/thread/120694
extension Color {
    init(hex: String) {
        var str = "0x"
        str += String(hex[hex.index(after: hex.startIndex)...])

        let hexUINT: UInt32 = UInt32(Float64(str) ?? 0xCC6699)
        
        self.init(
            .sRGB,
            red: Double((hexUINT >> 16) & 0xff) / 255,
            green: Double((hexUINT >> 08) & 0xff) / 255,
            blue: Double((hexUINT >> 00) & 0xff) / 255,
            opacity: 1
        )
    }
}
