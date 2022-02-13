//
//  OverviewView.swift
//  Witchery
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct OverviewView: View {
    @State var witchSelected: Bool = false
    @State var infoToggle: Bool = false
    
    @Binding var currentWitch: Witch
    @State var currentArray: [Witch] = GlobalData.shared.witches
    @State var currentElement: Int = -1
    
    @Binding var overviewToggle: Bool
    @Binding var offsetX: CGFloat
    
    /// Returns the amount of rows needed to display all relevant witches.
    /// - Returns: Returns the amount of rows needed
    func getRowAmount() -> Int {
        if currentArray.count%3 > 0 {
            return currentArray.count/3 + 1
        } else {
            return currentArray.count/3
        }
    }
    
    /// Returns an array of witches depending on the current filter criteria.
    /// - Parameter row: The current row
    /// - Returns: Returns an filtered array of witches
    func getSubArray(row: Int) -> [Witch] {
        if (3 + row * 3) < currentArray.count {
            let rowArray = currentArray[row * 3 ..< 3 + row * 3]
            return Array(rowArray)
        } else {
            let rowArray = currentArray[row * 3 ..< currentArray.count]
            return Array(rowArray)
        }
    }
    
    /// Applies filter critera and set the array of witches.
    /// - Parameter element: The elemental criteria
    func setElementalArray(element: Element?) {
        if element == nil {
            currentArray = GlobalData.shared.witches
        } else {
            var elementals: [Witch] = []
            
            for witch in GlobalData.shared.witches {
                if element!.name == witch.getElement().name {
                    elementals.append(witch)
                }
            }
            
            currentArray = elementals
        }
    }
    
    /// Returns wether the witch is selected or not.
    /// - Parameter witch: The witch in question
    /// - Returns: Returns wether the witch is selected or not
    func isSelected(witch: Witch) -> Bool {
        if witchSelected {
            return witch.name == currentWitch.name
        } else {
            return false
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if witchSelected {
                    HStack(alignment: .top) {
                        Button(infoToggle ? "X" : "?") {
                            AudioPlayer.shared.playStandardSound()
                            infoToggle = !infoToggle
                        }
                        .buttonStyle(BasicButton(width: 40))
                        Spacer()
                        ZStack {
                            Color("background")
                            VStack(alignment: .leading, spacing: 0) {
                                ZStack(alignment: .leading) {
                                    Rectangle().fill(Color("outline")).frame(height: 1)
                                    CustomText(key: currentWitch.name, fontSize: 18).padding(.horizontal, 10).background(Color("background")).offset(x: 10)
                                }
                                .frame(height: 60)
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 5) {
                                        BaseWitchesOverviewView(base: currentWitch.getModifiedBase()).padding(.bottom, 5)
                                        ForEach(currentWitch.spells, id: \.self) { spell in
                                            DetailedActionView(title: spell.name, description: spell.name + "Descr", symbol: spell.element.symbol)
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
                            CustomText(key: "overview", fontSize: 18).padding(.horizontal, 10).background(Color("background")).offset(x: 10)
                        }
                        .frame(height: 60).padding(.horizontal, 15).padding(.leading, 10)
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 8) {
                                ForEach(0 ..< self.getRowAmount(), id:\.self) { row in
                                    HStack(spacing: 8) {
                                        ForEach(self.getSubArray(row: row), id: \.name) { witch in
                                            Button(action: {
                                                AudioPlayer.shared.playConfirmSound()
                                                witchSelected = true
                                                currentWitch = witch
                                            }) {
                                                RectangleWitchView(witch: witch, isSelected: self.isSelected(witch: witch))
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
                                    CustomText(key: currentElement == -1 ? "allElements" : GlobalData.shared.elementArray[currentElement].name, fontSize: 14).frame(width: 65)
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
                                AudioPlayer.shared.playCancelSound()
                                witchSelected = false
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

struct WitchesOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(currentWitch: Binding.constant(exampleWitch), overviewToggle: Binding.constant(true), offsetX: Binding.constant(0))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
