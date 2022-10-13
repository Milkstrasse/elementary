//
//  ElementaryApp.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.08.22.
//

import SwiftUI

let exampleFighter: Fighter = Fighter(data: FighterData(name: "example", element: "water", spells: ["waterSimpleAttack", "woodSimpleAttack", "decaySimpleAttack", "attackDown"], base: Base(health: 65, attack: 100, defense: 80, agility: 50, precision: 90, resistance: 55)))

class ViewManager: ObservableObject {
    @Published var currentView: AnyView = AnyView(Color.yellow)
    
    func setView(view: AnyView) {
        currentView = AnyView(view)
    }
    
    func getCurrentView() -> AnyView {
        return currentView
    }
}

@main
struct ElementaryApp: App {
    @StateObject var manager: ViewManager = ViewManager()
    @State var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color("Background1").ignoresSafeArea()
                if isLoading {
                    Color.blue.ignoresSafeArea().onAppear {
                        DispatchQueue.main.async {
                            GlobalData.shared.loadData()
                            SaveLogic.shared.load()
                            
                            Localization.shared.getLanguages()
                            Localization.shared.loadCurrentLanguage()
                            
                            AudioPlayer.shared.playMenuMusic()
                            
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
}
