//
//  OverviewView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct OverviewView: View {
    @State var fighterSelected: Bool = false
    @State var infoToggle: Bool = false
    
    @Binding var currentFighter: FighterData
    
    @Binding var overviewToggle: Bool
    @Binding var offsetX: CGFloat
    
    func getRowAmount() -> Int {
        if GlobalData.allFighterData.count%3 > 0 {
            return GlobalData.allFighterData.count/3 + 1
        } else {
            return GlobalData.allFighterData.count/3
        }
    }
    
    func getSubArray(row: Int) -> [FighterData?] {
        if (3 + row * 3) < GlobalData.allFighterData.count {
            let rowArray = GlobalData.allFighterData[row * 3 ..< 3 + row * 3]
            return Array(rowArray)
        } else {
            let rowArray = GlobalData.allFighterData[row * 3 ..< GlobalData.allFighterData.count]
            
            var subArray: [FighterData?] = Array(rowArray)
            for _ in (0 ..< (row + 1) * 3 - GlobalData.allFighterData.count) {
                subArray.append(nil)
            }
            return subArray
        }
    }
    
    func isSelected(fighter: FighterData) -> Bool {
        if fighterSelected {
            return fighter.name == currentFighter.name
        } else {
            return false
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if fighterSelected {
                    HStack(alignment: .top) {
                        Button(infoToggle ? "X" : "?") {
                            infoToggle = !infoToggle
                        }
                        .buttonStyle(GrowingButton(width: 40))
                        Spacer()
                        ZStack {
                            Color.red
                            VStack(alignment: .leading, spacing: 5) {
                                Text(currentFighter.name)
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 5) {
                                        BaseOverviewView(base: currentFighter.base).padding(.bottom, 5)
                                        DetailedActionView(title: "Attack", description: "Description")
                                        DetailedActionView(title: "Attack", description: "Description")
                                        DetailedActionView(title: "Attack", description: "Description")
                                        DetailedActionView(title: "Attack", description: "Description")
                                    }
                                }
                            }
                        }
                        .frame(width: 345).offset(x: infoToggle ? 0 : 224).animation(.linear(duration: 0.2), value: infoToggle)
                    }
                    .padding(.all, 15)
                }
                ZStack(alignment: .trailing) {
                    HStack(spacing: 0) {
                        Spacer()
                        Triangle().fill(Color.pink).frame(width: 134)
                        Rectangle().fill(Color.pink).frame(width: 315 + geometry.safeAreaInsets.trailing)
                    }
                    .offset(x: geometry.safeAreaInsets.trailing)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Overview").frame(height: 60).padding([.top, .leading], 15)
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 8) {
                                ForEach(0 ..< self.getRowAmount()) { row in
                                    HStack(spacing: 8) {
                                        ForEach(self.getSubArray(row: row), id: \.?.name) { fighter in
                                            if fighter != nil {
                                                RectangleFighterView(fighterData: fighter!, isSelected: self.isSelected(fighter: fighter!))
                                                    .onTapGesture {
                                                        print(fighter!.name)
                                                        fighterSelected = true
                                                        currentFighter = fighter!
                                                }
                                            } else {
                                                Color.clear
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                        Spacer().frame(height: 10)
                        HStack(spacing: 5) {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(width: 160, height: 40)
                                HStack {
                                    Button("<") {
                                        print("Button pressed!")
                                    }
                                    Spacer()
                                    Text("All Types")
                                    Spacer()
                                    Button(">") {
                                        print("Button pressed!")
                                    }
                                }
                                .frame(width: 130).padding(.horizontal, 15)
                            }
                            Button("X") {
                                fighterSelected = false
                                offsetX = -449
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    overviewToggle = false
                                }
                            }
                            .buttonStyle(GrowingButton(width: 40))
                        }
                        .padding(.trailing, 15)
                    }
                    .frame(width: 340).padding(.vertical, 15)
                }
                .padding(.trailing, offsetX).animation(.linear(duration: 0.2), value: offsetX).offset(x: infoToggle ? 449 : 0).animation(.linear(duration: 0.2), value: infoToggle)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            offsetX = 0
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(currentFighter: Binding.constant(FighterData(name: "magicalgirl_1", element: "Water", skills: [""], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, spAttack: 100))), overviewToggle: Binding.constant(true), offsetX: Binding.constant(0))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
