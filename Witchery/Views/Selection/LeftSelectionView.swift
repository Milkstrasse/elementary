//
//  LeftSelectionView.swift
//  Witchery
//
//  Created by Janice Hablützel on 04.01.22.
//

import SwiftUI

struct LeftSelectionView: View {
    @Binding var witches: [Witch?]
    @State var selectedSlot: Int = -1
    @State var selectedNature: Int = 0
    @State var selectedAbility: Int = 0
    
    @State var selectionToggle: Bool = false
    @State var infoToggle: Bool = false
    
    @State var offsetX: CGFloat = 175
    
    func isSelected(witch: Witch?) -> Bool {
        if witch == nil {
            return false
        }
        
        for selectedWitch in witches {
            if witch?.name == selectedWitch?.name {
                return true
            }
        }
        
        return false
    }
    
    func getFirstHalf() -> [Witch?] {
        if GlobalData.shared.witches.count%2 == 0 {
            let rowArray = GlobalData.shared.witches[0 ..< GlobalData.shared.witches.count/2]
            return Array(rowArray)
        } else {
            let rowArray = GlobalData.shared.witches[0 ..< GlobalData.shared.witches.count/2 + 1]
            return Array(rowArray)
        }
    }
    
    func getSecondHalf() -> [Witch?] {
        if GlobalData.shared.witches.count%2 == 0 {
            let rowArray = GlobalData.shared.witches[GlobalData.shared.witches.count/2 ..< GlobalData.shared.witches.count]
            return Array(rowArray)
        } else {
            let rowArray = GlobalData.shared.witches[GlobalData.shared.witches.count/2 + 1 ..< GlobalData.shared.witches.count]
            return Array(rowArray)
        }
    }
    
    func getNature(witch: Witch) -> Int {
        for index in GlobalData.shared.natures.indices {
            if witch.nature.name == GlobalData.shared.natures[index].name {
                return index
            }
        }
        
        return 0
    }
    
    func getAbility(witch: Witch) -> Int {
        for index in Abilities.allCases.indices {
            if witch.ability.name == Abilities.allCases[index].rawValue {
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
                                        if selectionToggle && witches[index] != nil {
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
                                        
                                        if witches[index] != nil {
                                            selectedNature = getNature(witch: witches[selectedSlot]!)
                                            selectedAbility = getAbility(witch: witches[selectedSlot]!)
                                            
                                            selectionToggle = false
                                            infoToggle = true
                                        } else {
                                            infoToggle = false
                                            selectionToggle = true
                                        }
                                    }
                                }) {
                                    SquareWitchView(witch: witches[index], isSelected: index == selectedSlot)
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
                                            ForEach(self.getSecondHalf(), id: \.?.name) { witch in
                                                Button(action: {
                                                    AudioPlayer.shared.playStandardSound()
                                                    
                                                    if !isSelected(witch: witch) {
                                                        witches[selectedSlot] = Witch(data: witch!.data)
                                                    }
                                                }) {
                                                    SquareWitchView(witch: witch, isSelected: self.isSelected(witch: witch)).rotationEffect(.degrees(90))
                                                }
                                            }
                                        }
                                        VStack(spacing: 5) {
                                            ForEach(self.getFirstHalf(), id: \.?.name) { witch in
                                                Button(action: {
                                                    AudioPlayer.shared.playStandardSound()
                                                    
                                                    if !isSelected(witch: witch) {
                                                        witches[selectedSlot] = Witch(data: witch!.data)
                                                    }
                                                }) {
                                                    SquareWitchView(witch: witch, isSelected: self.isSelected(witch: witch)).rotationEffect(.degrees(90))
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
                                                witches[selectedSlot] = nil
                                                
                                                selectionToggle = true
                                                infoToggle = false
                                            }
                                            .buttonStyle(BasicButton(width: (geometry.size.height - 30)/3 - 5)).rotationEffect(.degrees(-90)).frame(width: 40, height: (geometry.size.height - 30)/3 - 5)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5).fill(Color("outline")).frame(width: 40, height: (geometry.size.height - 30)/3 * 2)
                                                HStack(spacing: 0) {
                                                    Button("<") {
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if selectedNature <= 0 {
                                                            selectedNature = GlobalData.shared.natures.count - 1
                                                        } else {
                                                            selectedNature -= 1
                                                        }
                                                        
                                                        witches[selectedSlot]!.setNature(nature: selectedNature)
                                                    }
                                                    .buttonStyle(ClearBasicButton(width: 40, height: 40, fontColor: Color("background")))
                                                    CustomText(key: GlobalData.shared.natures[selectedNature].name, fontColor: Color("background"), fontSize: 14).frame(width: (geometry.size.height - 30)/3 * 2 - 80)
                                                    Button(">") {
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if selectedNature >= GlobalData.shared.natures.count - 1 {
                                                            selectedNature = 0
                                                        } else {
                                                            selectedNature += 1
                                                        }
                                                        
                                                        witches[selectedSlot]!.setNature(nature: selectedNature)
                                                    }
                                                    .buttonStyle(ClearBasicButton(width: 40, height: 40, fontColor: Color("background")))
                                                }.rotationEffect(.degrees(-90)).frame(width: 40, height: (geometry.size.height - 30)/3 * 2)
                                            }
                                        }
                                        BaseWitchesOverviewView(base: witches[selectedSlot]!.getModifiedBase(), width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 75, height: geometry.size.height - 30)
                                        .padding(.trailing, 5)
                                        ForEach(witches[selectedSlot]!.spells, id: \.self) { spell in
                                            DetailedActionView(title: spell.name, description: spell.name + "Descr", symbol: spell.element.symbol, width: geometry.size.height - 30).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                        }
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5).fill(Color("outline")).frame(width: geometry.size.height - 30, height: 60)
                                            HStack(spacing: 0) {
                                                Button("<") {
                                                    AudioPlayer.shared.playStandardSound()
                                                    
                                                    if selectedAbility <= 0 {
                                                        selectedAbility = Abilities.allCases.count - 1
                                                    } else {
                                                        selectedAbility -= 1
                                                    }
                                                    
                                                    witches[selectedSlot]!.setAbility(ability: selectedAbility)
                                                }
                                                .buttonStyle(ClearBasicButton(width: 40, height: 60, fontColor: Color("background")))
                                                VStack {
                                                    CustomText(key: Abilities.allCases[selectedAbility].getAbility().name, fontColor: Color("background"), fontSize: 16, isBold: true).frame(width: geometry.size.height - 90 - 30, alignment: .leading)
                                                    CustomText(key: Abilities.allCases[selectedAbility].getAbility().description, fontColor: Color("background"), fontSize: 13).frame(width: geometry.size.height - 90 - 30, alignment: .leading)
                                                }
                                                Button(">") {
                                                    AudioPlayer.shared.playStandardSound()
                                                    
                                                    if selectedAbility >= Abilities.allCases.count - 1 {
                                                        selectedAbility = 0
                                                    } else {
                                                        selectedAbility += 1
                                                    }
                                                    
                                                    witches[selectedSlot]!.setAbility(ability: selectedAbility)
                                                }
                                                .buttonStyle(ClearBasicButton(width: 40, height: 60, fontColor: Color("background")))
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
                                selectedNature = getNature(witch: witches[selectedSlot]!)
                                selectedAbility = getAbility(witch: witches[selectedSlot]!)
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
        LeftSelectionView(witches: .constant([nil, nil, nil, nil])).ignoresSafeArea(.all, edges: .bottom)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
