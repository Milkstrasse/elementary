//
//  OverviewView.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.08.22.
//

import SwiftUI

struct OverviewView: View {
    @EnvironmentObject var manager: ViewManager
    
    @State var transitionToggle: Bool = true
    
    @State var currentFighter: Fighter = exampleFighter
    @State var fighterSelected: Bool = false
    @State var selectedSkin: Int = 0
    
    @State var currentArray: [Fighter] = GlobalData.shared.fighters
    @State var currentCriteria: Int = -1
    let criterias: [String] = ["name", "element", "health", "attack", "defense", "agility", "precision", "resistance"]
    
    @State var showInfo: Bool = false
    
    @State var blink: Bool = false
    @State var stopBlinking: Bool = false
    
    /// Returns the amount of rows needed to display all relevant fighters.
    /// - Returns: Returns the amount of rows needed
    func getRowAmount() -> Int {
        if currentArray.count%6 > 0 {
            return currentArray.count/6 + 1
        } else {
            return currentArray.count/6
        }
    }
    
    /// Returns an array of fighters depending on the current criteria.
    /// - Parameter row: The current row
    /// - Returns: Returns an array of fighters
    func getSubArray(row: Int) -> [Fighter] {
        if (6 + row * 6) < currentArray.count {
            let rowArray = currentArray[row * 6 ..< 6 + row * 6]
            return Array(rowArray)
        } else {
            let rowArray = currentArray[row * 6 ..< currentArray.count]
            return Array(rowArray)
        }
    }
    
    /// Sorts the array of fighters depending on the criteria.
    /// - Parameter criteria: Criteria to sort the array
    func sortArray(criteria: Int) {
        switch criteria {
        case 0:
            currentArray = currentArray.sorted {
                Localization.shared.getTranslation(key: $0.name) < Localization.shared.getTranslation(key: $1.name)
            }
        case 1:
            currentArray = currentArray.sorted {
                Localization.shared.getTranslation(key: $0.element.name) < Localization.shared.getTranslation(key: $1.element.name)
            }
        case 2:
            currentArray = currentArray.sorted {
                $0.getModifiedBase().health > $1.getModifiedBase().health
            }
        case 3:
            currentArray = currentArray.sorted {
                $0.getModifiedBase().attack > $1.getModifiedBase().attack
            }
        case 4:
            currentArray = currentArray.sorted {
                $0.getModifiedBase().defense > $1.getModifiedBase().defense
            }
        case 5:
            currentArray = currentArray.sorted {
                $0.getModifiedBase().agility > $1.getModifiedBase().agility
            }
        case 6:
            currentArray = currentArray.sorted {
                $0.getModifiedBase().precision > $1.getModifiedBase().precision
            }
        case 7:
            currentArray = currentArray.sorted {
                $0.getModifiedBase().resistance > $1.getModifiedBase().resistance
            }
        default:
            currentArray = GlobalData.shared.fighters
        }
    }
    
    /// Returns wether the fighter is selected or not.
    /// - Parameter fighter: The fighter in question
    /// - Returns: Returns wether the fighter is selected or not
    func isSelected(fighter: Fighter) -> Bool {
        if fighterSelected {
            return fighter.name == currentFighter.name
        } else {
            return false
        }
    }
    
    /// Sends signal to blink.
    /// - Parameter delay: The delay between blinks
    func blink(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            blink = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                blink = false
                
                if !stopBlinking {
                    let blinkInterval: Int = Int.random(in: 5 ... 10)
                    blink(delay: TimeInterval(blinkInterval))
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color("MainPanel")
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MainView(currentFighter: GlobalData.shared.getRandomFighter().name).environmentObject(manager)))
                            }
                        }) {
                            IconButton(label: "\u{f00d}")
                        }
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color("TitlePanel")).frame(width: 255, height: largeHeight).shadow(radius: 5, x: 5, y: 0)
                            CustomText(text: Localization.shared.getTranslation(key: "overview").uppercased(), fontColor: Color("MainPanel"), fontSize: mediumFont, isBold: true).padding(.all, outerPadding)
                        }
                    }
                    .padding([.top, .leading], outerPadding)
                    Group {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 11) {
                                ForEach(0 ..< self.getRowAmount(), id: \.self) { row in
                                    HStack(spacing: 11) {
                                        ForEach(self.getSubArray(row: row), id: \.self) { fighter in
                                            Button(action: {
                                                AudioPlayer.shared.playConfirmSound()
                                                
                                                selectedSkin = 0
                                                
                                                if isSelected(fighter: fighter) {
                                                    fighterSelected = false
                                                    currentFighter = exampleFighter
                                                } else {
                                                    fighterSelected = true
                                                    currentFighter = fighter
                                                }
                                            }) {
                                                RectanglePortraitView(fighter: fighter, isSelected: isSelected(fighter: fighter), width: (geometry.size.height - 30 - 55)/6)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, outerPadding)
                        }
                        .padding(.top, innerPadding)
                        HStack(spacing: innerPadding) {
                            Spacer()
                            Button(action: {
                                AudioPlayer.shared.playStandardSound()
                                showInfo = true
                            }) {
                                BorderedButton(label: "info", width: 105, height: smallHeight, isInverted: false)
                            }
                            .opacity(fighterSelected ? 1 : 0.5).disabled(!fighterSelected)
                            ZStack {
                                Rectangle().fill(Color("MainPanel"))
                                    .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                HStack(spacing: 0) {
                                    Button(action: {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if currentCriteria < 0 {
                                            currentCriteria = criterias.count - 1
                                        } else {
                                            currentCriteria -= 1
                                        }
                                        
                                        sortArray(criteria: currentCriteria)
                                    }) {
                                        ClearButton(label: "<", width: 35, height: smallHeight)
                                    }
                                    CustomText(text: Localization.shared.getTranslation(key: currentCriteria == -1 ? "unsorted" : criterias[currentCriteria]).uppercased(), fontSize: smallFont).frame(maxWidth: 100)
                                    Button(action: {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if currentCriteria >= criterias.count - 1 {
                                            currentCriteria = -1
                                        } else {
                                            currentCriteria += 1
                                        }
                                        
                                        sortArray(criteria: currentCriteria)
                                    }) {
                                        ClearButton(label: ">", width: 35, height: smallHeight)
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                            .frame(width: 170, height: smallHeight)
                        }
                        .padding(.all, outerPadding)
                    }
                    .offset(x: showInfo ? -geometry.size.height : 0).animation(.linear(duration: 0.3), value: showInfo)
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
                FighterInfoView(fighter: currentFighter, userProgress: GlobalData.shared.userProgress, selectedSkin: $selectedSkin)
                    .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height - geometry.size.width/2)
                    .offset(y: showInfo ? 0 : geometry.size.width).animation(.linear(duration: 0.3), value: showInfo)
                ZStack(alignment: .bottomLeading) {
                    TitlePanel().fill(Color("Negative")).frame(width: geometry.size.height - geometry.size.width).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0)).shadow(radius: 5, x: 5, y: 5)
                    Image("Pattern").frame(width: 240, height: 145).clipShape(TriangleA())
                    Image(fileName: blink ? currentFighter.name + currentFighter.getSkin(index: selectedSkin) + "_blink" : currentFighter.name + currentFighter.getSkin(index: selectedSkin)).resizable().frame(width: geometry.size.width - smallHeight - 2 * outerPadding, height: geometry.size.width - smallHeight - 2 * outerPadding).offset(x: showInfo ? -15 : -geometry.size.width * 0.9).shadow(radius: 5, x: 5, y: 0)
                        .animation(.linear(duration: 0.2).delay(0.2), value: showInfo)
                    VStack {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            
                            currentFighter.skinIndex = 0
                            showInfo = false
                        }) {
                            IconButton(label: "\u{f00d}")
                        }
                        Spacer()
                    }
                    .padding(.all, outerPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).offset(y: showInfo ? ((geometry.size.width - smallHeight - 2 * outerPadding) - geometry.size.width)/2 : -geometry.size.width)
                .animation(.linear(duration: 0.3), value: showInfo)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180)).offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            let blinkInterval: Int = Int.random(in: 5 ... 10)
            blink(delay: TimeInterval(blinkInterval))
        }
        .onDisappear {
            stopBlinking = true
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView()
    }
}
