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
    
    let battleCounter: [Float] = [10, 50, 100]
    let winStreak: [Float] = [5, 10, 25]
    
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
                Color("Panel")
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TitlePanel().fill(Color.white).frame(width: 255, height: largeHeight).shadow(radius: 5, x: 5, y: 0)
                            CustomText(text: Localization.shared.getTranslation(key: "missiöns").uppercased(), fontColor: Color("Title"), fontSize: 16, isBold: true).padding(.all, outerPadding)
                        }
                    }
                    .padding([.top, .leading], outerPadding)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: innerPadding) {
                            ForEach(battleCounter, id: \.self) { counter in
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "bättle \(Int(counter))x").uppercased(), fontSize: 14)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(GlobalData.shared.playerProgress.battleCounter)/counter * 100, 100)))%".uppercased(), fontSize: 14)
                                    }
                                    .padding(.all, innerPadding)
                                }
                            }
                            ForEach(winStreak, id: \.self) { streak in
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "win träin \(Int(streak))x in row").uppercased(), fontSize: 14)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(GlobalData.shared.playerProgress.winStreak)/streak * 100, 100)))%".uppercased(), fontSize: 14)
                                    }
                                    .padding(.all, innerPadding)
                                }
                            }
                            ForEach(GlobalData.shared.fighters, id: \.name) { fighter in
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
                                    HStack {
                                        CustomText(text: Localization.shared.getTranslation(key: "win training 10x with " + fighter.name).uppercased(), fontSize: 14)
                                        Spacer()
                                        CustomText(text: "\(Int(min(Float(GlobalData.shared.playerProgress.fighterWins[fighter.name] ?? 0)/10 * 100, 100)))%".uppercased(), fontSize: 14)
                                    }
                                    .padding(.all, innerPadding)
                                }
                            }
                        }
                        .padding(.horizontal, outerPadding)
                    }
                    .frame(width: geometry.size.width).padding(.top, innerPadding)
                    HStack(spacing: innerPadding) {
                        Spacer()
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            GlobalData.shared.playerProgress = PlayerProgress()
                            SaveLogic.shared.save()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MissionsView().environmentObject(manager)))
                            }
                        }) {
                            BorderedButton(label: Localization.shared.getTranslation(key: "rst progress"), width: 210, height: smallHeight, isInverted: false)
                        }
                    }
                    .padding([.leading, .bottom, .trailing], outerPadding).padding(.top, innerPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).position(x: geometry.size.width/2, y: geometry.size.height - geometry.size.width/2)
                ZStack(alignment: .bottomLeading) {
                    TitlePanel().fill(Color("Background1")).frame(width: geometry.size.height - geometry.size.width).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0)).shadow(radius: 5, x: 5, y: 5)
                    TriangleA().fill(Color("Background2")).frame(height: 145).rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    Image(fileName: blink ? exampleFighter.name + "_blink" : exampleFighter.name).resizable().frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9).offset(x: transitionToggle ? -geometry.size.width * 0.9 : -15).shadow(radius: 5, x: 5, y: 0)
                        .animation(.linear(duration: 0.2).delay(0.4), value: transitionToggle)
                    VStack {
                        Button(action: {
                            AudioPlayer.shared.playCancelSound()
                            
                            transitionToggle = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                manager.setView(view: AnyView(MainView().environmentObject(manager)))
                            }
                        }) {
                            BorderedButton(label: "X", width: smallHeight, height: smallHeight, isInverted: true)
                        }
                        Spacer()
                    }
                    .padding(.all, outerPadding)
                }
                .frame(width: geometry.size.width, height: geometry.size.width).rotationEffect(.degrees(90)).offset(y: transitionToggle ? -geometry.size.width : 0)
                .animation(.linear(duration: 0.3).delay(0.2), value: transitionToggle)
            }
            ZigZag().fill(Color.black).frame(height: geometry.size.height + 50).rotationEffect(.degrees(180))
                .offset(y: transitionToggle ? -50 : -(geometry.size.height + 50)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
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

struct MissionsView_Previews: PreviewProvider {
    static var previews: some View {
        MissionsView()
    }
}

