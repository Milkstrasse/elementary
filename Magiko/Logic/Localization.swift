//
//  Localization.swift
//  Magiko
//
//  Created by Janice Hablützel on 08.01.22.
//

import Foundation

class Localization {
    static let shared: Localization = Localization()
    
    var languages: [String] = []
    var translations: Dictionary<String, String> = [:]
    var currentLang: String = ""
    
    func getLanguages() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Languages") {
            for url in urls {
                languages.append(url.deletingPathExtension().lastPathComponent)
            }
        }
    }
    
    func loadLanguage(language: String) {
        if let url = Bundle.main.url(forResource: language, withExtension: "json", subdirectory: "Languages") {
            do {
                let data = try Data(contentsOf: url)
                translations = try JSONDecoder().decode([String:String].self, from: data)
                
                currentLang = language
            } catch {
                print("error: \(error)")
            }
            
            print("loaded: \(translations.count) strings")
        }
    }
    
    func getTranslation(key: String) -> String {
        return translations[key] ?? key
    }
}
