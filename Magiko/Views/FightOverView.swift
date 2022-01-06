//
//  FightOverView.swift
//  Magiko
//
//  Created by Janice Hablützel on 06.01.22.
//

import SwiftUI

struct FightOverView: View {
    @EnvironmentObject var currentView: CurrentView
    
    let leftFighters: [Fighter?] = [nil, nil, nil, nil]
    let rightFighters: [Fighter?] = [nil, nil, nil, nil]
    
    @State var transitionToggle: Bool = true
    
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            ZStack {
                HStack(spacing: 0) {
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            Button("Rematch") {
                            }
                            .buttonStyle(GrowingButton(width: 135))
                            Button("X") {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    currentView.viewName = "Main"
                                }
                            }
                            .buttonStyle(GrowingButton(width: 40))
                        }
                        .rotationEffect(.degrees(90)).frame(width: 40, height: 170)
                    }
                    Spacer()
                    VStack {
                        HStack(spacing: 5) {
                            Button("Rematch") {
                            }
                            .buttonStyle(GrowingButton(width: 135))
                            Button("X") {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    currentView.viewName = "Main"
                                }
                            }
                            .buttonStyle(GrowingButton(width: 40))
                        }
                        .rotationEffect(.degrees(-90)).frame(width: 40, height: 170)
                        Spacer()
                    }
                }
                .padding(.all, 15).edgesIgnoringSafeArea(.bottom)
                HStack(spacing: 0) {
                    LeftFightOverView(fighters: leftFighters)
                    Text("------- X -------").rotationEffect(.degrees(90)).fixedSize().frame(width: 60)
                    RightFightOverView(fighters: rightFighters)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            GeometryReader { geometry in
                ZigZag().fill(Color.purple).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
                    .offset(y: transitionToggle ? -65 : -(geometry.size.height + 65)).animation(.linear(duration: 0.3), value: transitionToggle).ignoresSafeArea()
            }
        }
        .onAppear {
            transitionToggle = false
        }
    }
}

struct LeftFightOverView: View {
    let fighters: [Fighter?]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(0 ..< 4) { index in
                                FighterView(fighter: fighters[index], isSelected: false)
                            }
                        }
                        .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct RightFightOverView: View {
    let fighters: [Fighter?]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                HStack {
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(0 ..< 4) { index in
                                FighterView(fighter: fighters[index], isSelected: false)
                            }
                        }
                        .rotationEffect(.degrees(-90)).frame(width: 70, height: 295)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct FightOverView_Previews: PreviewProvider {
    static var previews: some View {
        FightOverView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
