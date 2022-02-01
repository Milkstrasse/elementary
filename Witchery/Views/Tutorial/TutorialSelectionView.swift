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
    
    func isArrayEmpty(array: [Witch?]) -> Bool {
        for witch in array {
            if witch != nil {
                return false
            }
        }
        
        return true
    }
    
    func getTopTutorialText() -> String {
        switch tutorialCounter {
            case 1:
                return "select witch"
            case 2:
                return "click on selected witch to edit her"
            case 3:
                return "change her **nature** and observe how her\nstats change. each nature has **drawbacks**\nand **benefits**"
            case 4:
                return "scroll down to give her an artifact with\n**special effects**"
            case 5, 6, 7:
                return "add another witch. you can have up to four\nwitches in a team"
            case 8:
                return "edit her to her liking and click on the witch\nif you are ready"
            default:
                return ""
        }
        
    }
    
    func getBottomTutorialText() -> String {
        if tutorialCounter < 2 {
            return "click on + button to select witch"
        } else {
            return "click on ready to start fight"
        }
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
                            .buttonStyle(BasicButton(width: 135)).disabled(true)
                            Button("X") {
                                AudioPlayer.shared.playCancelSound()
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                }
                            }
                            .buttonStyle(BasicButton(width: 40))
                        }
                        .rotationEffect(.degrees(90)).frame(width: 40, height: 180)
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                        RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                        ZStack {
                            CustomText(text: getBottomTutorialText(), fontSize: 14).frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 60, height: 80, alignment: .topLeading)
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
                            .buttonStyle(BasicButton(width: 135)).opacity(isArrayEmpty(array: rightWitches) ? 0.5 : 1.0).disabled(isArrayEmpty(array: rightWitches))
                            Button("X") {
                                AudioPlayer.shared.playCancelSound()
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    manager.setView(view: AnyView(MainView().environmentObject(manager)))
                                }
                            }
                            .buttonStyle(BasicButton(width: 40))
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
                                        SquareWitchView(witch: leftWitches[index], isSelected: false)
                                    }
                                }
                                .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                                Spacer()
                            }
                        }
                    }
                    ZStack {
                        Rectangle().fill(Color("outline")).frame(width: 1).padding(.vertical, 15)
                        CustomText(text: "X", fontSize: 18).padding(.horizontal, 10).background(Color("background")).rotationEffect(.degrees(90))
                    }
                    .frame(width: 60)
                    TutorialRightSelectionView(witches: $rightWitches, tutorialCounter: $tutorialCounter)
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
            Rectangle().fill(Color("background")).opacity(0.5).frame(width: geometry.size.width/2 + geometry.safeAreaInsets.leading + 30).ignoresSafeArea()
            Rectangle().fill(Color("background")).frame(width: geometry.size.width/2 + geometry.safeAreaInsets.trailing + 30).opacity(0.5).zIndex(-1).offset(x: geometry.size.width/2 + geometry.safeAreaInsets.trailing + 30).ignoresSafeArea()
            if tutorialCounter > 0 && tutorialCounter < 9 {
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                        RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: 110, height: geometry.size.height + geometry.safeAreaInsets.bottom - 30)
                        ZStack {
                            CustomText(text: getTopTutorialText(), fontSize: 14).frame(width: geometry.size.height + geometry.safeAreaInsets.bottom - 60, height: 80, alignment: .topLeading)
                        }
                        .frame(width: 80, height: geometry.size.height + geometry.safeAreaInsets.bottom - 60).padding(.all, 15).rotationEffect(.degrees(-90))
                    }
                    .padding(.trailing, 240)
                    Spacer()
                }
                .ignoresSafeArea().padding(.vertical, 15)
            }
            ZigZag().fill(Color("outline")).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
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
