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
    
    @Binding var offsetX: CGFloat
    @Binding var overviewToggle: Bool
    
    /// Returns the amount of rows needed to display all relevant witches.
    /// - Returns: Returns the amount of rows needed
    func getRowAmount() -> Int {
        if currentArray.count%4 > 0 {
            return currentArray.count/4 + 1
        } else {
            return currentArray.count/4
        }
    }
    
    /// Returns an array of witches depending on the current filter criteria.
    /// - Parameter row: The current row
    /// - Returns: Returns an filtered array of witches
    func getSubArray(row: Int) -> [Witch] {
        if (4 + row * 4) < currentArray.count {
            let rowArray = currentArray[row * 4 ..< 4 + row * 4]
            return Array(rowArray)
        } else {
            let rowArray = currentArray[row * 4 ..< currentArray.count]
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
            VStack(alignment: .leading) {
                Button(infoToggle ? "X" : "?") {
                    if infoToggle {
                        AudioPlayer.shared.playCancelSound()
                        offsetX = offsetX/2
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            infoToggle = false
                        }
                    } else {
                        AudioPlayer.shared.playStandardSound()
                        infoToggle = true
                    }
                }
                .buttonStyle(BasicButton(width: 45))
                .padding(.all, 15)
                Spacer()
                ZStack {
                    VStack(spacing: 10) {
                        Text(Localization.shared.getTranslation(key: "overview")).foregroundColor(Color.white).frame(maxWidth: .infinity, alignment: .leading).frame(height: 60)
                            .padding(.horizontal, 15)
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 10) {
                                ForEach(0 ..< self.getRowAmount(), id:\.self) { row in
                                    HStack(spacing: 10) {
                                        ForEach(self.getSubArray(row: row), id: \.self) { witch in
                                            Button(action: {
                                                AudioPlayer.shared.playConfirmSound()
                                                witchSelected = true
                                                currentWitch = witch
                                            }) {
                                                Button(action: {
                                                    AudioPlayer.shared.playConfirmSound()
                                                    witchSelected = true
                                                    currentWitch = witch
                                                }) {
                                                    SquareWitchView(witch: witch, isSelected: self.isSelected(witch: witch), size: (geometry.size.width - 60)/4)
                                                }
                                            }
                                        }
                                        ForEach(0 ..< 4 - self.getSubArray(row: row).count, id:\.self) { _ in
                                            Color.clear
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: geometry.size.width - 85, height: 45)
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
                                    .buttonStyle(ClearBasicButton(width: 45, height: 45))
                                    Spacer()
                                    Text(currentElement == -1 ? "allElements" : GlobalData.shared.elementArray[currentElement].name).frame(width: 90)
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
                                    .buttonStyle(ClearBasicButton(width: 45, height: 45))
                                }
                            }
                            Button(Localization.shared.getTranslation(key: "X")) {
                                AudioPlayer.shared.playCancelSound()
                                witchSelected = false
                                offsetX = 0
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    overviewToggle = false
                                }
                            }
                            .buttonStyle(BasicButton(width: 45))
                        }
                        .padding(.horizontal, 15)
                    }
                    .padding(.vertical, 15).offset(x: geometry.size.width - offsetX).animation(.linear(duration: 0.2), value: offsetX).frame(height: 355)
                    if infoToggle {
                        VStack(spacing: 10) {
                            Text(Localization.shared.getTranslation(key: currentWitch.name)).foregroundColor(Color.white).frame(maxWidth: .infinity, alignment: .leading).frame(height: 60)
                                .padding(.horizontal, 15)
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 5) {
                                    BaseWitchOverviewView(base: currentWitch.getModifiedBase(), bgColor: Color("health")).padding(.bottom, 5)
                                    ForEach(currentWitch.spells, id: \.self) { spell in
                                        DetailedActionView(title: spell.name, description: spell.name + "Descr", symbol: spell.element.symbol, inverted: true)
                                    }
                                }
                                .padding(.horizontal, 15)
                            }
                        }
                        .padding(.vertical, 15).offset(x: 2 * geometry.size.width - offsetX).animation(.linear(duration: 0.2), value: offsetX).frame(height: 355)
                        .onAppear {
                            offsetX = 2 * offsetX
                        }
                    }
                }
            }
            .onAppear {
                offsetX = geometry.size.width
            }
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(currentWitch: Binding.constant(exampleWitch), offsetX: Binding.constant(0), overviewToggle: Binding.constant(true))
    }
}
