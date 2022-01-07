//
//  MagikoApp.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

class CurrentView: ObservableObject {
    @Published var scene: Scene = .loading
    
    enum Scene {
        case loading
        case main
        case fightSelection
        case fight
    }
}

@main
struct MagikoApp: App {
    @StateObject var currentView = CurrentView()
    
    var body: some Scene {
        WindowGroup {
            if currentView.scene == CurrentView.Scene.main {
                MainView().environmentObject(currentView)
            } else if currentView.scene == CurrentView.Scene.fightSelection {
                FightSelectionView().environmentObject(currentView)
            } else if currentView.scene == CurrentView.Scene.fight {
                FightView()
            } else {
                Color.purple.onAppear {
                    DispatchQueue.main.async {
                        GlobalData.shared.loadData()
                        
                        let lang = String(Locale.preferredLanguages[0].prefix(2))
                        GlobalData.shared.getLanguages()
                        GlobalData.shared.loadLanguage(language: lang)
                        
                        currentView.scene = CurrentView.Scene.main
                    }
                }
            }
        }
    }
}
