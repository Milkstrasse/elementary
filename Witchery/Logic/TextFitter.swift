//
//  TextFitter.swift
//  Witchery
//
//  Created by Janice Hablützel on 01.02.22.
//

import SwiftUI

/// Divides  strings to make them fit a text box.
struct TextFitter {
    /// Divides strings to make them fit a text box while avoiding splitting up words.
    /// - Parameters:
    ///   - text: The text that should fit
    ///   - geoWidth: The width of the text box
    /// - Returns: Returns a text that will fit the text box
    static func getFittedText(text: String, geoWidth: CGFloat) -> String {
        let cutOff: Int = Int(geoWidth/6)
        var textArray: [String] = []
        
        if text.count < cutOff {
            return text
        }
        
        textArray = createTextArray(text: text, cutOff: cutOff)
        
        var needsRedo: Int = finalizeText(textArray: &textArray)
        
        while needsRedo > 0 { //word has been split up -> redo
            var txt: String = ""
            for index in needsRedo ..< textArray.count {
                txt += textArray[index]
            }
            
            let array = createTextArray(text: txt, cutOff: cutOff)
            
            for k in needsRedo ..< textArray.count {
                textArray[k] = array[k - needsRedo]
            }
            if needsRedo + array.count > textArray.count {
                textArray.append(array.last!)
            }
            
            needsRedo = finalizeText(textArray: &textArray)
        }
        
        var finalText: String = ""
        for line in textArray {
            finalText += line + "\n"
        }
        
        return String(finalText.dropLast())
    }
    
    /// Creates first attempt at dividing the text to fit a certain width.
    /// - Parameters:
    ///   - text: The text that should fit
    ///   - cutOff: The max length of a string
    /// - Returns: Returns the text divided into an array
    static func createTextArray(text: String, cutOff: Int) -> [String] {
        var array: [String] = []
        
        var offset: Int = cutOff
        var startIndex: String.Index = text.index(text.startIndex, offsetBy: offset - cutOff)
        
        while offset < text.count {
            startIndex = text.index(text.startIndex, offsetBy: offset - cutOff)
            let endIndex: String.Index = text.index(startIndex, offsetBy: cutOff)
            array.append(String(text[startIndex ..< endIndex]))
            
            offset += cutOff
        }
        
        startIndex = text.index(text.startIndex, offsetBy: offset - cutOff)
        array.append(String(text[startIndex ..< text.endIndex]))
        
        return array
    }
    
    /// Cleans up text and checks for split words.
    /// - Parameter textArray: The array containing the raw text
    /// - Returns: Returns the index where word has been split
    static func finalizeText(textArray: inout [String]) -> Int {
        for index in textArray.indices {
            let textLine: String = textArray[index]
            if textLine.first == " " {
                textArray[index] = String(textArray[index].dropFirst())
            } else if index > 0 {
                if textArray[index - 1].last != " " {
                    var txt: String = ""
                    let temp: [String] = textArray[index - 1].components(separatedBy: " ")
                    for i in 0 ..< temp.count - 1 {
                        txt.append(temp[i] + " ")
                    }
                    
                    textArray[index - 1] = txt
                    textArray[index] = temp.last! + textArray[index]
                    
                    return index
                }
            }
        }
        
        return 0
    }
}
