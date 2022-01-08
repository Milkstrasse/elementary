//
//  Element.swift
//  Magiko
//
//  Created by Janice Hablützel on 08.01.22.
//

struct Element: Decodable {
    let name: String
    let color: String
    
    let strengths: [String]
    let weaknesses: [String]
    
    init() {
        name = "Aether"
        color = "#929292"
        strengths = []
        weaknesses = []
    }
    
    func hasAdvantage(element: Element) -> Bool {
        return strengths.contains(element.name)
    }
    
    func hasDisdvantage(element: Element) -> Bool {
        return weaknesses.contains(element.name)
    }
}
