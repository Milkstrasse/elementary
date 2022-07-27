//
//  TutorialSelectionView.swift
//  Witchery
//
//  Created by Janice Hablützel on 31.01.22.
//

import SwiftUI

struct TutorialSelectionView: View {
    @EnvironmentObject var manager: ViewManager
    @State var gameLogic: GameLogic = GameLogic()
    
    @State var tutorialCounter: Int = 0
    
    @State var topWitches: [Witch?] = [exampleWitch, nil, nil, nil]
    @State var bottomWitches: [Witch?] = [nil, nil, nil, nil]
    
    @State var transitionToggle: Bool = true
    
    /// Creates and returns the logic that will be used int the upcoming fight.
    /// - Returns: returns the logic that will be used int the upcoming fight.
    func createLogic() -> FightLogic {
        var lefts: [Witch] = []
        for witch in topWitches {
            if witch != nil {
                lefts.append(witch!)
            }
        }
        
        var rights: [Witch] = []
        for witch in bottomWitches {
            if witch != nil {
                rights.append(witch!)
            }
        }
        
        return FightLogic(players: [Player(id: 0, witches: lefts), Player(id: 1, witches: rights)], hasCPUPlayer: true)
    }
    
    /// Checks if selected teams contains atleast one witch.
    /// - Parameter array: The selection of witches to check
    /// - Returns: Returns wether atleast one witch was selected or not
    func isArrayEmpty(array: [Witch?]) -> Bool {
        for witch in array {
            if witch != nil {
                return false
            }
        }
        
        return true
    }
    
    /// Returns tutorial text to be displayed in the top text box.
    /// - Parameter geoWidth: The width of the text box
    /// - Returns: Returns tutorial text
    func getTopTutorialText(geoWidth: CGFloat) -> String {
        let text: String
        
        switch tutorialCounter {
            case 5, 6, 7:
                text = Localization.shared.getTranslation(key: "tutorial5")
            case 8:
                text = Localization.shared.getTranslation(key: "tutorial6")
            default:
                text = Localization.shared.getTranslation(key: "tutorial\(tutorialCounter)")
        }
        
        return TextFitter.getFittedText(text: text, geoWidth: geoWidth)
    }
    
    /// Returns tutorial text to be displayed in the bottom text box.
    /// - Returns: Returns tutorial text
    func getBottomTutorialText(geoWidth: CGFloat) -> String {
        let text: String
        
        if tutorialCounter < 2 {
            text = Localization.shared.getTranslation(key: "tutorial0")
        } else {
            text = Localization.shared.getTranslation(key: "tutorial7")
        }
        
        return TextFitter.getFittedText(text: text, geoWidth: geoWidth)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                HStack(spacing: 5) {
                    Spacer()
                    Button(Localization.shared.getTranslation(key: "cancel")) {
                    }
                    .buttonStyle(BasicButton(width: 135)).disabled(true)
                    Button("X") {
                        AudioPlayer.shared.playCancelSound()
                        transitionToggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            manager.setView(view: AnyView(MainView().environmentObject(manager)))
                        }
                    }
                    .buttonStyle(BasicButton(width: 45))
                }
                .rotationEffect(.degrees(180))
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color("health"))
                    ZStack {
                        CustomText(text: getBottomTutorialText(geoWidth: geometry.size.width - 60), fontSize: smallFontSize).frame(width: geometry.size.width - 60, height: 75, alignment: .topLeading)
                    }
                    .padding(.all, 15)
                }
                .frame(height: 105)
                HStack(spacing: 5) {
                    Spacer()
                    Button(Localization.shared.getTranslation(key: "ready")) {
                        AudioPlayer.shared.playConfirmSound()
                        let fightLogic: FightLogic = createLogic()
                        
                        if fightLogic.isValid() {
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(TutorialFightView(fightLogic: fightLogic).environmentObject(manager)))
                            }
                        }
                    }
                    .buttonStyle(BasicButton(width: 135)).opacity(isArrayEmpty(array: bottomWitches) ? 0.5 : 1.0).disabled(isArrayEmpty(array: bottomWitches))
                    Button("X") {
                        AudioPlayer.shared.playCancelSound()
                        transitionToggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            manager.setView(view: AnyView(MainView().environmentObject(manager)))
                        }
                    }
                    .buttonStyle(BasicButton(width: 45))
                }
            }
            .padding(.all, 15)
            VStack(spacing: 0) {
                VStack {
                    HStack(spacing: 5) {
                        Spacer()
                        ForEach(0 ..< 4) { index in
                            SquareWitchView(witch: topWitches[index], isSelected: false, inverted: true)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .rotationEffect(.degrees(180))
                ZStack {
                    Rectangle().fill(Color("highlight")).frame(height: 2)
                    CustomText(text: "X", fontColor: Color("highlight"), fontSize: largeFontSize, isBold: true).padding(.horizontal, 10).background(Color.purple)
                }
                .padding(.all, 15)
                TutorialPlayerSelectionView(witches: $bottomWitches, tutorialCounter: $tutorialCounter)
            }
            Rectangle().fill(Color("background")).opacity(tutorialCounter > 8 ? 0 : 0.5).frame(height: (geometry.size.height + geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top)/2 + 25).ignoresSafeArea()
            Rectangle().fill(Color("background")).opacity(tutorialCounter > 8 ? 0 : 0.5).frame(height: (geometry.size.height + geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top)/2 - 25).zIndex(-1).offset(y: (geometry.size.height + geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top)/2 + 25).ignoresSafeArea()
            if tutorialCounter > 0 && tutorialCounter < 9 {
                VStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(height: 105)
                        ZStack {
                            CustomText(text: getTopTutorialText(geoWidth: geometry.size.width - 60), fontSize: smallFontSize).frame(width: geometry.size.width - 60, height: 75, alignment: .topLeading)
                        }
                        .padding(.all, 15)
                    }
                    .padding(.bottom, geometry.size.height/2 - 100)
                    Spacer()
                }
                .ignoresSafeArea().padding(.horizontal, 15)
            }
            ZigZag().fill(Color("panel")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 65).rotationEffect(.degrees(180)).offset(y: transitionToggle ? 0 : -geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom - 65).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
        }
    }
}

struct TutorialSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialSelectionView()
    }
}
