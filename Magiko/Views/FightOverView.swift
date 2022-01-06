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
                        .rotationEffect(.degrees(90)).frame(width: 40, height: 180)
                    }
                    HStack {
                        HStack(spacing: 0) {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: 109)
                                ZStack {
                                    Text("Game Over Messagefdfdsf").fixedSize().frame(width: 250, height: 79, alignment: .topLeading)
                                }
                                .frame(width: 79, height: 250).padding(.all, 15).rotationEffect(.degrees(90))
                            }
                            .frame(width: 109)
                            SmallTriangle().fill(Color.yellow).frame(width: 14, height: 26).offset(y: 113).rotationEffect(.degrees(180))
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            HStack(spacing: 5) {
                                ForEach(0 ..< 4) { index in
                                    FighterView(fighter: leftFighters[index], isSelected: false)
                                }
                            }
                            .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                            Spacer()
                        }
                    }
                    .padding(.leading, 10)
                    Text("------- X -------").rotationEffect(.degrees(90)).fixedSize().frame(width: 60)
                    HStack {
                        VStack {
                            Spacer()
                            HStack(spacing: 5) {
                                ForEach(0 ..< 4) { index in
                                    FighterView(fighter: rightFighters[index], isSelected: false)
                                }
                            }
                            .rotationEffect(.degrees(-90)).frame(width: 70, height: 295)
                            Spacer()
                        }
                        Spacer()
                        HStack(spacing: 0) {
                            SmallTriangle().fill(Color.yellow).frame(width: 14, height: 26).offset(y: 113)
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: 109)
                                ZStack {
                                    Text("Game Over Messagefdfdsf").fixedSize().frame(width: 250, height: 79, alignment: .topLeading)
                                }
                                .frame(width: 79, height: 250).padding(.all, 15).rotationEffect(.degrees(-90))
                            }
                            .frame(width: 109)
                        }
                    }
                    .padding(.trailing, 10)
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
                        .rotationEffect(.degrees(-90)).frame(width: 40, height: 180)
                        Spacer()
                    }
                }
                .padding(.all, 15)
            }
            .edgesIgnoringSafeArea(.bottom)
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

struct FightOverView_Previews: PreviewProvider {
    static var previews: some View {
        FightOverView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
