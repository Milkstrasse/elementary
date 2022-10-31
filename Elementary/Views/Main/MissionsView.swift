//
//  MissionsView.swift
//  Elementary
//
//  Created by Janice Hablützel on 20.10.22.
//

import SwiftUI

struct MissionsView: View {
    @EnvironmentObject var manager: ViewManager
    
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
            
            GlobalData.shared.userProgress.resetDaily()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                blink = false
                
                if !stopBlinking {
                    let blinkInterval: Int = Int.random(in: 5 ... 10)
                    blink(delay: TimeInterval(blinkInterval))
                }
            }
        }
    }
    
    func dailyComplete() -> Float {
        let userProgress: UserProgress = GlobalData.shared.userProgress
        
        var counter: Float = Float(userProgress.dailyFightCounter)/5
        counter += Float(userProgress.dailyElementCounter)/2
        counter = counter/2 * 100
        
        return counter
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color("Panel")
                VStack(alignment: .leading, spacing: innerPadding) {
                    HStack(alignment: .top) {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            SaveData.save()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MainView().environmentObject(manager)))
                            }
                        }) {
                            BorderedButton(label: "X", width: smallHeight, height: smallHeight, isInverted: false)
                        }
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color.white).frame(width: 255, height: largeHeight).shadow(radius: 5, x: 5, y: 0)
                            CustomText(text: Localization.shared.getTranslation(key: "missions").uppercased(), fontColor: Color("Title"), fontSize: 16, isBold: true).padding(.all, outerPadding)
                        }
                    }
                    .padding([.top, .leading], outerPadding)
                    HStack(spacing: innerPadding) {
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color("Positive"))
                            CustomText(text: Localization.shared.getTranslation(key: "dailyQuests").uppercased(), fontSize: 16, isBold: true).padding(.leading, innerPadding)
                        }
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color("Positive"))
                            CustomText(text: Localization.shared.getTranslation(key: "milestones").uppercased(), fontSize: 16, isBold: true).padding(.leading, innerPadding)
                        }
                    }
                    .frame(height: largeHeight).padding(.horizontal, outerPadding)
                    HStack(spacing: innerPadding) {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: innerPadding) {
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "fightMission", params: ["5"]).uppercased(), fontSize: 14)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(GlobalData.shared.userProgress.dailyFightCounter)/5 * 100, 100)))%", fontSize: 14)
                                    }
                                    .padding(.all, innerPadding)
                                }
                                .frame(height: largeHeight)
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "winUsingMission", params: [GlobalData.shared.userProgress.getDailyElement().name, "2"]).uppercased(), fontSize: 14)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(GlobalData.shared.userProgress.dailyElementCounter)/2 * 100, 100)))%", fontSize: 14)
                                    }
                                    .padding(.all, innerPadding)
                                }
                                .frame(height: largeHeight)
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "completeMission", params: ["5"]).uppercased(), fontSize: 14)
                                        Spacer()
                                        CustomText(text: "\(Int(min(dailyComplete(), 100)))%", fontSize: 14)
                                    }
                                    .padding(.all, innerPadding)
                                }
                                .frame(height: largeHeight)
                            }
                            .padding(.leading, outerPadding)
                        }
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: innerPadding) {
                                ForEach(fightCounter, id: \.self) { counter in
                                    ZStack {
                                        Rectangle().fill(Color("Panel"))
                                            .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                        HStack {
                                            CustomText(text: Localization.shared.getTranslation(key: "fightMission", params: ["\(Int(counter))"]).uppercased(), fontSize: 14)
                                            Spacer()
                                            CustomText(text: "\(Int(min(Float(GlobalData.shared.userProgress.fightCounter)/counter * 100, 100)))%", fontSize: 14)
                                        }
                                        .padding(.all, innerPadding)
                                    }
                                    .frame(height: largeHeight)
                                }
                                ForEach(winStreak, id: \.self) { streak in
                                    ZStack {
                                        Rectangle().fill(Color("Panel"))
                                            .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                        HStack {
                                            CustomText(text: Localization.shared.getTranslation(key: "winMission", params: ["\(Int(streak))"]).uppercased(), fontSize: 14)
                                            Spacer()
                                            CustomText(text: "\(Int(min(Float(GlobalData.shared.userProgress.winStreak)/streak * 100, 100)))%", fontSize: 14)
                                        }
                                        .padding(.all, innerPadding)
                                    }
                                    .frame(height: largeHeight)
                                }
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "winAliveMission").uppercased(), fontSize: 14)
                                        Spacer()
                                        CustomText(text: GlobalData.shared.userProgress.winAllAlive ? "100%" : "0%", fontSize: 14)
                                    }
                                    .padding(.all, innerPadding)
                                }
                                .frame(height: largeHeight)
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "weatherMission").uppercased(), fontSize: 14)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(GlobalData.shared.userProgress.getWeatherAmount())/10 * 100, 100)))%", fontSize: 14)
                                    }
                                    .padding(.all, innerPadding)
                                }
                                .frame(height: largeHeight)
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "hexMission").uppercased(), fontSize: 14)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(GlobalData.shared.userProgress.getHexAmount())/10 * 100, 100)))%", fontSize: 14)
                                    }
                                    .padding(.all, innerPadding)
                                }
                                .frame(height: largeHeight)
                            }
                            .padding(.trailing, outerPadding)
                        }
                    }
                    HStack(spacing: innerPadding) {
                        Spacer()
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            GlobalData.shared.userProgress = UserProgress()
                            SaveData.save()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MissionsView().environmentObject(manager)))
                            }
                        }) {
                            BorderedButton(label: Localization.shared.getTranslation(key: "reset"), width: 210, height: smallHeight, isInverted: false)
                        }
                    }
                    .padding([.leading, .bottom, .trailing], outerPadding).padding(.top, innerPadding)
                }
                .frame(width: geometry.size.height, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height/2)
            }
            ZigZag().fill(Color.black).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
        }
        .onAppear {
            transitionToggle = false
            
            GlobalData.shared.userProgress.resetDaily()
            
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
        MissionsView()
    }
}
