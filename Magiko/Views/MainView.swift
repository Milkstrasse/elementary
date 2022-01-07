//
//  MainView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var currentView: CurrentView
    
    @State var currentFighter: Fighter = Fighter(data: FighterData(name: "magicalgirl_1", element: "Water", skills: [], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, spAttack: 100)))
    
    @State var overviewToggle: Bool = false
    @State var settingsToggle: Bool = false
    @State var infoToggle: Bool = false
    
    @State var transitionToggle: Bool = true
    
    @State var offsetX: CGFloat = -449
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Color.red.ignoresSafeArea()
            Image(currentFighter.name).resizable().scaleEffect(2.4).aspectRatio(contentMode: .fit).offset(x: -50, y: 170).padding(.trailing, offsetX < 0 ? 0 : 255).animation(.linear(duration: 0.2), value: offsetX)
            HStack(alignment: .top, spacing: 5) {
                HStack(spacing: 5) {
                    Button("Training") {
                        print("Button pressed!")
                    }
                    .buttonStyle(GrowingButton(width: 135))
                    Button("O") {
                        overviewToggle = true
                    }
                    .buttonStyle(GrowingButton(width: 40))
                    Button("S") {
                        settingsToggle = true
                    }
                    .buttonStyle(GrowingButton(width: 40))
                    Button("I") {
                        infoToggle = true
                    }
                    .buttonStyle(GrowingButton(width: 40))
                }
                .padding(.leading, offsetX < 0 ? 0 : -449).animation(.linear(duration: 0.2), value: offsetX)
                Spacer()
                VStack {
                    Spacer()
                    Button(GlobalData.shared.getTranslation(key: "fight")) {
                        transitionToggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            currentView.scene = CurrentView.Scene.fightSelection
                        }
                    }
                    .buttonStyle(GrowingButton(width: 190))
                }
            }
            .padding(.all, 15)
            if overviewToggle {
                OverviewView(currentFighter: $currentFighter, overviewToggle: $overviewToggle, offsetX: $offsetX)
            } else if settingsToggle {
                SettingsView(settingsToggle: $settingsToggle, offsetX: $offsetX)
            } else if infoToggle {
                InfoView(infoToggle: $infoToggle, offsetX: $offsetX)
            }
            GeometryReader { geometry in
                ZigZag().fill(Color.purple).frame(height: geometry.size.height + 65)
                    .offset(y: transitionToggle ? -65 : geometry.size.height + 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            transitionToggle = false
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
.previewInterfaceOrientation(.landscapeRight)
    }
}
