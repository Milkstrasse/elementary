//
//  FightSelectionView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct FightSelectionView: View {
    @EnvironmentObject var currentView: CurrentView
    
    @State var leftFighters: [Fighter?] = [nil, nil, nil, nil]
    @State var rightFighters: [Fighter?] = [nil, nil, nil, nil]
    
    @State var transitionToggle: Bool = true
    
    func tempCheck() -> Bool {
        for fighter in leftFighters {
            if fighter != nil {
                for fighter in rightFighters {
                    if fighter != nil {
                       return true
                    }
                }
            }
        }
        
        return false
    }
    
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            ZStack {
                HStack(spacing: 0) {
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            Button("Ready") {
                                if tempCheck() {
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        currentView.scene = CurrentView.Scene.fight
                                    }
                                }
                            }
                            .buttonStyle(GrowingButton(width: 135))
                            Button("X") {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    currentView.scene = CurrentView.Scene.main
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
                                if tempCheck() {
                                    transitionToggle = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        currentView.scene = CurrentView.Scene.fight
                                    }
                                }
                            }
                            .buttonStyle(GrowingButton(width: 135))
                            Button("X") {
                                transitionToggle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    currentView.scene = CurrentView.Scene.main
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
                    LeftSelectionView(fighters: $leftFighters)
                    Text("------- X -------").rotationEffect(.degrees(90)).fixedSize().frame(width: 60)
                    RightSelectionView(fighters: $rightFighters)
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

struct FightSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FightSelectionView()
.previewInterfaceOrientation(.landscapeRight)
    }
}
