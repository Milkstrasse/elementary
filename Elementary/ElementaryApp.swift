//
//  ElementaryApp.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.08.22.
//

import SwiftUI

class ViewManager: ObservableObject {
    @Published var currentView: AnyView = AnyView(Color.yellow)
    @Published var progress: Float = 0
    
    /// Sets a new view to display onto the screen.
    /// - Parameter view: The view to display
    func setView(view: AnyView) {
        DispatchQueue.main.async {
            self.currentView = AnyView(view)
        }
    }
    
    /// Returns the current view to display onto the main screen.
    /// - Returns: Returns the current view
    func getCurrentView() -> AnyView {
        return currentView
    }
}

@main
struct ElementaryApp: App {
    @StateObject var manager: ViewManager = ViewManager()
    @State var isLoading: Bool = true
    
    @State var randomInt: Int = 0
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color("Negative").ignoresSafeArea()
                if isLoading {
                    Color("Positive").ignoresSafeArea().onAppear {
                        SaveData.load()
                        
                        Localization.shared.getLanguages()
                        Localization.shared.loadCurrentLanguage()
                        
                        randomInt = Int.random(in: 1 ... 4)
                        
                        DispatchQueue.global().async {
                            GlobalData.shared.loadData(manager: manager)
                            
                            AudioPlayer.shared.playMenuMusic()
                            
                            manager.setView(view: AnyView(MainView(currentFighter: GlobalData.shared.getRandomFighter()).environmentObject(manager)))
                            isLoading = false
                        }
                    }
                    VStack {
                        CustomText(text: String(format: "%.2f", manager.progress) + "%", fontSize: General.smallFont)
                        if randomInt > 0 {
                            CustomText(text: Localization.shared.getTranslation(key: "tip\(randomInt)"), fontSize: General.mediumFont)
                        }
                    }
                } else {
                    manager.getCurrentView()
                }
            }
        }
    }
}
