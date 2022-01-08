//
//  OverviewView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct OverviewView: View {
    @State var fighterSelected: Bool = false
    @State var infoToggle: Bool = false
    
    @Binding var currentFighter: Fighter
    
    @Binding var overviewToggle: Bool
    @Binding var offsetX: CGFloat
    
    func getRowAmount() -> Int {
        if GlobalData.shared.allFighter.count%3 > 0 {
            return GlobalData.shared.allFighter.count/3 + 1
        } else {
            return GlobalData.shared.allFighter.count/3
        }
    }
    
    func getSubArray(row: Int) -> [Fighter] {
        if (3 + row * 3) < GlobalData.shared.allFighter.count {
            let rowArray = GlobalData.shared.allFighter[row * 3 ..< 3 + row * 3]
            return Array(rowArray)
        } else {
            let rowArray = GlobalData.shared.allFighter[row * 3 ..< GlobalData.shared.allFighter.count]
            return Array(rowArray)
        }
    }
    
    func isSelected(fighter: Fighter) -> Bool {
        if fighterSelected {
            return fighter.name == currentFighter.name
        } else {
            return false
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if fighterSelected {
                    HStack(alignment: .top) {
                        Button(infoToggle ? "X" : "?") {
                            infoToggle = !infoToggle
                        }
                        .buttonStyle(GrowingButton(width: 40))
                        Spacer()
                        ZStack {
                            Color.red
                            VStack(alignment: .leading, spacing: 5) {
                                CustomText(key: currentFighter.name)
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 5) {
                                        BaseOverviewView(base: currentFighter.base).padding(.bottom, 5)
                                        ForEach(currentFighter.skills, id: \.self) { skill in
                                            DetailedSkillView(skill: skill)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: 345).offset(x: infoToggle ? 0 : 224).animation(.linear(duration: 0.2), value: infoToggle)
                    }
                    .padding(.all, 15)
                }
                ZStack(alignment: .trailing) {
                    HStack(spacing: 0) {
                        Spacer()
                        Triangle().fill(Color.pink).frame(width: 134)
                        Rectangle().fill(Color.pink).frame(width: 315 + geometry.safeAreaInsets.trailing)
                    }
                    .offset(x: geometry.safeAreaInsets.trailing)
                    VStack(alignment: .leading, spacing: 0) {
                        CustomText(key: "Overview").frame(height: 60).padding([.top, .leading], 15)
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 8) {
                                ForEach(0 ..< self.getRowAmount()) { row in
                                    HStack(spacing: 8) {
                                        ForEach(self.getSubArray(row: row), id: \.name) { fighter in
                                            RectangleFighterView(fighter: fighter, isSelected: self.isSelected(fighter: fighter))
                                                .onTapGesture {
                                                    print(fighter.name)
                                                    fighterSelected = true
                                                    currentFighter = fighter
                                            }
                                        }
                                        ForEach(0 ..< 3 - self.getSubArray(row: row).count) { _ in
                                            Color.clear
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                        Spacer().frame(height: 10)
                        HStack(spacing: 5) {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: 160, height: 40)
                                HStack {
                                    Button("<") {
                                        print("Button pressed!")
                                    }
                                    Spacer()
                                    CustomText(key: "All Types")
                                    Spacer()
                                    Button(">") {
                                        print("Button pressed!")
                                    }
                                }
                                .frame(width: 130).padding(.horizontal, 15)
                            }
                            Button("X") {
                                fighterSelected = false
                                offsetX = -449
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    overviewToggle = false
                                }
                            }
                            .buttonStyle(GrowingButton(width: 40))
                        }
                        .padding(.trailing, 15)
                    }
                    .frame(width: 340).padding(.vertical, 15)
                }
                .padding(.trailing, offsetX).animation(.linear(duration: 0.2), value: offsetX).offset(x: infoToggle ? 449 : 0).animation(.linear(duration: 0.2), value: infoToggle)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            offsetX = 0
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(currentFighter: Binding.constant(exampleFighter), overviewToggle: Binding.constant(true), offsetX: Binding.constant(0))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
