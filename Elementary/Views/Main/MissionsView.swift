//
//  MissionsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 20.10.22.
//

import SwiftUI

struct MissionsView: View {
    @EnvironmentObject var manager: ViewManager
    
    @State var userProgress: UserProgress
    
    @State var transitionToggle: Bool = true
    
    @State var blink: Bool = false
    @State var stopBlinking: Bool = false
    
    let fightCounter: [Float] = [25, 50, 100]
    let winStreak: [Float] = [5, 10, 25]
    
    /// Sends signal to blink.
    /// - Parameter delay: The delay between blinks
    func blink(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            blink = true
            
            userProgress.resetDaily()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                blink = false
                
                if !stopBlinking {
                    let blinkInterval: Int = Int.random(in: 5 ... 10)
                    blink(delay: TimeInterval(blinkInterval))
                }
            }
        }
    }
    
    /// Calculates the percentage of completed daily missions.
    /// - Returns: Returns percentage of completed daily missions
    func dailyComplete() -> Float {
        var counter: Float = min(Float(userProgress.dailyFightCounter)/5, 1)
        counter += min(Float(userProgress.dailyWinCounter)/2, 1)
        if userProgress.dailyElementWin {
            counter += 1
        }
        if userProgress.dailyArtifactUsed {
            counter += 1
        }
        
        counter = counter/4 * 100
        
        return counter
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color("MainPanel").ignoresSafeArea()
                VStack(alignment: .leading, spacing: General.innerPadding) {
                    HStack(alignment: .top) {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            
                            GlobalData.shared.userProgress = userProgress
                            SaveData.saveProgress()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MainView(currentFighter: GlobalData.shared.getRandomFighter()).environmentObject(manager)))
                            }
                        }) {
                            IconButton(label: "\u{f00d}")
                        }
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color("TitlePanel")).frame(width: 255 + geometry.safeAreaInsets.bottom, height: General.largeHeight).shadow(radius: 5, x: 5, y: 0)
                            CustomText(text: Localization.shared.getTranslation(key: "missions").uppercased(), fontColor: Color("MainPanel"), fontSize: General.mediumFont, isBold: true).padding(.all, General.outerPadding).padding(.trailing, geometry.safeAreaInsets.bottom)
                        }
                        .ignoresSafeArea().offset(x: geometry.safeAreaInsets.bottom)
                    }
                    .padding([.top, .leading], General.outerPadding)
                    HStack(spacing: General.innerPadding) {
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color("Positive"))
                            CustomText(text: Localization.shared.getTranslation(key: "dailyQuests").uppercased(), fontSize: General.mediumFont, isBold: true).padding(.leading, General.innerPadding)
                        }
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color("Positive"))
                            CustomText(text: Localization.shared.getTranslation(key: "milestones").uppercased(), fontSize: General.mediumFont, isBold: true).padding(.leading, General.innerPadding)
                        }
                    }
                    .frame(height: General.largeHeight).padding(.horizontal, General.outerPadding)
                    HStack(spacing: General.innerPadding) {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: General.innerPadding/2) {
                                ZStack(alignment: .trailing) {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "fightMission", params: ["5"]).uppercased(), fontSize: General.smallFont)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(userProgress.dailyFightCounter)/5 * 100, 100)))%", fontSize: General.smallFont)
                                    }
                                    .padding(.all, General.innerPadding)
                                    if Float(userProgress.dailyFightCounter)/5 >= 1 && !userProgress.dailyCollected[0] {
                                        Button(action: {
                                            userProgress.missionCollect(points: 10, index: 0)
                                        }) {
                                            BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                        }
                                    }
                                }
                                .frame(height: General.largeHeight)
                                ZStack(alignment: .trailing) {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "winUsingMission", params: [userProgress.getDailyElement().name]).uppercased(), fontSize: General.smallFont)
                                        Spacer()
                                        CustomText(text: userProgress.dailyElementWin ? "100%" : "0%", fontSize: General.smallFont)
                                    }
                                    .padding(.all, General.innerPadding)
                                    if userProgress.dailyElementWin && !userProgress.dailyCollected[1] {
                                        Button(action: {
                                            userProgress.missionCollect(points: 10, index: 1)
                                        }) {
                                            BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                        }
                                    }
                                }
                                .frame(height: General.largeHeight)
                                ZStack(alignment: .trailing) {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "winMission", params: ["2"]).uppercased(), fontSize: General.smallFont)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(userProgress.dailyWinCounter)/2 * 100, 100)))%", fontSize: General.smallFont)
                                    }
                                    .padding(.all, General.innerPadding)
                                    if Float(userProgress.dailyWinCounter)/2 >= 1 && !userProgress.dailyCollected[2] {
                                        Button(action: {
                                            userProgress.missionCollect(points: 10, index: 2)
                                        }) {
                                            BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                        }
                                    }
                                }
                                .frame(height: General.largeHeight)
                                ZStack(alignment: .trailing) {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "useArtifactMission").uppercased(), fontSize: General.smallFont)
                                        Spacer()
                                        CustomText(text: userProgress.dailyArtifactUsed ? "100%" : "0%", fontSize: General.smallFont)
                                    }
                                    .padding(.all, General.innerPadding)
                                    if userProgress.dailyArtifactUsed && !userProgress.dailyCollected[3] {
                                        Button(action: {
                                            userProgress.dailyCollect(points: 10, index: 3)
                                        }) {
                                            BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                        }
                                    }
                                }
                                .frame(height: General.largeHeight)
                                ZStack(alignment: .trailing) {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "completeMission").uppercased(), fontSize: General.smallFont)
                                        Spacer()
                                        CustomText(text: "\(Int(min(dailyComplete(), 100)))%", fontSize: General.smallFont)
                                    }
                                    .padding(.all, General.innerPadding)
                                    if dailyComplete() >= 100 && !userProgress.missionCollected[4] {
                                        Button(action: {
                                            userProgress.missionCollect(points: 20, index: 4)
                                        }) {
                                            BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                        }
                                    }
                                }
                                .frame(height: General.largeHeight)
                            }
                            .padding(.leading, General.outerPadding)
                        }
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: General.innerPadding/2) {
                                ForEach(fightCounter.indices, id: \.self) { index in
                                    ZStack(alignment: .trailing) {
                                        Rectangle().fill(Color("MainPanel"))
                                            .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                        HStack {
                                            CustomText(text: Localization.shared.getTranslation(key: "fightMission", params: ["\(Int(fightCounter[index]))"]).uppercased(), fontSize: General.smallFont)
                                            Spacer()
                                            CustomText(text: "\(Int(min(Float(userProgress.fightCounter)/fightCounter[index] * 100, 100)))%", fontSize: General.smallFont)
                                        }
                                        .padding(.all, General.innerPadding)
                                        if Float(userProgress.fightCounter)/fightCounter[index] >= 1 && !userProgress.missionCollected[index] {
                                            Button(action: {
                                                userProgress.missionCollect(points: 50, index: index)
                                            }) {
                                                BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                            }
                                        }
                                    }
                                    .frame(height: General.largeHeight)
                                }
                                ForEach(winStreak.indices, id: \.self) { index in
                                    ZStack(alignment: .trailing) {
                                        Rectangle().fill(Color("MainPanel"))
                                            .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                        HStack {
                                            CustomText(text: Localization.shared.getTranslation(key: "winStreakMission", params: ["\(Int(winStreak[index]))"]).uppercased(), fontSize: General.smallFont)
                                            Spacer()
                                            CustomText(text: "\(Int(min(Float(userProgress.winStreak)/winStreak[index] * 100, 100)))%", fontSize: General.smallFont)
                                        }
                                        .padding(.all, General.innerPadding)
                                        if Float(userProgress.winStreak)/winStreak[index] >= 1 && !userProgress.missionCollected[fightCounter.count + index] {
                                            Button(action: {
                                                userProgress.missionCollect(points: 50, index: fightCounter.count + index)
                                            }) {
                                                BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                            }
                                        }
                                    }
                                    .frame(height: General.largeHeight)
                                }
                                ZStack(alignment: .trailing) {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "winAliveMission").uppercased(), fontSize: General.smallFont)
                                        Spacer()
                                        CustomText(text: userProgress.winAllAlive ? "100%" : "0%", fontSize: General.smallFont)
                                    }
                                    .padding(.all, General.innerPadding)
                                    if userProgress.winAllAlive && !userProgress.missionCollected[fightCounter.count + winStreak.count] {
                                        Button(action: {
                                            userProgress.missionCollect(points: 50, index: fightCounter.count + winStreak.count)
                                        }) {
                                            BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                        }
                                    }
                                }
                                .frame(height: General.largeHeight)
                                ZStack(alignment: .trailing) {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "weatherMission").uppercased(), fontSize: General.smallFont)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(userProgress.getWeatherAmount())/Float(Weather.allCases.count) * 100, 100)))%", fontSize: General.smallFont)
                                    }
                                    .padding(.all, General.innerPadding)
                                    if Float(userProgress.getWeatherAmount())/Float(Weather.allCases.count) >= 1 && !userProgress.missionCollected[fightCounter.count + winStreak.count + 1] {
                                        Button(action: {
                                            userProgress.missionCollect(points: 50, index: fightCounter.count + winStreak.count + 1)
                                        }) {
                                            BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                        }
                                    }
                                }
                                .frame(height: General.largeHeight)
                                ZStack(alignment: .trailing) {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "hexMission").uppercased(), fontSize: General.smallFont)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(userProgress.getHexAmount())/Float(Hexes.allCases.count) * 100, 100)))%", fontSize: General.smallFont)
                                    }
                                    .padding(.all, General.innerPadding)
                                    if Float(userProgress.getHexAmount())/Float(Hexes.allCases.count) >= 1 && !userProgress.missionCollected[fightCounter.count + winStreak.count + 2] {
                                        Button(action: {
                                            userProgress.missionCollect(points: 50, index: fightCounter.count + winStreak.count + 2)
                                        }) {
                                            BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                        }
                                    }
                                }
                                .frame(height: General.largeHeight)
                                ZStack(alignment: .trailing) {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "artifactMission").uppercased(), fontSize: General.smallFont)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(userProgress.getArtifactAmount())/Float(Artifacts.allCases.count) * 100, 100)))%", fontSize: General.smallFont)
                                    }
                                    .padding(.all, General.innerPadding)
                                    if Float(userProgress.getArtifactAmount())/Float(Artifacts.allCases.count) >= 1 && !userProgress.missionCollected[fightCounter.count + winStreak.count + 3] {
                                        Button(action: {
                                            userProgress.missionCollect(points: 50, index: fightCounter.count + winStreak.count + 3)
                                        }) {
                                            BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                        }
                                    }
                                }
                                .frame(height: General.largeHeight)
                                ZStack(alignment: .trailing) {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "fightElementMission").uppercased(), fontSize: General.smallFont)
                                        Spacer()
                                        CustomText(text: userProgress.fightOneElement ? "100%" : "0%", fontSize: General.smallFont)
                                    }
                                    .padding(.all, General.innerPadding)
                                    if userProgress.fightOneElement && !userProgress.missionCollected[fightCounter.count + winStreak.count + 4] {
                                        Button(action: {
                                            userProgress.missionCollect(points: 50, index: fightCounter.count + winStreak.count + 4)
                                        }) {
                                            BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                        }
                                    }
                                }
                                .frame(height: General.largeHeight)
                            }
                            .padding(.trailing, General.outerPadding)
                        }
                    }
                    HStack(spacing: General.innerPadding) {
                        Spacer()
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            userProgress = UserProgress()
                            SaveData.saveProgress()
                        }) {
                            BorderedButton(label: "reset", width: 155, height: General.smallHeight, isInverted: false)
                        }
                        ZStack(alignment: .trailing) {
                            Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth)
                            HStack(spacing: General.innerPadding/2) {
                                CustomText(text: userProgress.getFormattedPoints(), fontSize: General.smallFont)
                                Text("\u{f890}").font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color("Text"))
                            }
                            .padding(.trailing, General.innerPadding)
                        }
                        .frame(width: 105, height: General.smallHeight)
                    }
                    .padding([.leading, .bottom, .trailing], General.outerPadding).padding(.top, General.innerPadding)
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).rotationEffect(.degrees(180)).offset(y: transitionToggle ? -50 : -(geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            userProgress.resetDaily()
            
            let blinkInterval: Int = Int.random(in: 5 ... 10)
            blink(delay: TimeInterval(blinkInterval))
        }
        .onDisappear {
            stopBlinking = true
        }
    }
}

struct MissionsView_Previews: PreviewProvider {
    static var previews: some View {
        MissionsView(userProgress: UserProgress())
    }
}
