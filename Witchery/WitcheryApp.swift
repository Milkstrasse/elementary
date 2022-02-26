//
//  WitcheryApp.swift
//  Witchery
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

let exampleWitch: Witch = Witch(data: WitchData(name: "water1", element: "water", spells: ["unknownSpell"], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 0, resistance: 100)))

@main
struct WitcheryApp: App {
    @StateObject var manager: ViewManager = ViewManager()
    @State var isLoading = true
    
    //disables rotation animation
    init() {
        UINavigationBar.setAnimationsEnabled(false)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color("background").ignoresSafeArea()
                if isLoading {
                    Color("panel").ignoresSafeArea().onAppear {
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
