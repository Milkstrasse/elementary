//
//  Extensions.swift
//  Elementary
//
//  Created by Janice Hablützel on 06.01.22.
//

import SwiftUI

extension Image {
    /// Creates image from png saved in folder.
    /// - Parameter fileName: The name of the png image
    init(fileName: String) {
        if let mainURL = SaveData.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = URL.init(fileURLWithPath: mainURL.path + "/mods/assets/" + fileName + ".png")
            if SaveData.fileManager.fileExists(atPath: url.path) {
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

extension UIImage {
    /// Creates image from png saved in folder.
    /// - Parameter fileName: The name of the png image
    convenience init?(fileName: String) {
        if let mainURL = SaveData.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = URL.init(fileURLWithPath: mainURL.path + "/mods/assets/" + fileName + ".png")
            if SaveData.fileManager.fileExists(atPath: url.path) {
                self.init(contentsOfFile: url.path)
            } else if let url = Bundle.main.url(forResource: fileName, withExtension: "png", subdirectory: "Assets") {
                self.init(contentsOfFile: url.path)
            } else {
                self.init()
            }
        } else {
            self.init()
        }
    }
}

//https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values
extension Color {
    /// Creates a color from a hex string.
    /// - Parameter hex: Hex code as a string
    init(hex: String) {
        let hexString:String = String(hex.dropFirst())

        if ((hexString.count) != 6) {
            self.init(red: 0, green: 0, blue: 0)
        }

        var rgbValue:UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red: CGFloat = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green: CGFloat = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue: CGFloat = CGFloat((rgbValue & 0x0000FF)) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

extension FileManager {
    /// Checks if directory exists.
    /// - Parameter url: The url of the directory
    /// - Returns: Return wether directory exists  or not
    func directoryExists(atUrl url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = self.fileExists(atPath: url.path, isDirectory:&isDirectory)
        return exists && isDirectory.boolValue
    }
}
