//
//  TextFitter.swift
//  Witchery
//
//  Created by Janice Hablützel on 01.02.22.
//

import SwiftUI

struct TextFitter {
    static func getFittedText(text: String, geoWidth: CGFloat) -> String {
        let cutOff: Int = Int(geoWidth/6)
        var textArray: [String] = []
        
        if text.count < cutOff {
            return text
        }
        
        textArray = createTextArray(text: text, cutOff: cutOff)
        
        var needsRedo: Int = finalizeText(textArray: &textArray)
        
        while needsRedo > 0 {
            var txt: String = ""
            for index in needsRedo ..< textArray.count {
                txt += textArray[index]
            }
            
            let array = createTextArray(text: txt, cutOff: cutOff)
            for k in needsRedo ..< textArray.count {
                textArray[k] = array[k - needsRedo]
            }
            
            needsRedo = finalizeText(textArray: &textArray)
        }
        
        var finalText: String = ""
        for line in textArray {
            finalText += line + "\n"
        }
        
        return String(finalText.dropLast())
    }
    
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
                
                if textLine.first == " " {
                    textArray[index] = String(textArray[index].dropFirst())
                }
            }
        }
        
        return 0
    }
}
