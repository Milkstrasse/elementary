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
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color("Negative").ignoresSafeArea()
                if isLoading {
                    Color("Positive").ignoresSafeArea().onAppear {
                        DispatchQueue.global().async {
                            GlobalData.shared.loadData(manager: manager)
                            SaveData.load()
                            
                            Localization.shared.getLanguages()
                            Localization.shared.loadCurrentLanguage()
                            
                            AudioPlayer.shared.playMenuMusic()
                            
                            manager.setView(view: AnyView(MainView(currentFighter: GlobalData.shared.getRandomFighter()).environmentObject(manager)))
                            isLoading = false
                        }
                    }
                    CustomText(text: String(format: "%.2f", manager.progress) + "%", fontSize: smallFont)
                } else {
                    manager.getCurrentView()
                }
            }
        }
    }
}
