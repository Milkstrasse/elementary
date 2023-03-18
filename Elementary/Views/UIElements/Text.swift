//
//  Text.swift
//  Elementary
//
//  Created by Janice Hablützel on 20.08.22.
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
        var counter: Int = text.count //limit iterations
        
        let cutOff: Int = Int(geoWidth/6)
        var textArray: [String] = []
        
        if text.count < cutOff {
            return text
        }
        
        textArray = createTextArray(text: text, cutOff: cutOff)
        
        var needsRedo: Int = finalizeText(textArray: &textArray)
        
        while needsRedo > 0 && counter >= 0 { //word has been split up -> redo
            counter -= 1
            
            var txt: String = ""
            for index in needsRedo ..< textArray.count {
                txt += textArray[index]
            }
            
            let array: [String] = createTextArray(text: txt, cutOff: cutOff)
            
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
            if index > 0 {
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
        
        for index in textArray.indices {
            let textLine: String = textArray[index]
            if textLine.first == " " {
                textArray[index] = String(textArray[index].dropFirst())
            }
        }
        
        return 0
    }
}

struct CustomText: View {
    var text: String
    var fontColor: Color
    var fontSize: CGFloat
    
    var lineLimit: Int?
    var isBold: Bool
    
    var alignment: HorizontalAlignment
    
    var textArray: [[String]]
    
    /// Creates a text with custom fonts.
    /// - Parameters:
    ///   - text: The string to display
    ///   - fontColor: The color of the text
    ///   - fontSize: The size of the text
    ///   - isBold: Indicates whether the text is bold or not
    ///   - alignment: The alignment of the text
    init(text: String, fontColor: Color = Color("Text"), fontSize: CGFloat, isBold: Bool = false, alignment: HorizontalAlignment = .leading) {
        self.text = text
        self.fontColor = fontColor
        self.fontSize = fontSize
        
        textArray = []
        let lines: [String] = text.components(separatedBy: "\n")
        for line in lines {
            textArray.append(line.components(separatedBy: "**"))
        }
        
        self.isBold = isBold
        
        self.alignment = alignment
    }
    
    /// Returns wether the word should be bold or not.
    /// - Parameter index: The current index of the word in a line
    /// - Returns: Returns wether the word should be bold or not
    func isBold(index: Int) -> Bool {
        if isBold {
            return true
        }
        
        return index%2 != 0
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: 0) {
            ForEach(textArray.indices, id: \.self) { line in
                HStack(spacing: 0) {
                    ForEach(textArray[line].indices, id: \.self) { index in
                        Text(textArray[line][index]).font(.custom(isBold(index: index) ? "RobotoCondensed-Bold" : "RobotoCondensed-Regular", size: fontSize)).fixedSize().foregroundColor(fontColor).lineLimit(lineLimit)
                    }
                }
            }
        }
    }
}

struct Text_Previews: PreviewProvider {
    static var previews: some View {
        CustomText(text: "Hello", fontSize: General.smallFont)
    }
}
