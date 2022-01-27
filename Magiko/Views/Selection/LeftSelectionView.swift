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
    @State var selectedLoadout: Int = 0
    @State var selectedAbility: Int = 0
    
    @State var selectionToggle: Bool = false
    @State var infoToggle: Bool = false
    
    @State var offsetX: CGFloat = 175
    
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
        if GlobalData.shared.fighters.count%2 == 0 {
            let rowArray = GlobalData.shared.fighters[0 ..< GlobalData.shared.fighters.count/2]
            return Array(rowArray)
        } else {
            let rowArray = GlobalData.shared.fighters[0 ..< GlobalData.shared.fighters.count/2 + 1]
            return Array(rowArray)
        }
    }
    
    func getSecondHalf() -> [Fighter?] {
        if GlobalData.shared.fighters.count%2 == 0 {
            let rowArray = GlobalData.shared.fighters[GlobalData.shared.fighters.count/2 ..< GlobalData.shared.fighters.count]
            return Array(rowArray)
        } else {
            let rowArray = GlobalData.shared.fighters[GlobalData.shared.fighters.count/2 + 1 ..< GlobalData.shared.fighters.count]
            return Array(rowArray)
        }
    }
    
    func getLoadout(fighter: Fighter) -> Int {
        for index in GlobalData.shared.loadouts.indices {
            if fighter.loadout.name == GlobalData.shared.loadouts[index].name {
                return index
            }
        }
        
        return 0
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
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    if selectedSlot == index {
                                        if selectionToggle && fighters[index] != nil {
                                            selectionToggle = false
                                            infoToggle = true
                                        } else {
                                            offsetX = 189
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                selectionToggle = false
                                                infoToggle = false
                                                
                                                selectedSlot = -1
                                            }
                                        }
                                    } else {
                                        selectedSlot = index
                                        
                                        if fighters[index] != nil {
                                            selectedLoadout = getLoadout(fighter: fighters[selectedSlot]!)
                                            
                                            selectionToggle = false
                                            infoToggle = true
                                        } else {
                                            infoToggle = false
                                            selectionToggle = true
                                        }
                                    }
                                }) {
                                    SquareFighterView(fighter: fighters[index], isSelected: index == selectedSlot)
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
                        Rectangle().fill(Color("background")).frame(width: 175 + geometry.safeAreaInsets.leading)
                        if selectionToggle {
                            VStack {
                                ScrollView(.vertical, showsIndicators: false) {
                                    HStack(alignment: .top, spacing: 5) {
                                        VStack(spacing: 5) {
                                            ForEach(self.getSecondHalf(), id: \.?.name) { fighter in
                                                Button(action: {
                                                    AudioPlayer.shared.playStandardSound()
                                                    
                                                    if !isSelected(fighter: fighter) {
                                                        fighters[selectedSlot] = Fighter(data: fighter!.data)
                                                    }
                                                }) {
                                                    SquareFighterView(fighter: fighter, isSelected: self.isSelected(fighter: fighter)).rotationEffect(.degrees(90))
                                                }
                                            }
                                        }
                                        VStack(spacing: 5) {
                                            ForEach(self.getFirstHalf(), id: \.?.name) { fighter in
                                                Button(action: {
                                                    AudioPlayer.shared.playStandardSound()
                                                    
                                                    if !isSelected(fighter: fighter) {
                                                        fighters[selectedSlot] = Fighter(data: fighter!.data)
                                                    }
                                                }) {
                                                    SquareFighterView(fighter: fighter, isSelected: self.isSelected(fighter: fighter)).rotationEffect(.degrees(90))
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
                                            Button(Localization.shared.getTranslation(key: "remove")) {
                                                AudioPlayer.shared.playStandardSound()
                                                fighters[selectedSlot] = nil
                                                
                                                selectionToggle = true
                                                infoToggle = false
                                            }
                                            .buttonStyle(BasicButton(width: geometry.size.height - 30 - 215 - 5)).rotationEffect(.degrees(-90)).frame(width: 40, height: geometry.size.height - 30 - 215 - 5)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: 40, height: 215)
                                                RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: 40, height: 215)
                                                HStack(spacing: 0) {
                                                    Button("<") {
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if selectedLoadout <= 0 {
                                                            selectedLoadout = GlobalData.shared.loadouts.count - 1
                                                        } else {
                                                            selectedLoadout -= 1
                                                        }
                                                        
                                                        fighters[selectedSlot]!.setLoadout(loadout: selectedLoadout)
                                                    }
                                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                                    CustomText(key: GlobalData.shared.loadouts[selectedLoadout].name).frame(width: 125)
                                                    Button(">") {
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if selectedLoadout >= GlobalData.shared.loadouts.count - 1 {
                                                            selectedLoadout = 0
                                                        } else {
                                                            selectedLoadout += 1
                                                        }
                                                        
                                                        fighters[selectedSlot]!.setLoadout(loadout: selectedLoadout)
                                                    }
                                                    .buttonStyle(ClearBasicButton(width: 40, height: 40))
                                                }.rotationEffect(.degrees(-90)).frame(width: 40, height: 215)
                                            }
                                        }
                                        BaseOverviewView(base: fighters[selectedSlot]!.getModifiedBase(), width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 75, height: geometry.size.height - 30)
                                        .padding(.trailing, 5)
                                        ForEach(fighters[selectedSlot]!.skills, id: \.self) { skill in
                                            DetailedActionView(title: skill.name, description: skill.name + "Descr", symbol: skill.element.symbol, width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                        }
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5).fill(Color("button")).frame(width: geometry.size.height - 30, height: 60)
                                            RoundedRectangle(cornerRadius: 5).strokeBorder(Color("outline"), lineWidth: 1).frame(width: geometry.size.height - 30, height: 60)
                                            HStack(spacing: 0) {
                                                Button("<") {
                                                    AudioPlayer.shared.playStandardSound()
                                                    
                                                    if selectedAbility <= 0 {
                                                        selectedAbility = Abilities.allCases.count - 1
                                                    } else {
                                                        selectedAbility -= 1
                                                    }
                                                    
                                                    fighters[selectedSlot]!.setAbility(ability: selectedAbility)
                                                }
                                                .buttonStyle(ClearBasicButton(width: 40, height: 60))
                                                VStack {
                                                    CustomText(key: Abilities.allCases[selectedAbility].getAbility().name).frame(width: geometry.size.height - 90 - 30, alignment: .leading)
                                                    CustomText(key: Abilities.allCases[selectedAbility].getAbility().description).frame(width: geometry.size.height - 90 - 30, alignment: .leading)
                                                }
                                                Button(">") {
                                                    AudioPlayer.shared.playStandardSound()
                                                    
                                                    if selectedAbility >= Abilities.allCases.count - 1 {
                                                        selectedAbility = 0
                                                    } else {
                                                        selectedAbility += 1
                                                    }
                                                    
                                                    fighters[selectedSlot]!.setAbility(ability: selectedAbility)
                                                }
                                                .buttonStyle(ClearBasicButton(width: 40, height: 60))
                                            }
                                            .frame(width: geometry.size.height - 30, height: 60)
                                        }
                                        .rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                    }
                                    .padding(.vertical, 15)
                                }
                                .clipped()
                            }
                            .padding(.horizontal, 15).frame(width: 175).rotationEffect(.degrees(180))
                            .onAppear {
                                selectedLoadout = getLoadout(fighter: fighters[selectedSlot]!)
                            }
                        }
                    }
                    Rectangle().fill(Color("outline")).frame(width: 1)
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
        LeftSelectionView(fighters: .constant([nil, nil, nil, nil])).ignoresSafeArea(.all, edges: .bottom)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
