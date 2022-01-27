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
    @State var currentArray: [Fighter] = GlobalData.shared.fighters
    @State var currentElement: Int = -1
    
    @Binding var overviewToggle: Bool
    @Binding var offsetX: CGFloat
    
    func getRowAmount() -> Int {
        if currentArray.count%3 > 0 {
            return currentArray.count/3 + 1
        } else {
            return currentArray.count/3
        }
    }
    
    func getSubArray(row: Int) -> [Fighter] {
        if (3 + row * 3) < currentArray.count {
            let rowArray = currentArray[row * 3 ..< 3 + row * 3]
            return Array(rowArray)
        } else {
            let rowArray = currentArray[row * 3 ..< currentArray.count]
            return Array(rowArray)
        }
    }
    
    func setElementalArray(element: Element?) {
        if element == nil {
            currentArray = GlobalData.shared.fighters
        } else {
            var elementals: [Fighter] = []
            
            for fighter in GlobalData.shared.fighters {
                if element!.name == fighter.element.name {
                    elementals.append(fighter)
                }
            }
            
            currentArray = elementals
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
                            AudioPlayer.shared.playStandardSound()
                            infoToggle = !infoToggle
                        }
                        .buttonStyle(BasicButton(width: 40))
                        Spacer()
                        ZStack {
                            Color("background")
                            VStack(alignment: .leading, spacing: 5) {
                                CustomText(key: currentFighter.name)
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 5) {
                                        BaseOverviewView(base: currentFighter.base).padding(.bottom, 5)
                                        ForEach(currentFighter.skills, id: \.self) { skill in
                                            DetailedActionView(title: skill.name, description: skill.name + "Descr", symbol: skill.element.symbol)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: geometry.size.height - 30).offset(x: infoToggle ? 0 : 225).animation(.linear(duration: 0.2), value: infoToggle)
                    }
                    .padding(.all, 15)
                }
                ZStack(alignment: .trailing) {
                    HStack(spacing: 0) {
                        Spacer()
                        ZStack(alignment: .trailing) {
                            Triangle().fill(Color("outline")).offset(x: -1)
                            Triangle().fill(Color("background"))
                        }
                        Rectangle().fill(Color("background")).frame(width: 315 + geometry.safeAreaInsets.trailing)
                    }
                    .offset(x: geometry.safeAreaInsets.trailing)
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color("outline")).frame(height: 1)
                            CustomText(key: "overview").padding(.horizontal, 10).background(Color("background")).offset(x: 10)
                        }
                        .frame(height: 60).padding(.horizontal, 15).padding(.leading, 10)
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 8) {
                                ForEach(0 ..< self.getRowAmount(), id:\.self) { row in
                                    HStack(spacing: 8) {
                                        ForEach(self.getSubArray(row: row), id: \.name) { fighter in
                                            Button(action: {
                                                AudioPlayer.shared.playConfirmSound()
                                                fighterSelected = true
                                                currentFighter = fighter
                                            }) {
                                                RectangleFighterView(fighter: fighter, isSelected: self.isSelected(fighter: fighter))
                                            }
                                        }
                                        ForEach(0 ..< 3 - self.getSubArray(row: row).count, id:\.self) { _ in
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
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: 160, height: 40)
                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: 160, height: 40)
                                HStack {
                                    Button("<") {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if currentElement < 0 {
                                            currentElement = GlobalData.shared.elementArray.count - 1
                                        } else {
                                            currentElement -= 1
                                        }
                                        
                                        setElementalArray(element: currentElement == -1 ? nil : GlobalData.shared.elementArray[currentElement])
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                    Spacer()
                                    CustomText(key: currentElement == -1 ? "allTypes" : GlobalData.shared.elementArray[currentElement].name.lowercased()).frame(width: 65)
                                    Spacer()
                                    Button(">") {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        if currentElement >= GlobalData.shared.elementArray.count - 1 {
                                            currentElement = -1
                                        } else {
                                            currentElement += 1
                                        }
                                        
                                        setElementalArray(element: currentElement == -1 ? nil : GlobalData.shared.elementArray[currentElement])
                                    }
                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                }
                                .frame(width: 145)
                            }
                            Button("X") {
                                AudioPlayer.shared.playStandardSound()
                                fighterSelected = false
                                offsetX = -450
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    overviewToggle = false
                                }
                            }
                            .buttonStyle(BasicButton(width: 40))
                        }
                        .padding(.trailing, 15)
                    }
                    .frame(width: 340).padding(.vertical, 15)
                }
                .padding(.trailing, offsetX).animation(.linear(duration: 0.2), value: offsetX).offset(x: infoToggle ? 316 + geometry.safeAreaInsets.trailing + geometry.size.height/2.75 : 0).animation(.linear(duration: 0.2), value: infoToggle)
            }
            .ignoresSafeArea(.all, edges: .bottom)
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
