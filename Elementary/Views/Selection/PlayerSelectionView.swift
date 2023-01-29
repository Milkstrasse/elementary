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
    @Binding var selectedSlot: Int
    @State var selectedNature: Int = 0
    @State var selectedArtifact: Int = 0
    @State var selectedOutfit: Int = 0
    
    let height: CGFloat
    let singleMode: Bool
    
    @Binding var offset: CGFloat
    @Binding var selectionToggle: Bool
    @Binding var infoToggle: Bool
    
    @GestureState var isNatureDecreasing = false
    @GestureState var isNatureIncreasing = false
    @GestureState var isArtifactDecreasing = false
    @GestureState var isArtifactIncreasing = false
    
    /// Tries to add a selected fighter to the team.
    /// - Parameter fighter: The selected fighter
    /// - Returns: Returns if fighter was successfully added to the team
    func addFighter(fighter: Fighter) -> Bool {
        if GlobalData.shared.artifactUse == 1 && isArtifactInUse(artifact: getArtifact(fighter: fighter)) {
            AudioPlayer.shared.playCancelSound()
            return false
        } else if GlobalData.shared.teamLimit == 0 {
            AudioPlayer.shared.playStandardSound()
            fighters[selectedSlot] = SavedFighterData(fighter: fighter).toFighter(images: fighter.images) //make copy
            return true
        } else if !isPartOfTeam(fighter: fighter) {
            if GlobalData.shared.teamLimit == 2 {
                for opponent in opponents {
                    if opponent?.name == fighter.name {
                        AudioPlayer.shared.playCancelSound()
                        return false
                    }
                }
            }
            
            AudioPlayer.shared.playStandardSound()
            fighters[selectedSlot] = SavedFighterData(fighter: fighter).toFighter(images: fighter.images) //make copy
            return true
        } else {
            AudioPlayer.shared.playCancelSound()
            return false
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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack(spacing: General.innerPadding/2) {
                    ForEach(0 ..< fighters.count, id: \.self) { index in
                        Button(action: {
                        }) {
                            SquarePortraitView(fighter: fighters[index], outfitIndex: fighters[index]?.outfitIndex ?? 0, isSelected: index == selectedSlot, isInverted: true)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded({ _ in
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    selectedSlot = index
                                    
                                    addFighter(fighter: TeamManager.getRandomFighter(fighters: fighters, opponents: opponents))
                                    offset = 0
                                    
                                    selectionToggle = false
                                    infoToggle = true
                                })
                        )
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded { _ in
                                    AudioPlayer.shared.playStandardSound()
                                    
                                    if selectedSlot == index {
                                        if selectionToggle && fighters[index] != nil {
                                            offset = 0
                                            
                                            selectionToggle = false
                                            infoToggle = true
                                        } else {
                                            offset = height
                                            
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

                                })
                    }
                }
                Spacer()
            }
            ZStack(alignment: .top) {
                Rectangle().fill(Color("MainPanel")).shadow(radius: 5, x: 5, y: 0)
                if selectionToggle {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: General.innerPadding) {
                            if !GlobalData.shared.savedFighters.isEmpty { //saved fighters
                                VStack(spacing: 5) {
                                    HStack(spacing: 5) {
                                        ForEach(GlobalData.shared.getFirstSavedHalf(), id: \.self) { fighter in
                                            Button(action: {
                                                if addFighter(fighter: fighter) {
                                                    offset = 0
                                                    
                                                    selectionToggle = false
                                                    infoToggle = true
                                                }
                                            }) {
                                                SquarePortraitView(fighter: fighter, outfitIndex: fighter.outfitIndex, isSelected: self.isSelected(fighter: fighter), isInverted: false)
                                            }
                                        }
                                    }
                                    HStack(spacing: 5) {
                                        ForEach(GlobalData.shared.getSecondSavedHalf(), id: \.self) { fighter in
                                            Button(action: {
                                                if addFighter(fighter: fighter) {
                                                    offset = 0
                                                    
                                                    selectionToggle = false
                                                    infoToggle = true
                                                }
                                            }) {
                                                SquarePortraitView(fighter: fighter, outfitIndex: fighter.outfitIndex, isSelected: self.isSelected(fighter: fighter), isInverted: false)
                                            }
                                        }
                                    }
                                    if GlobalData.shared.savedFighters.count == 1 {
                                        Spacer().frame(width: 65, height: 65)
                                    }
                                }
                            }
                            VStack(alignment: .leading, spacing: 5) { //all fighters
                                HStack(spacing: 5) {
                                    ForEach(GlobalData.shared.getFirstHalf(), id: \.self) { fighter in
                                        Button(action: {
                                            if addFighter(fighter: fighter) {
                                                offset = 0
                                                
                                                selectionToggle = false
                                                infoToggle = true
                                            }
                                        }) {
                                            SquarePortraitView(fighter: fighter, outfitIndex: 0, isSelected: self.isSelected(fighter: fighter), isInverted: false)
                                        }
                                    }
                                }
                                HStack(spacing: 5) {
                                    ForEach(GlobalData.shared.getSecondHalf(), id: \.self) { fighter in
                                        Button(action: {
                                            if addFighter(fighter: fighter) {
                                                offset = 0
                                                
                                                selectionToggle = false
                                                infoToggle = true
                                            }
                                        }) {
                                            SquarePortraitView(fighter: fighter, outfitIndex: 0, isSelected: self.isSelected(fighter: fighter), isInverted: false)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, General.outerPadding)
                    }
                    .padding(.horizontal, General.outerPadding).clipped()
                } else if infoToggle {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: General.innerPadding) {
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color("Positive"))
                                HStack(spacing: 0) {
                                    CustomText(text: Localization.shared.getTranslation(key: fighters[selectedSlot]!.name).uppercased(), fontSize: General.mediumFont, isBold: true)
                                    CustomText(text: " - " + Localization.shared.getTranslation(key: fighters[selectedSlot]!.title).uppercased(), fontSize: General.smallFont, isBold: false)
                                    Spacer()
                                    Text(General.createSymbol(string: fighters[selectedSlot]!.getElement().symbol)).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color("Text")).frame(width: General.smallHeight, height: General.smallHeight)
                                }
                                .frame(height: General.largeHeight).padding(.leading, General.innerPadding)
                            }
                            HStack(spacing: General.innerPadding) {
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                    HStack {
                                        Button(action: {
                                        }) {
                                            ClearButton(label: "<", width: 35, height: General.smallHeight)
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
                                        CustomText(text: Localization.shared.getTranslation(key: GlobalData.shared.natures[selectedNature].name).uppercased(), fontSize: General.smallFont).frame(maxWidth: .infinity)
                                        Button(action: {
                                        }) {
                                            ClearButton(label: ">", width: 35, height: General.smallHeight)
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
                                    BorderedButton(label: "remove", width: 120, height: General.smallHeight, isInverted: false)
                                }
                            }
                            BaseFighterOverviewView(modifiedBase: fighters[selectedSlot]!.getModifiedBase(), base: fighters[selectedSlot]!.base)
                            VStack(spacing: General.innerPadding/2) {
                                if singleMode {
                                    ForEach(fighters[selectedSlot]!.singleSpells, id: \.self) { spell in
                                        SpellView(spell: spell, desccription: Localization.shared.getTranslation(key: spell.name + "Descr"))
                                    }
                                } else {
                                    ForEach(fighters[selectedSlot]!.multiSpells, id: \.self) { spell in
                                        SpellView(spell: spell, desccription: Localization.shared.getTranslation(key: spell.name + "Descr"))
                                    }
                                }
                            }
                            ZStack {
                                Rectangle().fill(Color("MainPanel")).frame(height: 60)
                                    .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
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
                                        CustomText(text: Localization.shared.getTranslation(key: Artifacts.allCases[selectedArtifact].getArtifact().name).uppercased(), fontSize: General.mediumFont, isBold: true).frame(maxWidth: .infinity, alignment: .leading)
                                        CustomText(text: Localization.shared.getTranslation(key: Artifacts.allCases[selectedArtifact].getArtifact().description), fontSize: General.smallFont).frame(maxWidth: .infinity, alignment: .leading)
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
                            HStack(spacing: General.innerPadding) {
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
                                    BorderedButton(label: GlobalData.shared.isSaved(fighter: SavedFighterData(fighter: fighters[selectedSlot]!)) ? Localization.shared.getTranslation(key: "unfavorite") : Localization.shared.getTranslation(key: "favorite"), width: 120, height: General.smallHeight, isInverted: false)
                                }
                                ZStack {
                                    Rectangle().fill(Color("MainPanel"))
                                        .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
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
                                            ClearButton(label: "<", width: 35, height: General.smallHeight)
                                        }
                                        CustomText(text: Localization.shared.getTranslation(key: fighters[selectedSlot]!.data.outfits[selectedOutfit].name).uppercased(), fontSize: General.smallFont).frame(maxWidth: .infinity)
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
                                            ClearButton(label: ">", width: 35, height: General.smallHeight)
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }
                        }
                        .padding(.horizontal, General.outerPadding)
                    }
                    .frame(height: 175 - 2 * General.outerPadding).padding(.vertical, General.outerPadding)
                    .onAppear {
                        selectedNature = getNature(fighter: fighters[selectedSlot]!)
                        selectedArtifact = getArtifact(fighter: fighters[selectedSlot]!)
                        selectedOutfit = fighters[selectedSlot]!.outfitIndex
                    }
                }
            }
            .frame(height: height).offset(y: offset).animation(.linear(duration: 0.2), value: offset)
        }
    }
}

struct PlayerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSelectionView(opponents: [GlobalData.shared.fighters[0], GlobalData.shared.fighters[0], nil, nil], fighters: Binding.constant([GlobalData.shared.fighters[0], nil, nil, nil]), selectedSlot: Binding.constant(-1), height: 175, singleMode: false, offset: Binding.constant(175), selectionToggle: Binding.constant(false), infoToggle: Binding.constant(false))
    }
}
