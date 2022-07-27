//
//  TutorialPlayerSelectionView.swift
//  Witchery
//
//  Created by Janice Hablützel on 31.01.22.
//

import SwiftUI

struct TutorialPlayerSelectionView: View {
    @Binding var witches: [Witch?]
    @Binding var tutorialCounter: Int
    
    @State var selectedSlot: Int = -1
    @State var selectedNature: Int = 0
    @State var selectedArtifact: Int = 0
    
    @State var selectionToggle: Bool = false
    @State var infoToggle: Bool = false
    
    @State var offsetY: CGFloat = 175
    
    @GestureState var isNatureDecreasing = false
    @GestureState var isNatureIncreasing = false
    @GestureState var isArtifactDecreasing = false
    @GestureState var isArtifactIncreasing = false
    
    /// Returns wether the witch is selected or not.
    /// - Parameter witch: The witch in question
    /// - Returns: Returns wether the witch is selected or not
    func isSelected(witch: Witch?) -> Bool {
        if witch == nil {
            return false
        }
        
        for selectedWitch in witches {
            if selectedWitch != nil && witch! == selectedWitch! {
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
    
    /// Check if the button is disabled.
    /// - Parameter index: The current index of the tutorial
    /// - Returns: Returns wether the button is disabled or not
    func isDisabled(index: Int) -> Bool {
        if index == 1 && tutorialCounter == 5 || index == 1 && tutorialCounter == 7 || index == 1 && tutorialCounter == 8 {
            return false
        }
        
        if index > 0 {
            return true
        }
        
        return tutorialCounter == 1 || tutorialCounter > 2
    }
    
    /// Check if the button is opaque.
    /// - Parameter index: The current index of the tutorial
    /// - Returns: Returns wether the button is opaque or not
    func isOpaque(index: Int) -> Bool {
        if index == 1 && tutorialCounter == 5 || index == 1 && tutorialCounter == 7 || index == 1 && tutorialCounter == 8 {
            return false
        }
        
        if tutorialCounter > 8 {
            return false
        }
        
        if index > 0 {
            return true
        }
        
        return tutorialCounter == 1 || tutorialCounter > 2
    }
    
    /// Check if the witch is unselectable.
    /// - Parameter index: The current index of the tutorial
    /// - Returns: Returns wether the witch is unselectable or not
    func isWitchDisabled(witch: Witch) -> Bool {
        if tutorialCounter == 1 && witch.getElement().name == "fire" {
            return false
        } else if tutorialCounter == 6 && witch.getElement().name == "plant" {
            return false
        }
        
        return true
    }
    
    /// Check if a witch in the team already uses an artifact.
    /// - Parameter artifact: The artifact in qustion
    /// - Returns: Returns wether another witch already uses the artifact
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
            ZStack(alignment: .bottomLeading) {
                VStack {
                    HStack(spacing: 5) {
                        Spacer()
                        ForEach(0 ..< 4) { index in
                            Button(action: {
                                AudioPlayer.shared.playStandardSound()
                                tutorialCounter += 1
                                
                                if selectedSlot == index {
                                    if selectionToggle && witches[index] != nil {
                                        selectionToggle = false
                                        infoToggle = true
                                    } else {
                                        offsetY = 175
                                        
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
                                SquareWitchView(witch: witches[index], isSelected: index == selectedSlot, inverted: true)
                            }
                            .opacity(isOpaque(index: index) ? 0.5 : 1.0).disabled(isDisabled(index: index))
                        }
                        Spacer()
                    }
                    Spacer()
                }
                if selectionToggle || infoToggle {
                    ZStack(alignment: .topLeading) {
                        Rectangle().fill(Color("panel"))
                        if selectionToggle {
                            ScrollView(.horizontal, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack(spacing: 5) {
                                        ForEach(GlobalData.shared.getFirstTutorialHalf(), id: \.self) { witch in
                                            Button(action: {
                                                AudioPlayer.shared.playStandardSound()
                                                tutorialCounter += 1
                                                
                                                if !isSelected(witch: witch) {
                                                    witches[selectedSlot] = Witch(data: witch.data)
                                                }
                                            }) {
                                                SquareWitchView(witch: witch, isSelected: self.isSelected(witch: witch))
                                            }
                                            .opacity(isWitchDisabled(witch: witch) ? 0.5 : 1.0).disabled(isWitchDisabled(witch: witch))
                                        }
                                    }
                                    HStack(spacing: 5) {
                                        ForEach(GlobalData.shared.getSecondTutorialHalf(), id: \.self) { witch in
                                            SquareWitchView(witch: witch, isSelected: self.isSelected(witch: witch)).opacity(0.5)
                                        }
                                    }
                                }
                                .padding(.leading, 15)
                            }
                            .frame(width: geometry.size.width - 15).padding(.vertical, 15).clipped()
                        } else {
                            VStack(spacing: 0) {
                                ScrollView(.vertical, showsIndicators: false) {
                                    HStack(spacing: 5) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5).fill(Color("outline")).frame(height: 45)
                                            HStack(spacing: 0) {
                                                Button("<") {
                                                }
                                                .buttonStyle(ClearBasicButton(width: 45, height: 45, fontColor: Color("button")))
                                                .onChange(of: isNatureDecreasing, perform: { _ in
                                                    Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                                        if self.isNatureDecreasing == true {
                                                            if tutorialCounter < 5 {
                                                                tutorialCounter = 4
                                                            }
                                                            
                                                            AudioPlayer.shared.playStandardSound()
                                                            
                                                            if selectedNature <= 0 {
                                                                selectedNature = GlobalData.shared.natures.count - 1
                                                            } else {
                                                                selectedNature -= 1
                                                            }
                                                            
                                                            witches[selectedSlot]!.setNature(nature: selectedNature)
                                                        } else {
                                                            timer.invalidate()
                                                        }
                                                    }
                                                })
                                                .simultaneousGesture(
                                                    LongPressGesture(minimumDuration: .infinity)
                                                        .updating($isNatureDecreasing) { value, state, _ in state = value }
                                                )
                                                .highPriorityGesture(
                                                    TapGesture()
                                                        .onEnded { _ in
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
                                                })
                                                CustomText(key: GlobalData.shared.natures[selectedNature].name, fontColor: Color("button"), fontSize: smallFontSize).frame(width: (geometry.size.width - 30)/3 * 2 - 90)
                                                Button(">") {
                                                }
                                                .buttonStyle(ClearBasicButton(width: 45, height: 45, fontColor: Color("button")))
                                                .onChange(of: isNatureIncreasing, perform: { _ in
                                                    Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                                        if self.isNatureIncreasing == true {
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
                                                        } else {
                                                            timer.invalidate()
                                                        }
                                                    }
                                                })
                                                .simultaneousGesture(
                                                    LongPressGesture(minimumDuration: .infinity)
                                                        .updating($isNatureIncreasing) { value, state, _ in state = value }
                                                )
                                                .highPriorityGesture(
                                                    TapGesture()
                                                        .onEnded { _ in
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
                                                })
                                            }
                                            .disabled(tutorialCounter == 5)
                                        }
                                        .opacity(tutorialCounter == 5 ? 0.5 : 1.0)
                                        Button(Localization.shared.getTranslation(key: "remove")) {
                                            AudioPlayer.shared.playStandardSound()
                                            witches[selectedSlot] = nil
                                            
                                            selectionToggle = true
                                            infoToggle = false
                                        }
                                        .buttonStyle(BasicButton(width: (geometry.size.width - 30)/3 - 5)).opacity(0.5).disabled(true)
                                    }
                                    .padding(.horizontal, 15)
                                    BaseWitchOverviewView(base: witches[selectedSlot]!.getModifiedBase(), bgColor: Color("button")).padding(.horizontal, 15)
                                    ForEach(witches[selectedSlot]!.spells, id: \.self) { spell in
                                        DetailedActionView(title: spell.name, description: spell.name + "Descr", symbol: spell.element.symbol)
                                            .padding(.horizontal, 15)
                                    }
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5).fill(Color("outline")).frame(height: 60)
                                        HStack(spacing: 0) {
                                            Button("<") {
                                            }
                                            .buttonStyle(ClearBasicButton(width: 40, height: 60, fontColor: Color("button")))
                                            .onChange(of: isArtifactDecreasing, perform: { _ in
                                                Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                                    if self.isArtifactDecreasing == true {
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if tutorialCounter < 6 {
                                                            tutorialCounter = 5
                                                        }
                                                        
                                                        if selectedArtifact <= 0 {
                                                            selectedArtifact = Artifacts.allCases.count - 1
                                                        } else {
                                                            selectedArtifact -= 1
                                                        }
                                                        
                                                        if GlobalData.shared.artifactUse == 1 {
                                                            while isArtifactInUse(artifact: selectedArtifact) {
                                                                if selectedArtifact <= 0 {
                                                                    selectedArtifact = Artifacts.allCases.count - 1
                                                                } else {
                                                                    selectedArtifact -= 1
                                                                }
                                                            }
                                                        }
                                                        
                                                        witches[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                                    } else {
                                                        timer.invalidate()
                                                    }
                                                }
                                            })
                                            .simultaneousGesture(
                                                LongPressGesture(minimumDuration: .infinity)
                                                    .updating($isArtifactDecreasing) { value, state, _ in state = value }
                                            )
                                            .highPriorityGesture(
                                                TapGesture()
                                                    .onEnded { _ in
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if tutorialCounter < 6 {
                                                            tutorialCounter = 5
                                                        }
                                                        
                                                        if selectedArtifact <= 0 {
                                                            selectedArtifact = Artifacts.getTutorialArtifactArray().count - 1
                                                        } else {
                                                            selectedArtifact -= 1
                                                        }
                                                        
                                                        if GlobalData.shared.artifactUse == 1 {
                                                            while isArtifactInUse(artifact: selectedArtifact) {
                                                                if selectedArtifact <= 0 {
                                                                    selectedArtifact = Artifacts.getTutorialArtifactArray().count - 1
                                                                } else {
                                                                    selectedArtifact -= 1
                                                                }
                                                            }
                                                        }
                                                        
                                                        witches[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                            })
                                            VStack(spacing: -2) {
                                                CustomText(key: Artifacts.allCases[selectedArtifact].getArtifact().name, fontColor: Color("button"), fontSize: mediumFontSize, isBold: true).frame(width: geometry.size.width - 90 - 30, alignment: .leading)
                                                CustomText(key: Artifacts.allCases[selectedArtifact].getArtifact().description, fontColor: Color("button"), fontSize: tinyFontSize).frame(width: geometry.size.width - 90 - 30, alignment: .leading)
                                            }
                                            Button(">") {
                                            }
                                            .buttonStyle(ClearBasicButton(width: 40, height: 60, fontColor: Color("button")))
                                            .onChange(of: isArtifactIncreasing, perform: { _ in
                                                Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                                    if self.isArtifactIncreasing == true {
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if tutorialCounter < 6 {
                                                            tutorialCounter = 5
                                                        }
                                                        
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if selectedArtifact >= Artifacts.getTutorialArtifactArray().count - 1 {
                                                            selectedArtifact = 0
                                                        } else {
                                                            selectedArtifact += 1
                                                        }
                                                        
                                                        if GlobalData.shared.artifactUse == 1 {
                                                            while isArtifactInUse(artifact: selectedArtifact) {
                                                                if selectedArtifact >= Artifacts.getTutorialArtifactArray().count - 1 {
                                                                    selectedArtifact = 0
                                                                } else {
                                                                    selectedArtifact += 1
                                                                }
                                                            }
                                                        }
                                                        
                                                        witches[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                                    } else {
                                                        timer.invalidate()
                                                    }
                                                }
                                            })
                                            .simultaneousGesture(
                                                LongPressGesture(minimumDuration: .infinity)
                                                    .updating($isArtifactIncreasing) { value, state, _ in state = value }
                                            )
                                            .highPriorityGesture(
                                                TapGesture()
                                                    .onEnded { _ in
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if tutorialCounter < 6 {
                                                            tutorialCounter = 5
                                                        }
                                                        
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if selectedArtifact >= Artifacts.getTutorialArtifactArray().count - 1 {
                                                            selectedArtifact = 0
                                                        } else {
                                                            selectedArtifact += 1
                                                        }
                                                        
                                                        if GlobalData.shared.artifactUse == 1 {
                                                            while isArtifactInUse(artifact: selectedArtifact) {
                                                                if selectedArtifact >= Artifacts.getTutorialArtifactArray().count - 1 {
                                                                    selectedArtifact = 0
                                                                } else {
                                                                    selectedArtifact += 1
                                                                }
                                                            }
                                                        }
                                                        
                                                        witches[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                            })
                                        }
                                        .frame(height: 60)
                                    }
                                    .opacity(tutorialCounter < 4 ? 0.5 : 1.0).padding(.horizontal, 15)
                                }
                                .frame(height: 145).padding(.top, 15).clipped()
                            }
                            .onAppear {
                                selectedNature = getNature(witch: witches[selectedSlot]!)
                                selectedArtifact = getArtifact(witch: witches[selectedSlot]!)
                            }
                        }
                    }
                    .frame(height: 175 + geometry.safeAreaInsets.bottom).offset(y: geometry.safeAreaInsets.bottom + offsetY).animation(.linear(duration: 0.2), value: offsetY)
                    .onAppear {
                        offsetY = 0
                    }
                }
            }
        }
    }
}

struct TutorialPlayerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialPlayerSelectionView(witches:Binding.constant([nil, nil, nil, nil]), tutorialCounter:Binding.constant(0))
    }
}
