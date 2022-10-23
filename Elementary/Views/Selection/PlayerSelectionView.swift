//
//  PlayerSelectionView.swift
//  Elementary
//
//  Created by Janice Hablützel on 22.08.22.
//

import SwiftUI

struct PlayerSelectionView: View {
    let opponents: [Fighter?]
    
    @Binding var fighters: [Fighter?]
    @State var selectedSlot: Int = -1
    @State var selectedNature: Int = 0
    @State var selectedArtifact: Int = 0
    
    @State var offset: CGFloat = 175
    @State var selectionToggle: Bool = false
    @State var infoToggle: Bool = false
    
    @GestureState var isNatureDecreasing = false
    @GestureState var isNatureIncreasing = false
    @GestureState var isArtifactDecreasing = false
    @GestureState var isArtifactIncreasing = false
    
    /// Tries to add a selected fighter to the team.
    /// - Parameter fighter: The selected fighter
    func addFighter(fighter: Fighter) {
        if GlobalData.shared.artifactUse == 1 && isArtifactInUse(artifact: getArtifact(fighter: fighter)) {
            AudioPlayer.shared.playCancelSound()
        } else if GlobalData.shared.teamLimit == 0 {
            AudioPlayer.shared.playStandardSound()
            fighters[selectedSlot] = SavedFighterData(fighter: fighter).toFighter() //make copy
        } else if !isPartOfTeam(fighter: fighter) {
            if GlobalData.shared.teamLimit == 2 {
                for opponent in opponents {
                    if opponent != nil && opponent!.name == fighter.name {
                        AudioPlayer.shared.playCancelSound()
                        return
                    }
                }
            }
            
            AudioPlayer.shared.playStandardSound()
            fighters[selectedSlot] = SavedFighterData(fighter: fighter).toFighter() //make copy
        } else {
            AudioPlayer.shared.playCancelSound()
        }
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
            if selectedFighter != nil && fighter.name == selectedFighter!.name {
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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack(spacing: innerPadding) {
                    ForEach(0 ..< 4) { index in
                        Button(action: {
                            AudioPlayer.shared.playStandardSound()
                            
                            if selectedSlot == index {
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
                                selectedSlot = index
                                
                                if fighters[index] != nil {
                                    selectedNature = getNature(fighter: fighters[selectedSlot]!)
                                    selectedArtifact = getArtifact(fighter: fighters[selectedSlot]!)
                                    
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
                            SquarePortraitView(fighter: fighters[index], isSelected: index == selectedSlot, isInverted: true)
                        }
                    }
                }
                Spacer()
            }
            ZStack {
                Rectangle().fill(Color("Panel")).shadow(radius: 5, x: 5, y: 0)
                if selectionToggle {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: innerPadding) {
                            if !GlobalData.shared.savedFighters.isEmpty {
                                VStack(spacing: 5) {
                                    HStack(spacing: 5) {
                                        ForEach(GlobalData.shared.getFirstSavedHalf(), id: \.self) { fighter in
                                            Button(action: {
                                                addFighter(fighter: fighter)
                                            }) {
                                                SquarePortraitView(fighter: fighter, isSelected: self.isSelected(fighter: fighter), isInverted: false)
                                            }
                                        }
                                    }
                                    HStack(spacing: 5) {
                                        ForEach(GlobalData.shared.getSecondSavedHalf(), id: \.self) { fighter in
                                            Button(action: {
                                                addFighter(fighter: fighter)
                                            }) {
                                                SquarePortraitView(fighter: fighter, isSelected: self.isSelected(fighter: fighter), isInverted: false)
                                            }
                                        }
                                    }
                                    if GlobalData.shared.savedFighters.count == 1 {
                                        Spacer().frame(width: 65, height: 65)
                                    }
                                }
                            }
                            VStack(spacing: 5) {
                                HStack(spacing: 5) {
                                    ForEach(GlobalData.shared.getFirstHalf(), id: \.self) { fighter in
                                        Button(action: {
                                            addFighter(fighter: fighter)
                                        }) {
                                            SquarePortraitView(fighter: fighter, isSelected: self.isSelected(fighter: fighter), isInverted: false)
                                        }
                                    }
                                }
                                HStack(spacing: 5) {
                                    ForEach(GlobalData.shared.getSecondHalf(), id: \.self) { fighter in
                                        Button(action: {
                                            addFighter(fighter: fighter)
                                        }) {
                                            SquarePortraitView(fighter: fighter, isSelected: self.isSelected(fighter: fighter), isInverted: false)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, outerPadding).clipped()
                } else if infoToggle {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: innerPadding) {
                            HStack(spacing: innerPadding/2) {
                                ZStack {
                                    Rectangle().fill(Color("Panel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
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
                                                    
                                                    fighters[selectedSlot]!.setNature(nature: selectedNature)
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
                                                    
                                                    if selectedNature <= 0 {
                                                        selectedNature = GlobalData.shared.natures.count - 1
                                                    } else {
                                                        selectedNature -= 1
                                                    }
                                                    
                                                    fighters[selectedSlot]!.setNature(nature: selectedNature)
                                                })
                                        CustomText(text: Localization.shared.getTranslation(key: GlobalData.shared.natures[selectedNature].name).uppercased(), fontSize: 14).frame(maxWidth: .infinity)
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
                                                    
                                                    fighters[selectedSlot]!.setNature(nature: selectedNature)
                                                })
                                    }
                                    .padding(.horizontal, 2)
                                }
                                Button(action: {
                                    AudioPlayer.shared.playCancelSound()
                                    
                                    fighters[selectedSlot] = nil
                                    
                                    selectionToggle = true
                                    infoToggle = false
                                }) {
                                    BorderedButton(label: Localization.shared.getTranslation(key: "remove"), width: 120, height: smallHeight, isInverted: false)
                                }
                            }
                            BaseFighterOverviewView(base: fighters[selectedSlot]!.getModifiedBase())
                            VStack(spacing: innerPadding/2) {
                                ForEach(fighters[selectedSlot]!.spells, id: \.self) { spell in
                                    SpellView(spell: spell, desccription: Localization.shared.getTranslation(key: spell.name + "Descr"))
                                }
                            }
                            ZStack {
                                Rectangle().fill(Color("Panel")).frame(height: 60)
                                    .overlay(Rectangle().strokeBorder(Color("Border1"), lineWidth: borderWidth))
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
                                                
                                                if GlobalData.shared.artifactUse == 1 {
                                                    while isArtifactInUse(artifact: selectedArtifact) {
                                                        if selectedArtifact <= 0 {
                                                            selectedArtifact = Artifacts.allCases.count - 1
                                                        } else {
                                                            selectedArtifact -= 1
                                                        }
                                                    }
                                                }
                                                
                                                fighters[selectedSlot]!.setArtifact(artifact: selectedArtifact)
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
                                                
                                                fighters[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                            })
                                    VStack {
                                        CustomText(text: Localization.shared.getTranslation(key: Artifacts.allCases[selectedArtifact].getArtifact().name).uppercased(), fontSize: 16, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                        CustomText(text: Localization.shared.getTranslation(key: Artifacts.allCases[selectedArtifact].getArtifact().description), fontSize: 14).frame(maxWidth: .infinity, alignment: .leading)
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
                                                
                                                if GlobalData.shared.artifactUse == 1 {
                                                    while isArtifactInUse(artifact: selectedArtifact) {
                                                        if selectedArtifact >= Artifacts.allCases.count - 1 {
                                                            selectedArtifact = 0
                                                        } else {
                                                            selectedArtifact += 1
                                                        }
                                                    }
                                                }
                                                
                                                fighters[selectedSlot]!.setArtifact(artifact: selectedArtifact)
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
                                                
                                                if selectedArtifact >= Artifacts.allCases.count - 1 {
                                                    selectedArtifact = 0
                                                } else {
                                                    selectedArtifact += 1
                                                }
                                                
                                                if GlobalData.shared.artifactUse == 1 {
                                                    while isArtifactInUse(artifact: selectedArtifact) {
                                                        if selectedArtifact >= Artifacts.allCases.count - 1 {
                                                            selectedArtifact = 0
                                                        } else {
                                                            selectedArtifact += 1
                                                        }
                                                    }
                                                }
                                                
                                                fighters[selectedSlot]!.setArtifact(artifact: selectedArtifact)
                                            })
                                }
                            }
                            HStack(spacing: innerPadding/2) {
                                Button(action: {
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    let fighter: SavedFighterData = SavedFighterData(fighter: fighters[selectedSlot]!)
                                    if GlobalData.shared.isSaved(fighter: fighter) {
                                        GlobalData.shared.removeFighter(fighter: fighter)
                                    } else {
                                        GlobalData.shared.saveFighter(fighter: fighter)
                                    }
                                    
                                    DispatchQueue.main.async {
                                        SaveLogic.shared.save()
                                    }
                                }) {
                                    BorderedButton(label: GlobalData.shared.isSaved(fighter: SavedFighterData(fighter: fighters[selectedSlot]!)) ? Localization.shared.getTranslation(key: "remove") : Localization.shared.getTranslation(key: "save"), width: 120, height: smallHeight, isInverted: false)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, outerPadding)
                    }
                    .padding(.vertical, outerPadding)
                    .onAppear {
                        selectedNature = getNature(fighter: fighters[selectedSlot]!)
                        selectedArtifact = getArtifact(fighter: fighters[selectedSlot]!)
                    }
                }
            }
            .frame(height: 175).offset(y: offset).animation(.linear(duration: 0.2), value: offset)
        }
    }
}

struct PlayerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSelectionView(opponents: [exampleFighter, exampleFighter, nil, nil], fighters: Binding.constant([exampleFighter, nil, nil, nil]))
    }
}
