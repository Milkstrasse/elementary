//
//  Localization.swift
//  Elementary
//
//  Created by Janice Hablützel on 08.01.22.
//

import Foundation

/// Stores translations for a specific language and the names of all available languages.
class Localization {
    static let shared: Localization = Localization()
    
    var languages: [String] = []
    var translations: Dictionary<String, String> = [:]
    var currentLang: String = ""
    
    /// Gets name of each language file in folder.
    func getLanguages() {
        if let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "Languages") {
            for url in urls {
                languages.append(url.deletingPathExtension().lastPathComponent)
            }
        }
    }
    
    /// Loads all translations of an language file.
    /// - Parameter language: The name of the language file
    func loadLanguage(language: String) {
        if let url = Bundle.main.url(forResource: language, withExtension: "json", subdirectory: "Languages") {
            do {
                let data = try Data(contentsOf: url)
                translations = try JSONDecoder().decode([String:String].self, from: data)
                
                currentLang = language
            } catch {
                print("error: \(error)")
            }
            
            //add found translations to existing ones and override old value with new
            translations.merge(GlobalData.shared.addTranslations(language: language)) {(_, new) in new}
            
            print("loaded: \(translations.count) strings")
        }
    }
    
    /// Loads all translations of the current language file.
    func loadCurrentLanguage() {
        if let url = Bundle.main.url(forResource: currentLang, withExtension: "json", subdirectory: "Languages") {
            do {
                let data = try Data(contentsOf: url)
                translations = try JSONDecoder().decode([String:String].self, from: data)
            } catch {
                print("error: \(error)")
            }
            
            //add found translations to existing ones and override old value with new
            translations.merge(GlobalData.shared.addTranslations(language: currentLang)) {(_, new) in new}
        }
    }
    
    /// Translates a text with parameters.
    /// - Parameters:
    ///   - key: The key to the  translation line in file
    ///   - params: The optional additional data used for the translation
    /// - Returns: Returns translated text
    func getTranslation(key: String, params: [String] = []) -> String {
        let translation: String? = translations[key]
        
        if translation != nil && !params.isEmpty {
            let charSet = CharacterSet(charactersIn: "{}")
            var components: [String] = translation!.components(separatedBy: charSet)
            
            for index in components.indices {
                if index%2 != 0 {
                    let paramIndex: Int = Int(components[index]) ?? 0
                    
                    if paramIndex < params.count {
                        components[index] = getTranslation(key: params[paramIndex])
                    }
                }
            }
            
            return components.joined()
        }
        
        return translations[key] ?? key
    }
}
