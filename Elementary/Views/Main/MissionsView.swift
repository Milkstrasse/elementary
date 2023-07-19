//
//  MissionsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 20.10.22.
//

import SwiftUI

struct MissionsView: View {
    @EnvironmentObject var manager: ViewManager
    
    @State var missionManager: MissionManager
    @State var userProgress: UserProgress
    
    @State var transitionToggle: Bool = true
    
    @State var blink: Bool = false
    
    /// Sends signal to blink.
    /// - Parameter delay: The delay between blinks
    func blink(delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            blink = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                blink = false
                
                let blinkInterval: Int = Int.random(in: 5 ... 10)
                blink(delay: TimeInterval(blinkInterval))
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
                            
                            GlobalData.shared.missionManager = missionManager
                            
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
                                ForEach(missionManager.quests.indices, id: \.self) { index in
                                    ZStack(alignment: .trailing) {
                                        Rectangle().fill(Color("MainPanel"))
                                            .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                        HStack {
                                            CustomText(text: Localization.shared.getTranslation(key: missionManager.quests[index].title, params: missionManager.quests[index].params).uppercased(), fontSize: General.smallFont)
                                            Spacer()
                                            CustomText(text: "\(missionManager.quests[index].completion)%", fontSize: General.smallFont)
                                        }
                                        .padding(.all, General.innerPadding)
                                        if missionManager.quests[index].completion >= 100 && !userProgress.questCollected[index] {
                                            Button(action: {
                                                userProgress.missionCollect(mission: &missionManager.quests[index], index: index)
                                                missionManager.unclaimedRewards -= 1
                                            }) {
                                                BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                            }
                                        }
                                    }
                                    .frame(height: General.largeHeight)
                                }
                            }
                            .padding(.leading, General.outerPadding)
                        }
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: General.innerPadding/2) {
                                ForEach(missionManager.milestones.indices, id: \.self) { index in
                                    ZStack(alignment: .trailing) {
                                        Rectangle().fill(Color("MainPanel"))
                                            .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                        HStack {
                                            CustomText(text: Localization.shared.getTranslation(key: missionManager.milestones[index].title, params: missionManager.milestones[index].params).uppercased(), fontSize: General.smallFont)
                                            Spacer()
                                            CustomText(text: "\(missionManager.milestones[index].completion)%", fontSize: General.smallFont)
                                        }
                                        .padding(.all, General.innerPadding)
                                        if missionManager.milestones[index].completion >= 100 && !userProgress.milestoneCollected[index + userProgress.questCollected.count] {
                                            Button(action: {
                                                userProgress.missionCollect(mission: &missionManager.milestones[index], index: index + userProgress.questCollected.count)
                                                missionManager.unclaimedRewards -= 1
                                            }) {
                                                BasicButton(label: Localization.shared.getTranslation(key: "collect"), width: 110, height: 35, fontSize: General.smallFont, isInverted: true).padding(.trailing, 7.5)
                                            }
                                        }
                                    }
                                    .frame(height: General.largeHeight)
                                }
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
                            
                            missionManager.resetAll(userProgress: userProgress)
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
            ZigZag().fill(Color("Positive")).frame(height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).offset(y: transitionToggle ? -50 : geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom + 100).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            userProgress.resetDaily()
            
            let blinkInterval: Int = Int.random(in: 5 ... 10)
            blink(delay: TimeInterval(blinkInterval))
        }
    }
}

struct MissionsView_Previews: PreviewProvider {
    static var previews: some View {
        MissionsView(missionManager: MissionManager(), userProgress: UserProgress())
    }
}
