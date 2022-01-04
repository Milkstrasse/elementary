//
//  FightSelectionView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct FightSelectionView: View {
    @EnvironmentObject var currentView: CurrentView
    
    @State var transitionToggle: Bool = true
    
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            ZStack {
                HStack(spacing: 0) {
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            Button("Ready") {
                                currentView.viewName = "Fight"
                            }
                            .buttonStyle(GrowingButton(width: 135))
                            Button("X") {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
                            Button("Ready") {
                                currentView.viewName = "Fight"
                            }
                            .buttonStyle(GrowingButton(width: 135))
                            Button("X") {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
                    LeftSelectionView()
                    Text("------- X -------").rotationEffect(.degrees(90)).fixedSize().frame(width: 60)
                    RightSelectionView()
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            GeometryReader { geometry in
                ZigZag().fill(Color.purple).frame(height: geometry.size.height + 65).rotationEffect(.degrees(180))
                    .offset(y: transitionToggle ? -65 : -(geometry.size.height + 65)).animation(.linear(duration: 0.2), value: transitionToggle).ignoresSafeArea()
            }
        }
        .onAppear {
            transitionToggle = false
        }
    }
}

struct FightSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FightSelectionView()
.previewInterfaceOrientation(.landscapeRight)
    }
}

struct FighterView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(Color.blue)
            Image("magicalgirl_1").resizable().scaleEffect(6.4).aspectRatio(contentMode: .fit).offset(y: 95).clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .frame(width: 70, height: 70)
    }
}
