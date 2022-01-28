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

let exampleWitch: Witch = Witch(data: WitchData(name: "luna", element: "water", spells: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, stamina: 100)))

@main
struct MagikoApp: App {
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
                    Color("outline").onAppear {
                        DispatchQueue.main.async {
                            var langCode = UserDefaults.standard.string(forKey: "lang")
                            if langCode == nil {
                                langCode = String(Locale.preferredLanguages[0].prefix(2))
                                UserDefaults.standard.set(langCode, forKey: "lang")
                            }
                            
                            Localization.shared.getLanguages()
                            Localization.shared.loadLanguage(language: langCode!)
                            
                            AudioPlayer.shared.setSoundVolume(volume: UserDefaults.standard.float(forKey: "sound"))
                            AudioPlayer.shared.setMusicVolume(volume: UserDefaults.standard.float(forKey: "music"))
                            AudioPlayer.shared.playMenuMusic()
                            
                            GlobalData.shared.loadData()
                            
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
