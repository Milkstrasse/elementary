//
//  MagikoApp.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

class CurrentView: ObservableObject {
    @Published var viewName: String = "Loading"
}

@main
struct MagikoApp: App {
    
    @StateObject var currentView = CurrentView()
    
    var body: some Scene {
        WindowGroup {
            if currentView.viewName == "Main" {
                MainView().environmentObject(currentView)
            } else if currentView.viewName == "FightSelection" {
                FightSelectionView().environmentObject(currentView)
            } else if currentView.viewName == "Fight" {
                FightView()
            } else {
                Color.purple.onAppear {
                    DispatchQueue.main.async {
                        GlobalData.loadFighters()
                        currentView.viewName = "Main"
                    }
                }
            }
        }
    }
}
