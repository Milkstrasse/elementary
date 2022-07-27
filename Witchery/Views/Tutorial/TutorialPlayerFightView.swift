//
//  TutorialPlayerFightView.swift
//  Witchery
//
//  Created by Janice Hablützel on 31.01.22.
//

import SwiftUI

struct TutorialPlayerFightView: View {
    @ObservedObject var fightLogic: FightLogic
    @ObservedObject var player: Player
    
    @Binding var tutorialCounter: Int
    
    let offsetX: CGFloat
    
    @State var currentSection: Section = .summary
    @Binding var gameOver: Bool
    
    @State var blink: Bool = false
    @State var stopBlinking: Bool = false
    
    /// Calculates the width of a witch's health bar.
    /// - Parameter witch: The current witch
    /// - Returns: Returns the width of the health bar
    func calcWidth(witch: Witch) -> CGFloat {
        let percentage: CGFloat = CGFloat(witch.currhp)/CGFloat(witch.getModifiedBase().health)
        let width = round(170 * percentage)
        
        return width
    }
    
    /// Returns tutorial text to be displayed in the text box.
    /// - Parameter geoWidth: The width of the text box
    /// - Returns: Returns tutorial text
    func getTutorialText(geoWidth: CGFloat) -> String {
        let text: String = Localization.shared.getTranslation(key: "tutorial\(tutorialCounter + 8)")
        
        return TextFitter.getFittedText(text: text, geoWidth: geoWidth)
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
            ZStack(alignment: .bottomTrailing) {
                if player.state == PlayerState.neutral {
                    Image(fileName: blink ? player.getCurrentWitch().name + "_blink" : player.getCurrentWitch().name).resizable().frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: -geometry.size.width/12 + offsetX, y: -175).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).animation(.easeOut(duration: 0.3), value: offsetX)
                } else if player.state == PlayerState.healing {
                    Image(fileName: player.getCurrentWitch().name + "_happy").resizable().frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: -geometry.size.width/12 + offsetX, y: -175).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                } else if player.state == PlayerState.hurting {
                    Image(fileName: player.getCurrentWitch().name + "_hurt").resizable().frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: -geometry.size.width/12 + offsetX, y: -175).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                } else {
                    Image(fileName: player.getCurrentWitch().name + "_attack").resizable().frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: -geometry.size.width/12 + offsetX, y: -175).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
                VStack {
                    Spacer()
                    ZStack(alignment: .top) {
                        Rectangle().fill(Color.red)
                        HStack(spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                Rectangle().frame(height: 50)
                                HStack(spacing: 5) {
                                    Spacer()
                                    ForEach(player.witches.indices, id:\.self) { index in
                                        Circle().fill(Color("outline")).frame(width: 10, height: 10).opacity(player.witches[index].currhp == 0 ? 0.5 : 1)
                                    }
                                }
                                .offset(x: -4, y: -15)
                                HStack(spacing: 5) {
                                    ForEach(player.getCurrentWitch().hexes, id: \.self) { hex in
                                        HexView(hex: hex)
                                    }
                                    if fightLogic.weather != nil {
                                        HexView(hex: fightLogic.weather!, weather: true)
                                    }
                                }
                                .padding(.leading, 15).offset(y: -12)
                                VStack(spacing: 0) {
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "hpBar", params: ["\(player.getCurrentWitch().currhp)", "\(player.getCurrentWitch().getModifiedBase().health)"]), fontColor: Color("background"), fontSize: tinyFontSize)
                                        Spacer()
                                        CustomText(key: player.getCurrentWitch().name, fontColor: Color("background"), fontSize: mediumFontSize, isBold: true)
                                    }
                                    ZStack(alignment: .leading) {
                                        Rectangle().fill(Color("healthbar")).frame(height: 6)
                                        Rectangle().fill(Color("health")).frame(width: calcWidth(witch: player.getCurrentWitch()), height: 6).animation(.default, value: player.getCurrentWitch().currhp)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                                .frame(width: 170, height: 50).padding(.leading, 15)
                            }
                            .frame(width: 190)
                            Triangle().frame(width: 50, height: 50)
                            Spacer()
                        }
                        .offset(y: -25)
                        Group {
                            if currentSection == .summary {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 5).fill(Color("button"))
                                    ScrollView(.vertical, showsIndicators: false) {
                                        ScrollViewReader { value in
                                            ForEach(fightLogic.battleLog.indices, id: \.self) { index in
                                                CustomText(text: fightLogic.battleLog[index], fontSize: smallFontSize).frame(width: geometry.size.width - 60, alignment: .topLeading).padding(.horizontal, 15).id(index)
                                                    .onAppear {
                                                        value.scrollTo(index, anchor: .bottom)
                                                    }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 15)
                                }
                                .frame(height: 115).padding(.horizontal, 15)
                            } else if currentSection != .waiting {
                                ScrollView(.vertical, showsIndicators: false) {
                                    if currentSection == .options {
                                        OptionsView(currentSection: $currentSection, gameOver: $gameOver, fightLogic: fightLogic, player: player, tutorialCounter: tutorialCounter)
                                    } else if currentSection == .spells {
                                        SpellsView(currentSection: $currentSection, fightLogic: fightLogic, player: player, tutorialCounter: tutorialCounter)
                                            .onAppear {
                                                tutorialCounter += 1
                                            }
                                    } else if currentSection == .team {
                                        TeamView(currentSection: $currentSection, fightLogic: fightLogic, player: player)
                                            .onAppear {
                                                tutorialCounter += 1
                                            }
                                    }
                                }
                                .frame(height: 115).clipped()
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: geometry.size.height - 30, height: 115)
                                    CustomText(key: "waiting", fontSize: smallFontSize).frame(width: geometry.size.width - 60, alignment: .topLeading).padding(.all, 15)
                                }
                                .frame(height: 115)
                            }
                        }
                        .padding(.top, 45)
                        HStack {
                            Spacer()
                            Button(currentSection == .summary ? Localization.shared.getTranslation(key: "next") : Localization.shared.getTranslation(key: "back")) {
                                AudioPlayer.shared.playStandardSound()
                                
                                if currentSection != .summary && tutorialCounter > 0 {
                                    return
                                }
                                
                                if currentSection == .options {
                                    currentSection = .summary
                                } else {
                                    if currentSection == .waiting {
                                        fightLogic.undoMove(player: player)
                                    }
                                    currentSection = .options
                                }
                            }
                            .buttonStyle(ClearButton(width: 100, height: 35))
                            .opacity(fightLogic.battling ? 0.7 : 1.0).disabled(fightLogic.battling)
                        }
                        .padding(.horizontal, 15)
                    }
                    .frame(height: 175 + geometry.safeAreaInsets.bottom).offset(y: geometry.safeAreaInsets.bottom)
                }
                if !fightLogic.battling {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(width: 240, height: 95)
                            ZStack {
                                ScrollView(.vertical, showsIndicators: false) {
                                    CustomText(text: getTutorialText(geoWidth: 215), fontSize: smallFontSize).frame(width: 210, height: 75, alignment: .topLeading)
                                }
                                .frame(width: 210, height: 65)
                            }
                            .frame(width: 210, height: 65).padding(.all, 15)
                        }
                        .padding(.leading, 15).offset(y: -220)
                        Spacer()
                    }
                }
            }
            .rotationEffect(.degrees(player.id == 0 ? 180 : 0))
            .onReceive(fightLogic.$battling, perform: { battling in
                if battling {
                    tutorialCounter += 1
                    currentSection = .summary
                }
            })
            /*HStack {
                Spacer()
                ZStack(alignment: .bottomTrailing) {
                    if player.state == PlayerState.neutral {
                        Image(fileName: blink ? player.getCurrentWitch().name + "_blink" : player.getCurrentWitch().name).resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40 + offsetX, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(-90)).animation(.easeOut(duration: 0.3), value: offsetX)
                    } else if player.state == PlayerState.healing {
                        Image(fileName: player.getCurrentWitch().name + "_happy").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(-90))
                    } else if player.state == PlayerState.hurting {
                        Image(fileName: player.getCurrentWitch().name + "_hurt").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(-90))
                    } else {
                        Image(fileName: player.getCurrentWitch().name + "_attack").resizable().scaleEffect(1.1).frame(width: geometry.size.width/1.5, height: geometry.size.width/1.5).offset(x: 40, y: -185).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotationEffect(.degrees(-90))
                    }
                    Rectangle().fill(Color("panel")).frame(width: 175 + geometry.safeAreaInsets.trailing).offset(x: geometry.safeAreaInsets.trailing)
                    HStack(spacing: 10) {
                        ZStack(alignment: .trailing) {
                            VStack(alignment: .trailing) {
                                ZStack(alignment: .bottomLeading) {
                                    HStack(spacing: 0) {
                                        Triangle().fill(Color("outline")).frame(width: 21, height: 52)
                                        Rectangle().fill(Color("outline")).frame(width: 190, height: 52)
                                    }
                                    .padding(.bottom, 4).offset(x: -1).frame(width: 210)
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(spacing: 5) {
                                            ForEach(player.witches.indices, id:\.self) { index in
                                                Circle().fill(Color("outline")).frame(width: 10, height: 10).opacity(player.witches[index].currhp == 0 ? 0.5 : 1)
                                            }
                                        }
                                        .padding(.leading, 24).offset(y: -5)
                                        HStack(spacing: 0) {
                                            Triangle().fill(Color("outline")).frame(width: 20, height: 50)
                                            ZStack(alignment: .topTrailing) {
                                                Rectangle().fill(Color("outline")).frame(width: 190)
                                                HStack(spacing: 5) {
                                                    ForEach(player.getCurrentWitch().hexes, id: \.self) { hex in
                                                        HexView(hex: hex)
                                                    }
                                                    if fightLogic.weather != nil {
                                                        HexView(hex: fightLogic.weather!, weather: true)
                                                    }
                                                }
                                                .offset(x: -12, y: -12)
                                                VStack(spacing: 0) {
                                                    HStack {
                                                        CustomText(key: player.getCurrentWitch().name, fontColor: Color("background"), fontSize: mediumFontSize, isBold: true).lineLimit(1)
                                                        Spacer()
                                                        CustomText(text: Localization.shared.getTranslation(key: "hpBar", params: ["\(player.getCurrentWitch().currhp)", "\(player.getCurrentWitch().getModifiedBase().health)"]), fontColor: Color("background"), fontSize: tinyFontSize)
                                                    }
                                                    ZStack(alignment: .leading) {
                                                        Rectangle().fill(Color("healthbar")).frame(height: 6)
                                                        Rectangle().fill(Color("health")).frame(width: calcWidth(witch: player.getCurrentWitch()), height: 6).animation(.default, value: player.getCurrentWitch().currhp)
                                                    }
                                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                                }
                                                .padding(.trailing, 15).padding(.leading, 5).frame(height: 50)
                                            }
                                        }
                                        .frame(height: 50)
                                    }
                                    .frame(height: 70)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 70, height: 210).offset(y: offsetX).animation(.easeOut(duration: 0.3).delay(0.1), value: offsetX)
                                Spacer()
                            }
                            VStack(alignment: .trailing) {
                                Spacer()
                                ZStack {
                                    Button(currentSection == .summary ? Localization.shared.getTranslation(key: "next") : Localization.shared.getTranslation(key: "back")) {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if currentSection != .summary && tutorialCounter > 0 {
                                            return
                                        }
                                        
                                        if currentSection == .options {
                                            currentSection = .summary
                                        } else {
                                            if currentSection == .waiting {
                                                fightLogic.undoMove(player: player)
                                            }
                                            currentSection = .options
                                        }
                                    }
                                    .buttonStyle(ClearButton(width: 100, height: 35))
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 35, height: 100).opacity(fightLogic.battling ? 0.7 : 1.0).disabled(fightLogic.battling)
                            }
                            .padding(.bottom, 15)
                        }
                        Group {
                            if currentSection == .summary {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: geometry.size.height - 30, height: 115)
                                    ScrollView(.vertical, showsIndicators: false) {
                                        ScrollViewReader { value in
                                            ForEach(fightLogic.battleLog.indices, id: \.self) { index in
                                                CustomText(text: fightLogic.battleLog[index], fontSize: smallFontSize).frame(width: geometry.size.height - 60, alignment: .leading).id(index)
                                                    .onAppear {
                                                        value.scrollTo(index, anchor: .bottom)
                                                    }
                                            }
                                        }
                                    }
                                    .frame(height: 85).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
                            } else if currentSection != .waiting {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 5) {
                                        if currentSection == .options {
                                            OptionsView(currentSection: $currentSection, gameOver: $gameOver, fightLogic: fightLogic, player: player, tutorialCounter: tutorialCounter)
                                        } else if currentSection == .spells {
                                            SpellsView(currentSection: $currentSection, fightLogic: fightLogic, player: player, tutorialCounter: tutorialCounter)
                                                .onAppear {
                                                    tutorialCounter += 1
                                                }
                                        } else if currentSection == .team {
                                            TeamView(currentSection: $currentSection, fightLogic: fightLogic, player: player)
                                                .onAppear {
                                                    tutorialCounter += 1
                                                }
                                        }
                                    }
                                }
                                .padding(.vertical, 15).frame(width: 115, height: geometry.size.height - 30)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: geometry.size.height - 30, height: 115)
                                    CustomText(key: "waiting", fontSize: smallFontSize).frame(width: geometry.size.height - 60, height: 85, alignment: .topLeading).padding(.horizontal, 15)
                                }
                                .rotationEffect(.degrees(-90)).frame(width: 115, height: geometry.size.height - 30)
                            }
                        }
                        .padding(.trailing, 15)
                    }
                }
            }
            .frame(width: geometry.size.width)
            .onReceive(fightLogic.$battling, perform: { battling in
                if battling {
                    tutorialCounter += 1
                    currentSection = .summary
                }
            })
            if !fightLogic.battling {
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color("health")).frame(width: 95, height: 240)
                    ZStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            CustomText(text: getTutorialText(geoWidth: 215), fontSize: smallFontSize).frame(width: 210, height: 75, alignment: .topLeading)
                        }
                        .frame(width: 210, height: 65)
                    }
                    .frame(width: 65, height: 210).padding(.all, 15).rotationEffect(.degrees(-90))
                }
                .padding(.top, 15).offset(x: geometry.size.width - 320)
            }*/
        }
        .onAppear {
            let blinkInterval: Int = Int.random(in: 5 ... 10)
            blink(delay: TimeInterval(blinkInterval))
        }
        .onDisappear {
            stopBlinking = true
        }
    }
}

struct TutorialPlayerFightView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialPlayerFightView(fightLogic: FightLogic(players: [Player(id: 0, witches: [exampleWitch]), Player(id: 1, witches: [exampleWitch])]), player: Player(id: 1, witches: [exampleWitch]), tutorialCounter:Binding.constant(0), offsetX: 0, gameOver:Binding.constant(false))
    }
}
