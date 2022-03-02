//
//  Extensions.swift
//  Witchery
//
//  Created by Janice Hablützel on 06.01.22.
//

import SwiftUI

//https://www.hackingwithswift.com/example-code/language/how-to-remove-duplicate-items-from-an-array
extension Array where Element: Hashable {
    /// Removes duplicates in an array. Example: Remove duplicate spells.
    /// - Returns: Returns an array without duplicates
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}

extension Image {
    /// Creates image from png saved in folder.
    /// - Parameter fileName: The name of the png image
    init(fileName: String) {
        if let mainURL = SaveLogic.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = URL.init(fileURLWithPath: mainURL.path + "/mods/assets/" + fileName + ".png")
            if SaveLogic.fileManager.fileExists(atPath: url.path) {
                self.init(uiImage: UIImage(contentsOfFile: url.path) ?? UIImage())
            } else if let url = Bundle.main.url(forResource: fileName, withExtension: "png", subdirectory: "Assets") {
                self.init(uiImage: UIImage(contentsOfFile: url.path) ?? UIImage())
            } else {
                self.init(uiImage: UIImage())
            }
        } else {
            self.init(uiImage: UIImage())
        }
    }
}
