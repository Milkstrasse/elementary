//
//  TutorialPlayerSelectionView.swift
//  Elementary
//
//  Created by Janice Hablützel on 22.12.22.
//

import SwiftUI

struct TutorialPlayerSelectionView: View {
    let opponents: [Fighter?]
    
    @Binding var fighters: [Fighter?]
    @State var selectedSlot: Int = -1
    @State var selectedNature: Int = 0
    @State var selectedArtifact: Int = 0
    @State var selectedOutfit: Int = 0
    
    @State var offset: CGFloat = 175
    @State var selectionToggle: Bool = false
    @State var infoToggle: Bool = false
    
    @GestureState var isNatureDecreasing = false
    @GestureState var isNatureIncreasing = false
    @GestureState var isArtifactDecreasing = false
    @GestureState var isArtifactIncreasing = false
    
    @Binding var tutorialCounter: Int
    @State var blinking: Bool = false
    @State var blinkingEnabled: Bool = true
    
    let blinkAnimation = Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)
    
    /// Tries to add a selected fighter to the team.
    /// - Parameter fighter: The selected fighter
    func addFighter(fighter: Fighter) {
        AudioPlayer.shared.playStandardSound()
        fighters[selectedSlot] = SavedFighterData(fighter: fighter).toFighter(images: fighter.images) //make copy
    }
    
    /// Returns wether the fighter is selected or not.
    /// - Parameter fighter: The fighter in question
    /// - Returns: Returns wether the fighter is selected or not
    func isSelected(fighter: Fighter?) -> Bool {
        if fighter == nil {
            return false
        }
        
        for selectedFighter in fighters {
            if selectedFighter != nil && fighter! == selectedFighter! {
                return true
            }
        }
        
        return false
    }
    
    /// Returns wether the fighter is part of the team or not.
    /// - Parameter fighter: The fighter in question
    /// - Returns: Returns wether the fighter is part of the team or not
    func isPartOfTeam(fighter: Fighter) -> Bool {
        for selectedFighter in fighters {
            if fighter.name == selectedFighter?.name {
                return true
            }
        }
        
        return false
    }
    
    /// Returns the index of the nature of a fighter.
    /// - Parameter fighter: The selected fighter
    /// - Returns: Returns the index of the nature of a fighter
    func getNature(fighter: Fighter) -> Int {
        for index in GlobalData.shared.natures.indices {
            if fighter.nature.name == GlobalData.shared.natures[index].name {
                return index
            }
        }
        
        return 0
    }
    
    /// Returns the index of the artifact of a fighter.
    /// - Parameter fighter: The selected fighter
    /// - Returns: Returns the index of the artifact of a fighter
    func getArtifact(fighter: Fighter) -> Int {
        for index in Artifacts.allCases.indices {
            if fighter.getArtifact().name == Artifacts.allCases[index].rawValue {
                return index
            }
        }
        
        return 0
    }
    
    /// Check if a fighter in the team already uses an artifact.
    /// - Parameter artifact: The artifact in question
    /// - Returns: Returns wether another fighter already uses the artifact
    func isArtifactInUse(artifact: Int) -> Bool {
        if artifact == 0 {
            return false
        }
        
        for fighter in fighters {
            if fighter != nil {
                if getArtifact(fighter: fighter!) == artifact {
                    return true
                }
            }
        }
        
        return false
    }
    
    func isAddButtonDisabled(index: Int) -> Bool {
        if tutorialCounter < 5 {
            return index != 0 || !blinkingEnabled
        } else if tutorialCounter == 7 || tutorialCounter == 9 {
            return index != 1
        }
        
        return true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack(spacing: innerPadding/2) {
                    ForEach(0 ..< fighters.count, id: \.self) { index in
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            if selectedSlot == index {
                                tutorialCounter += 1
                                
                                if selectionToggle && fighters[index] != nil {
                                    offset = 0
                                    
                                    selectionToggle = false
                                    infoToggle = true
                                } else {
                                    offset = 175
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        selectionToggle = false
                                        infoToggle = false
                                        
                                        selectedSlot = -1
                                    }
                                }
                            } else {
                                tutorialCounter += 1
                                
                                selectedSlot = index
                                
                                if fighters[index] != nil {
                                    selectedNature = getNature(fighter: fighters[selectedSlot]!)
                                    selectedArtifact = getArtifact(fighter: fighters[selectedSlot]!)
                                    selectedOutfit = fighters[selectedSlot]!.outfitIndex
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        offset = 0
                                    }
                                    
                                    selectionToggle = false
                                    infoToggle = true
                                } else {
                                    infoToggle = false
                                    selectionToggle = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        offset = 0
                                    }
                                }
                            }
                        }) {
                            SquarePortraitView(fighter: fighters[index], outfitIndex: fighters[index]?.outfitIndex ?? 0, isSelected: index == selectedSlot, isInverted: true).opacity(blinking && !isAddButtonDisabled(index: index) ? 0.4 : 1)
                                .onAppear {
                                    blinking = false
                                    withAnimation(blinkAnimation) {
                                        blinking = true
                                    }
                                }
                                .onChange(of: tutorialCounter) { newValue in
                                    if newValue%2 != 0 {
                                        if newValue == 7 {
                                            blinkingEnabled = true
                                            
                                            blinking = false
                                            withAnimation(blinkAnimation) {
                                                blinking = true
                                            }
                                        } else {
                                            blinkingEnabled = false
                                        }
                                    } else if newValue == 2 {
                                        blinkingEnabled = true
                                    }
                                }
                        }
                        .disabled(isAddButtonDisabled(index: index))
                    }
                }
                Spacer()
            }
            ZStack {
                Rectangle().fill(Color("MainPanel")).shadow(radius: 5, x: 5, y: 0)
                if selectionToggle {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: innerPadding) {
                            VStack(spacing: 5) { //tutorial fighters
                                Button(action: {
                                    tutorialCounter = 2
                                    addFighter(fighter: fireFighter)
                                }) {
                                    SquarePortraitView(fighter: fireFighter, outfitIndex: fireFighter.outfitIndex, isSelected: tutorialCounter >= 2, isInverted: false)
                                        .opacity(blinking && tutorialCounter == 1 ? 0.4 : 1)
                                        .onAppear {
                                            blinking = false
                                            withAnimation(blinkAnimation) {
                                                blinking = true
                                            }
                                        }
                                }
                                .disabled(tutorialCounter > 1)
                                Button(action: {
                                    tutorialCounter = 9
                                    addFighter(fighter: plantFighter)
                                }) {
                                    SquarePortraitView(fighter: plantFighter, outfitIndex: plantFighter.outfitIndex, isSelected: tutorialCounter == 9, isInverted: false)
                                        .opacity(blinking && tutorialCounter == 8 ? 0.4 : 1)
                                }
                                .disabled(tutorialCounter != 8)
                            }
                            VStack(alignment: .leading, spacing: 5) { //all fighters
                                HStack(spacing: 5) {
                                    ForEach(GlobalData.shared.getFirstHalf(), id: \.self) { fighter in
                                        Button(action: {
                                            addFighter(fighter: fighter)
                                        }) {
                                            SquarePortraitView(fighter: fighter, outfitIndex: 0, isSelected: self.isSelected(fighter: fighter), isInverted: false)
                                        }
                                    }
                                }
                                HStack(spacing: 5) {
                                    ForEach(GlobalData.shared.getSecondHalf(), id: \.self) { fighter in
                                        Button(action: {
                                            addFighter(fighter: fighter)
                                        }) {
                                            SquarePortraitView(fighter: fighter, outfitIndex: 0, isSelected: self.isSelected(fighter: fighter), isInverted: false)
                                        }
                                    }
                                }
                            }
                            .disabled(true)
                        }
                    }
                    .padding(.horizontal, outerPadding).clipped()
                } else if infoToggle {
                    ScrollViewReader { value in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: innerPadding) {
                                HStack(spacing: innerPadding) {
                                    ZStack {
                                        Rectangle().fill(Color("MainPanel"))
                                            .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                        HStack {
                                            Button(action: {
                                            }) {
                                                ClearButton(label: "<", width: 35, height: smallHeight)
                                            }
                                            .onChange(of: isNatureDecreasing, perform: { _ in
                                                Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                                    if self.isNatureDecreasing == true {
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if selectedNature <= 0 {
                                                            selectedNature = GlobalData.shared.natures.count - 1
                                                        } else {
                                                            selectedNature -= 1
                                                        }
                                                    } else {
                                                        timer.invalidate()
                                                        
                                                        tutorialCounter += 1
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
                                                        
                                                        if selectedNature <= 0 {
                                                            selectedNature = GlobalData.shared.natures.count - 1
                                                        } else {
                                                            selectedNature -= 1
                                                        }
                                                        
                                                        tutorialCounter += 1
                                                        
                                                        fighters[selectedSlot]!.setNature(nature: selectedNature)
                                                    })
                                            CustomText(text: Localization.shared.getTranslation(key: GlobalData.shared.natures[selectedNature].name).uppercased(), fontSize: smallFont).frame(maxWidth: .infinity)
                                            Button(action: {
                                            }) {
                                                ClearButton(label: ">", width: 35, height: smallHeight)
                                            }
                                            .onChange(of: isNatureIncreasing, perform: { _ in
                                                Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                                    if self.isNatureIncreasing == true {
                                                        AudioPlayer.shared.playStandardSound()
                                                        
                                                        if selectedNature >= GlobalData.shared.natures.count - 1 {
                                                            selectedNature = 0
                                                        } else {
                                                            selectedNature += 1
                                                        }
                                                        
                                                        fighters[selectedSlot]!.setNature(nature: selectedNature)
                                                    } else {
                                                        timer.invalidate()
                                                        
                                                        tutorialCounter += 1
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
                                                        
                                                        if selectedNature >= GlobalData.shared.natures.count - 1 {
                                                            selectedNature = 0
                                                        } else {
                                                            selectedNature += 1
                                                        }
                                                        
                                                        tutorialCounter += 1
                                                        
                                                        fighters[selectedSlot]!.setNature(nature: selectedNature)
                                                    })
                                        }
                                        .padding(.horizontal, 2)
                                    }
                                    .disabled(tutorialCounter != 3 && tutorialCounter != 4)
                                    .opacity(blinking && (tutorialCounter == 3 || tutorialCounter == 4 ) ? 0.4 : 1)
                                    Button(action: {
                                        AudioPlayer.shared.playCancelSound()
                                        
                                        fighters[selectedSlot] = nil
                                        
                                        tutorialCounter = 11
                                        
                                        selectionToggle = true
                                        infoToggle = false
                                    }) {
                                        BorderedButton(label: "remove", width: 120, height: smallHeight, isInverted: false)
                                    }
                                    .disabled(tutorialCounter != 10)
                                    .opacity(blinking && tutorialCounter == 10 ? 0.4 : 1)
                                }
                                .id(0)
                                BaseFighterOverviewView(base: fighters[selectedSlot]!.getModifiedBase())
                                VStack(spacing: innerPadding/2) {
                                    ForEach(fighters[selectedSlot]!.spells, id: \.self) { spell in
                                        SpellView(spell: spell, desccription: Localization.shared.getTranslation(key: spell.name + "Descr"))
                                    }
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel")).frame(height: 60)
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                    HStack(spacing: 0) {
                                        Button(action: {
                                        }) {
                                            ClearButton(label: "<", width: 40, height: 60)
                                        }
                                        .onChange(of: isArtifactDecreasing, perform: { _ in
                                            Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                                if self.isArtifactDecreasing == true {
                                                    AudioPlayer.shared.playStandardSound()
                                                    
                                                    if selectedArtifact <= 0 {
                                                        selectedArtifact = Artifacts.allCases.count - 1
                                                    } else {
                                                        selectedArtifact -= 1
                                                    }
                                                    
                                                    fighters[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                                } else {
                                                    timer.invalidate()
                                                    
                                                    tutorialCounter += 1
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
                                                    
                                                    if selectedArtifact <= 0 {
                                                        selectedArtifact = Artifacts.allCases.count - 1
                                                    } else {
                                                        selectedArtifact -= 1
                                                    }
                                                    
                                                    tutorialCounter += 1
                                                    
                                                    fighters[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                                })
                                        VStack {
                                            CustomText(text: Localization.shared.getTranslation(key: Artifacts.allCases[selectedArtifact].getArtifact().name).uppercased(), fontSize: mediumFont, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                            CustomText(text: Localization.shared.getTranslation(key: Artifacts.allCases[selectedArtifact].getArtifact().description), fontSize: smallFont).frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        Button(action: {
                                        }) {
                                            ClearButton(label: ">", width: 40, height: 60)
                                        }
                                        .onChange(of: isArtifactIncreasing, perform: { _ in
                                            Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: true) { timer in
                                                if self.isArtifactIncreasing == true {
                                                    AudioPlayer.shared.playStandardSound()
                                                    
                                                    if selectedArtifact >= Artifacts.allCases.count - 1 {
                                                        selectedArtifact = 0
                                                    } else {
                                                        selectedArtifact += 1
                                                    }
                                                    
                                                    fighters[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                                } else {
                                                    timer.invalidate()
                                                    
                                                    tutorialCounter += 1
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
                                                    
                                                    if selectedArtifact >= Artifacts.allCases.count - 1 {
                                                        selectedArtifact = 0
                                                    } else {
                                                        selectedArtifact += 1
                                                    }
                                                    
                                                    tutorialCounter += 1
                                                    
                                                    fighters[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                                })
                                    }
                                }
                                .disabled(tutorialCounter != 5 && tutorialCounter != 6)
                                .opacity(blinking && (tutorialCounter == 5 || tutorialCounter == 6) ? 0.4 : 1)
                                HStack(spacing: innerPadding) {
                                    Button(action: {
                                        AudioPlayer.shared.playStandardSound()
                                        
                                        let fighter: SavedFighterData = SavedFighterData(fighter: fighters[selectedSlot]!)
                                        if GlobalData.shared.isSaved(fighter: fighter) {
                                            GlobalData.shared.removeFighter(fighter: fighter)
                                        } else {
                                            GlobalData.shared.saveFighter(fighter: fighter)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            SaveData.saveSettings()
                                        }
                                    }) {
                                        BorderedButton(label: GlobalData.shared.isSaved(fighter: SavedFighterData(fighter: fighters[selectedSlot]!)) ? Localization.shared.getTranslation(key: "remove") : Localization.shared.getTranslation(key: "save"), width: 120, height: smallHeight, isInverted: false)
                                    }
                                    .disabled(true)
                                    ZStack {
                                        Rectangle().fill(Color("MainPanel"))
                                            .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                                        HStack {
                                            Button(action: {
                                                AudioPlayer.shared.playStandardSound()
                                                
                                                if fighters[selectedSlot]!.outfitIndex <= 0 {
                                                    fighters[selectedSlot]!.outfitIndex = fighters[selectedSlot]!.data.outfits.count - 1
                                                } else {
                                                    fighters[selectedSlot]!.outfitIndex -= 1
                                                }
                                                
                                                while !GlobalData.shared.userProgress.isOutfitUnlocked(fighter: fighters[selectedSlot]!.name, index: fighters[selectedSlot]!.outfitIndex) {
                                                    fighters[selectedSlot]!.outfitIndex -= 1
                                                }
                                                
                                                selectedOutfit = fighters[selectedSlot]!.outfitIndex
                                            }) {
                                                ClearButton(label: "<", width: 35, height: smallHeight)
                                            }
                                            CustomText(text: Localization.shared.getTranslation(key: fighters[selectedSlot]!.data.outfits[selectedOutfit].name).uppercased(), fontSize: smallFont).frame(maxWidth: .infinity)
                                            Button(action: {
                                                AudioPlayer.shared.playStandardSound()
                                                
                                                if fighters[selectedSlot]!.outfitIndex >= fighters[selectedSlot]!.data.outfits.count - 1 {
                                                    fighters[selectedSlot]!.outfitIndex = 0
                                                } else {
                                                    fighters[selectedSlot]!.outfitIndex += 1
                                                    
                                                    while !GlobalData.shared.userProgress.isOutfitUnlocked(fighter: fighters[selectedSlot]!.name, index: fighters[selectedSlot]!.outfitIndex) {
                                                        fighters[selectedSlot]!.outfitIndex += 1
                                                        
                                                        if fighters[selectedSlot]!.outfitIndex > fighters[selectedSlot]!.data.outfits.count - 1 {
                                                            fighters[selectedSlot]!.outfitIndex = 0
                                                            break
                                                        }
                                                    }
                                                }
                                                
                                                selectedOutfit = fighters[selectedSlot]!.outfitIndex
                                            }) {
                                                ClearButton(label: ">", width: 35, height: smallHeight)
                                            }
                                        }
                                        .padding(.horizontal, 2)
                                    }
                                }
                                .id(1)
                            }
                            .padding(.horizontal, outerPadding)
                            .onAppear {
                                blinking = false
                                withAnimation(blinkAnimation) {
                                    blinking = true
                                }
                            }
                        }
                        .padding(.vertical, outerPadding)
                        .onAppear {
                            selectedNature = getNature(fighter: fighters[selectedSlot]!)
                            selectedArtifact = getArtifact(fighter: fighters[selectedSlot]!)
                            selectedOutfit = fighters[selectedSlot]!.outfitIndex
                        }
                        .onChange(of: tutorialCounter) { newValue in
                            if newValue == 5 {
                                withAnimation(.easeInOut) {
                                    blinking = false
                                    value.scrollTo(1)
                                    withAnimation(blinkAnimation) {
                                        blinking = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 175).offset(y: offset).animation(.linear(duration: 0.2), value: offset)
        }
    }
}

struct TutorialPlayerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialPlayerSelectionView(opponents: [waterFighter, waterFighter, nil, nil], fighters: Binding.constant([waterFighter, nil, nil, nil]), tutorialCounter: Binding.constant(0))
    }
}
