//
//  TutorialRightSelectionView.swift
//  Witchery
//
//  Created by Janice Hablützel on 31.01.22.
//

import SwiftUI

struct TutorialRightSelectionView: View {
    @Binding var witches: [Witch?]
    @Binding var tutorialCounter: Int
    
    @State var selectedSlot: Int = -1
    @State var selectedNature: Int = 0
    @State var selectedArtifact: Int = 0
    
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
    
    func getNature(witch: Witch) -> Int {
        for index in GlobalData.shared.natures.indices {
            if witch.nature.name == GlobalData.shared.natures[index].name {
                return index
            }
        }
        
        return 0
    }
    
    func isDisabled(index: Int) -> Bool {
        if index == 1 && tutorialCounter == 5 || index == 1 && tutorialCounter == 7 || index == 1 && tutorialCounter == 8 {
            return false
        }
        
        if index > 0 {
            return true
        }
        
        return tutorialCounter == 1 || tutorialCounter > 2
    }
    
    func isWitchDisabled(witch: Witch) -> Bool {
        if tutorialCounter == 1 && witch.element.name == "fire" {
            return false
        } else if tutorialCounter == 6 && witch.element.name == "plant" {
            return false
        }
        
        return true
    }
    
    func getArtifact(witch: Witch) -> Int {
        for index in Artifacts.allCases.indices {
            if witch.getArtifact().name == Artifacts.allCases[index].rawValue {
                return index
            }
        }
        
        return 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                HStack {
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(0 ..< 4) { index in
                                Button(action: {
                                    AudioPlayer.shared.playStandardSound()
                                    tutorialCounter += 1
                                    
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
                                            selectedArtifact = getArtifact(witch: witches[selectedSlot]!)
                                            
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
                                .opacity(isDisabled(index: index) ? 0.5 : 1.0).disabled(isDisabled(index: index))
                            }
                        }
                        .rotationEffect(.degrees(-90)).frame(width: 70, height: 295)
                        Spacer()
                    }
                    Spacer()
                }
                if selectionToggle || infoToggle {
                    HStack(spacing: 0) {
                        Rectangle().fill(Color("outline")).frame(width: 1)
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color("background")).frame(width: 175 + geometry.safeAreaInsets.trailing)
                            if selectionToggle {
                                VStack {
                                    ScrollView(.vertical, showsIndicators: false) {
                                        HStack(alignment: .top, spacing: 5) {
                                            VStack(spacing: 5) {
                                                ForEach(GlobalData.shared.getSecondHalf(), id: \.?.name) { witch in
                                                    SquareWitchView(witch: witch, isSelected: self.isSelected(witch: witch)).rotationEffect(.degrees(90)).opacity(0.5)
                                                }
                                            }
                                            VStack(spacing: 5) {
                                                ForEach(GlobalData.shared.getFirstHalf(), id: \.?.name) { witch in
                                                    Button(action: {
                                                        AudioPlayer.shared.playStandardSound()
                                                        tutorialCounter += 1
                                                        
                                                        if !isSelected(witch: witch) {
                                                            witches[selectedSlot] = Witch(data: witch!.data)
                                                        }
                                                    }) {
                                                        SquareWitchView(witch: witch, isSelected: self.isSelected(witch: witch)).rotationEffect(.degrees(90))
                                                    }
                                                    .opacity(isWitchDisabled(witch: witch!) ? 0.5 : 1.0).disabled(isWitchDisabled(witch: witch!))
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 15)
                                    }
                                    .clipped()
                                }
                                .padding(.vertical, 15).rotationEffect(.degrees(180))
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
                                                .buttonStyle(BasicButton(width: (geometry.size.height - 30)/3 - 5)).rotationEffect(.degrees(-90)).frame(width: 40, height: (geometry.size.height - 30)/3 - 5).opacity(0.5).disabled(true)
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 5).fill(Color("outline")).frame(width: 40, height: (geometry.size.height - 30)/3 * 2)
                                                    HStack(spacing: 0) {
                                                        Button("<") {
                                                            AudioPlayer.shared.playStandardSound()
                                                            if tutorialCounter < 5 {
                                                                tutorialCounter = 4
                                                            }
                                                            
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
                                                            if tutorialCounter < 5 {
                                                                tutorialCounter = 4
                                                            }
                                                            
                                                            if selectedNature >= GlobalData.shared.natures.count - 1 {
                                                                selectedNature = 0
                                                            } else {
                                                                selectedNature += 1
                                                            }
                                                            
                                                            witches[selectedSlot]!.setNature(nature: selectedNature)
                                                        }
                                                        .buttonStyle(ClearBasicButton(width: 40, height: 40, fontColor: Color("background")))
                                                    }
                                                    .rotationEffect(.degrees(-90)).frame(width: 40, height: (geometry.size.height - 30)/3 * 2).disabled(tutorialCounter == 5)
                                                }
                                                .opacity(tutorialCounter == 5 ? 0.5 : 1.0)
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
                                                        if tutorialCounter < 6 {
                                                            tutorialCounter = 5
                                                        }
                                                        
                                                        if selectedArtifact <= 0 {
                                                            selectedArtifact = Artifacts.getTutorialArtifactArray().count - 1
                                                        } else {
                                                            selectedArtifact -= 1
                                                        }
                                                        
                                                        witches[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                                    }
                                                    .buttonStyle(ClearBasicButton(width: 40, height: 60, fontColor: Color("background")))
                                                    VStack {
                                                        CustomText(key: Artifacts.getTutorialArtifactArray()[selectedArtifact].name, fontColor: Color("background"), fontSize: 16, isBold: true).frame(width: geometry.size.height - 90 - 30, alignment: .leading)
                                                        CustomText(key: Artifacts.getTutorialArtifactArray()[selectedArtifact].description, fontColor: Color("background"), fontSize: 13).frame(width: geometry.size.height - 90 - 30, alignment: .leading)
                                                    }
                                                    Button(">") {
                                                        AudioPlayer.shared.playStandardSound()
                                                        if tutorialCounter < 6 {
                                                            tutorialCounter = 5
                                                        }
                                                        
                                                        if selectedArtifact >= Artifacts.getTutorialArtifactArray().count - 1 {
                                                            selectedArtifact = 0
                                                        } else {
                                                            selectedArtifact += 1
                                                        }
                                                        
                                                        witches[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                                    }
                                                    .buttonStyle(ClearBasicButton(width: 40, height: 60, fontColor: Color("background")))
                                                }
                                                .frame(width: geometry.size.height - 30, height: 60).disabled(tutorialCounter < 4)
                                            }
                                            .opacity(tutorialCounter < 4 ? 0.5 : 1.0).rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30)
                                        }
                                        .padding(.vertical, 15)
                                    }
                                    .clipped()
                                }
                                .padding(.horizontal, 15).frame(width: 175)
                                .onAppear {
                                    selectedNature = getNature(witch: witches[selectedSlot]!)
                                    selectedArtifact = getArtifact(witch: witches[selectedSlot]!)
                                }
                            }
                        }
                    }
                    .offset(x: geometry.safeAreaInsets.trailing + offsetX).animation(.linear(duration: 0.2), value: offsetX)
                    .onAppear {
                        offsetX = 0
                    }
                }
            }
        }
    }
}

struct TutorialRightSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialRightSelectionView(witches:Binding.constant([nil, nil, nil, nil]), tutorialCounter:Binding.constant(0)).ignoresSafeArea(.all, edges: .bottom).previewInterfaceOrientation(.landscapeLeft)
    }
}
