//
//  RightSelectionView.swift
//  Witchery
//
//  Created by Janice Hablützel on 04.01.22.
//

import SwiftUI

struct RightSelectionView: View {
    @Binding var witches: [Witch?]
    @State var selectedSlot: Int = -1
    @State var selectedNature: Int = 0
    @State var selectedArtifact: Int = 0
    
    @State var selectionToggle: Bool = false
    @State var infoToggle: Bool = false
    
    @State var offsetX: CGFloat = 175
    
    /// Returns wether the witch is selected or not.
    /// - Parameter witch: The witch in question
    /// - Returns: Returns wether the witch is selected or not
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
    
    /// Returns the index of the nature of a witch.
    /// - Parameter witch: The selected witch
    /// - Returns: Returns the index of the nature of a witch
    func getNature(witch: Witch) -> Int {
        for index in GlobalData.shared.natures.indices {
            if witch.nature.name == GlobalData.shared.natures[index].name {
                return index
            }
        }
        
        return 0
    }
    
    /// Returns the index of the artifact of a witch.
    /// - Parameter witch: The selected witch
    /// - Returns: Returns the index of the artifact of a witch
    func getArtifact(witch: Witch) -> Int {
        for index in Artifacts.allCases.indices {
            if witch.getArtifact().name == Artifacts.allCases[index].rawValue {
                return index
            }
        }
        
        return 0
    }
    
    func isArtifactInUse(artifact: Int) -> Bool {
        if artifact == 0 {
            return false
        }
        
        for witch in witches {
            if witch != nil {
                if getArtifact(witch: witch!) == artifact {
                    return true
                }
            }
        }
        
        return false
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
                                                ForEach(GlobalData.shared.getFirstHalf(), id: \.?.name) { witch in
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
                                                    }
                                                    .rotationEffect(.degrees(-90)).frame(width: 40, height: (geometry.size.height - 30)/3 * 2)
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
                                                        
                                                        if selectedArtifact <= 0 {
                                                            selectedArtifact = Artifacts.allCases.count - 1
                                                        } else {
                                                            selectedArtifact -= 1
                                                        }
                                                        
                                                        if GlobalData.shared.artifactUse == 1{
                                                            while isArtifactInUse(artifact: selectedArtifact) {
                                                                if selectedArtifact <= 0 {
                                                                    selectedArtifact = Artifacts.allCases.count - 1
                                                                } else {
                                                                    selectedArtifact -= 1
                                                                }
                                                            }
                                                        }
                                                        
                                                        witches[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                                    }
                                                    .buttonStyle(ClearBasicButton(width: 40, height: 60, fontColor: Color("background")))
                                                    VStack {
                                                        CustomText(key: Artifacts.allCases[selectedArtifact].getArtifact().name, fontColor: Color("background"), fontSize: 16, isBold: true).frame(width: geometry.size.height - 90 - 30, alignment: .leading)
                                                        CustomText(key: Artifacts.allCases[selectedArtifact].getArtifact().description, fontColor: Color("background"), fontSize: 13).frame(width: geometry.size.height - 90 - 30, alignment: .leading)
                                                    }
                                                    Button(">") {
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if selectedArtifact >= Artifacts.allCases.count - 1 {
                                                            selectedArtifact = 0
                                                        } else {
                                                            selectedArtifact += 1
                                                        }
                                                        
                                                        if GlobalData.shared.artifactUse == 1{
                                                            while isArtifactInUse(artifact: selectedArtifact) {
                                                                if selectedArtifact >= Artifacts.allCases.count - 1 {
                                                                    selectedArtifact = 0
                                                                } else {
                                                                    selectedArtifact += 1
                                                                }
                                                            }
                                                        }
                                                        
                                                        witches[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                                    }
                                                    .buttonStyle(ClearBasicButton(width: 40, height: 60, fontColor: Color("background")))
                                                }
                                                .frame(width: geometry.size.height - 30, height: 60)
                                            }
                                            .rotationEffect(.degrees(-90)).frame(width: 60, height: geometry.size.height - 30).opacity(GlobalData.shared.artifactUse == 2 ? 0.5 : 1.0).disabled(GlobalData.shared.artifactUse == 2)
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

struct RightSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RightSelectionView(witches:Binding.constant([nil, nil, nil, nil])).ignoresSafeArea(.all, edges: .bottom).previewInterfaceOrientation(.landscapeLeft)
    }
}
