//
//  MagikoApp.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

class ViewManager: ObservableObject {
    @Published var currentView: AnyView = AnyView(Color.yellow)
    
    func setView(view: AnyView) {
        currentView = AnyView(view)
    }
    
    func getCurrentView() -> AnyView {
        return currentView
    }
}

let exampleFighter: Fighter = Fighter(data: FighterData(name: "magicalgirl_1", element: "Water", skills: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, spAttack: 100)))

@main
struct MagikoApp: App {
    @StateObject var manager: ViewManager = ViewManager()
    @State var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                Color.purple.onAppear {
                    DispatchQueue.main.async {
                        var langCode = UserDefaults.standard.string(forKey: "lang")
                        if langCode == nil {
                            langCode = String(Locale.preferredLanguages[0].prefix(2))
                            UserDefaults.standard.set(langCode, forKey: "lang")
                        }
                        
                        GlobalData.shared.loadData()
                        
                        GlobalData.shared.getLanguages()
                        GlobalData.shared.loadLanguage(language: langCode!)
                        
                        manager.setView(view: AnyView(MainView().environmentObject(manager)))
                        isLoading = false
                    }
                }
            } else {
                manager.getCurrentView()
            }
        }
    }
}
