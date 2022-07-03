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
    
    @State var leftWitches: [Witch?] = [exampleWitch, nil, nil, nil]
    @State var rightWitches: [Witch?] = [nil, nil, nil, nil]
    
    @State var transitionToggle: Bool = true
    
    /// Creates and returns the logic that will be used int the upcoming fight.
    /// - Returns: returns the logic that will be used int the upcoming fight.
    func createLogic() -> FightLogic {
        var lefts: [Witch] = []
        for witch in leftWitches {
            if witch != nil {
                lefts.append(witch!)
            }
        }
        
        var rights: [Witch] = []
        for witch in rightWitches {
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
            ZStack {
                HStack(spacing: 0) {
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            Button(Localization.shared.getTranslation(key: "cancel")) {
                            }
                            .buttonStyle(BasicButton(width: 135, bgColor: Color("health"))).disabled(true)
                            Button("X") {
                                AudioPlayer.shared.playCancelSound()
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                }
                            }
                            .buttonStyle(BasicButton(width: 40, bgColor: Color("health")))
                        }
                        .rotationEffect(.degrees(90)).frame(width: 40, height: 180)
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                        ZStack {
                            CustomText(text: getBottomTutorialText(geoWidth: geometry.size.height + geometry.safeAreaInsets.bottom - 60), fontSize: smallFontSize).frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 60, height: 80, alignment: .topLeading)
                        }
                        .frame(width: 80, height: geometry.size.height + geometry.safeAreaInsets.bottom - 60).padding(.all, 15).rotationEffect(.degrees(-90))
                    }
                    .padding(.trailing, 10)
                    VStack {
                        HStack(spacing: 5) {
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
                            .buttonStyle(BasicButton(width: 135, bgColor: Color("health"))).opacity(isArrayEmpty(array: rightWitches) ? 0.5 : 1.0).disabled(isArrayEmpty(array: rightWitches))
                            Button("X") {
                                AudioPlayer.shared.playCancelSound()
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                }
                            }
                            .buttonStyle(BasicButton(width: 40, bgColor: Color("health")))
                        }
                        .rotationEffect(.degrees(-90)).frame(width: 40, height: 180)
                        Spacer()
                    }
                }
                .padding(.all, 15).ignoresSafeArea(.all, edges: .bottom)
                HStack(spacing: 0) {
                    ZStack {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                HStack(spacing: 5) {
                                    ForEach(0 ..< 4) { index in
                                        SquareWitchView(witch: leftWitches[index], isSelected: false, inverted: true)
                                    }
                                }
                                .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                                Spacer()
                            }
                        }
                    }
                    ZStack {
                        Rectangle().fill(Color("highlight")).frame(width: 2).padding(.vertical, 15)
                        CustomText(text: "X", fontColor: Color("highlight"), fontSize: largeFontSize, isBold: true).padding(.horizontal, 10).background(Color("background")).rotationEffect(.degrees(90))
                    }
                    .frame(width: 60)
                    TutorialRightSelectionView(witches: $rightWitches, tutorialCounter: $tutorialCounter)
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
            Rectangle().fill(Color("background")).opacity(tutorialCounter > 8 ? 0 : 0.5).frame(width: geometry.size.width/2 + geometry.safeAreaInsets.leading + 30).ignoresSafeArea()
            Rectangle().fill(Color("background")).frame(width: geometry.size.width/2 + geometry.safeAreaInsets.trailing + 30).opacity(0.5).zIndex(-1).offset(x: geometry.size.width/2 + geometry.safeAreaInsets.trailing + 30).ignoresSafeArea()
            if tutorialCounter > 0 && tutorialCounter < 9 {
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                        ZStack {
                            CustomText(text: getTopTutorialText(geoWidth: geometry.size.height + geometry.safeAreaInsets.bottom - 55), fontSize: smallFontSize).frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 60, height: 80, alignment: .topLeading)
                        }
                        .frame(width: 80, height: geometry.size.height + geometry.safeAreaInsets.bottom - 60).padding(.all, 15).rotationEffect(.degrees(-90))
                    }
                    .padding(.trailing, 240)
                    Spacer()
                }
                .ignoresSafeArea().padding(.vertical, 15)
            }
            ZigZag().fill(Color("panel")).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -65 : -(geometry.size.height + 65)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
        }
    }
}

struct TutorialSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialSelectionView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
