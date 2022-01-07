//
//  LeftSelectionView.swift
//  Magiko
//
//  Created by Janice Hablützel on 04.01.22.
//

import SwiftUI

struct LeftSelectionView: View {
    @Binding var fighters: [Fighter?]
    @State var selectedSlot: Int = -1
    
    @State var selectionToggle: Bool = false
    @State var infoToggle: Bool = false
    
    @State var offsetX: CGFloat = 189
    
    func getOffset() -> CGFloat {
        switch selectedSlot {
        case 0:
            return 113
        case 1:
            return 38
        case 2:
            return -38
        case 3:
            return -113
        default:
            return 0
        }
    }
    
    func isSelected(fighter: Fighter?) -> Bool {
        if fighter == nil {
            return false
        }
        
        for selectedFighter in fighters {
            if fighter?.name == selectedFighter?.name {
                return true
            }
        }
        
        return false
    }
    
    func getFirstHalf() -> [Fighter?] {
        if GlobalData.shared.allFighter.count%2 == 0 {
            let rowArray = GlobalData.shared.allFighter[0 ..< GlobalData.shared.allFighter.count/2]
            return Array(rowArray)
        } else {
            let rowArray = GlobalData.shared.allFighter[0 ..< GlobalData.shared.allFighter.count/2 + 1]
            return Array(rowArray)
        }
    }
    
    func getSecondHalf() -> [Fighter?] {
        if GlobalData.shared.allFighter.count%2 == 0 {
            let rowArray = GlobalData.shared.allFighter[GlobalData.shared.allFighter.count/2 ..< GlobalData.shared.allFighter.count]
            return Array(rowArray)
        } else {
            let rowArray = GlobalData.shared.allFighter[GlobalData.shared.allFighter.count/2 + 1 ..< GlobalData.shared.allFighter.count]
            return Array(rowArray)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(0 ..< 4) { index in
                                Button(action: {
                                    if selectedSlot == index {
                                        selectedSlot = -1
                                        offsetX = 189
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            selectionToggle = false
                                            infoToggle = false
                                        }
                                    } else {
                                        selectedSlot = index
                                        
                                        if fighters[index] != nil {
                                            selectionToggle = false
                                            infoToggle = true
                                        } else {
                                            infoToggle = false
                                            selectionToggle = true
                                        }
                                    }
                                }) {
                                    FighterView(fighter: fighters[index], isSelected: false)
                                }
                            }
                        }
                        .rotationEffect(.degrees(90)).frame(width: 70, height: 295)
                        Spacer()
                    }
                }
            }
            if selectionToggle || infoToggle {
                HStack(spacing: 0) {
                    ZStack(alignment: .trailing) {
                        Rectangle().fill(Color.pink).frame(width: 175 + geometry.safeAreaInsets.leading)
                        if selectionToggle {
                            VStack {
                                ScrollView(.vertical, showsIndicators: false) {
                                    HStack(alignment: .top, spacing: 5) {
                                        VStack(spacing: 5) {
                                            ForEach(self.getFirstHalf(), id: \.?.name) { fighter in
                                                FighterView(fighter: fighter, isSelected: self.isSelected(fighter: fighter)).rotationEffect(.degrees(90))
                                                    .onTapGesture {
                                                        if !isSelected(fighter: fighter) {
                                                            fighters[selectedSlot] = fighter
                                                        }
                                                    }
                                            }
                                        }
                                        VStack(spacing: 5) {
                                            ForEach(self.getSecondHalf(), id: \.?.name) { fighter in
                                                FighterView(fighter: fighter, isSelected: self.isSelected(fighter: fighter)).rotationEffect(.degrees(90))
                                                    .onTapGesture {
                                                        if !isSelected(fighter: fighter) {
                                                            fighters[selectedSlot] = fighter
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                }
                                .clipped()
                            }
                            .padding(.vertical, 15)
                        } else if infoToggle {
                            VStack {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .top, spacing: 5) {
                                        VStack(spacing: 5) {
                                            Button("Remove") {
                                                fighters[selectedSlot] = nil
                                                
                                                selectionToggle = true
                                                infoToggle = false
                                            }
                                            .buttonStyle(GrowingButton(width: geometry.size.height - 30 - 215 - 5)).rotationEffect(.degrees(-90)).frame(width: 40, height: geometry.size.height - 30 - 215 - 5)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5).fill(Color.blue).frame(width: 40, height: 215)
                                                HStack(spacing: 0) {
                                                    Button("<") {
                                                    }
                                                    .buttonStyle(ClearGrowingButton(width: 40, height: 40))
                                                    Text("Loadout").fixedSize().frame(width: 120)
                                                    Button(">") {
                                                    }
                                                    .buttonStyle(ClearGrowingButton(width: 40, height: 40))
                                                }.rotationEffect(.degrees(-90)).frame(width: 40, height: 215)
                                            }
                                        }
                                        BaseOverviewView(base: fighters[selectedSlot]!.base, width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 75, height: geometry.size.height - 30)
                                        .padding(.trailing, 5)
                                        ForEach(fighters[selectedSlot]!.skills, id: \.name) { skill in
                                            DetailedActionView(title: skill.name, description: skill.description, width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                        }
                                    }
                                    .padding(.vertical, 15)
                                }
                                .clipped()
                            }
                            .padding(.horizontal, 15).frame(width: 175).rotationEffect(.degrees(180))
                        }
                    }
                    SmallTriangle().fill(Color.pink).frame(width: 14, height: 26).offset(y: self.getOffset()).animation(.linear(duration: 0.2), value: selectedSlot).rotationEffect(.degrees(180))
                }
                .offset(x: -geometry.safeAreaInsets.leading - offsetX).animation(.linear(duration: 0.2), value: offsetX)
                .onAppear {
                    offsetX = 0
                }
            }
        }
    }
}

struct LeftSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LeftSelectionView(fighters: .constant([nil, nil, nil, nil])).edgesIgnoringSafeArea(.bottom)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
