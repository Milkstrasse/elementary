//
//  Extensions.swift
//  Witchery
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
