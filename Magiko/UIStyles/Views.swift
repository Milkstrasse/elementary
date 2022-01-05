//
//  Views.swift
//  Magiko
//
//  Created by Janice Hablützel on 05.01.22.
//

import SwiftUI

struct DetailedActionView: View {
    var title: String
    var description: String
    
    var width: CGFloat?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(Color.yellow)
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(title)
                    Text(description)
                }
                .padding(.leading, 15)
                Spacer()
                Triangle().fill(Color.green).frame(width: 22)
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.green).frame(width: 25)
                    RoundedRectangle(cornerRadius: 5).fill(Color.green).frame(width: 55)
                }
            }
        }
        .frame(width: width, height: 60)
    }
}

struct SimpleAttackView: View {
    var title: String
    
    var width: CGFloat?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(Color.yellow)
            HStack(spacing: 0) {
                ZStack(alignment: .trailing) {
                    Rectangle().fill(Color.green).frame(width: 25)
                    RoundedRectangle(cornerRadius: 5).fill(Color.green).frame(width: 75)
                }
                Triangle().fill(Color.green).frame(width: 16).rotationEffect(.degrees(180))
                HStack(spacing: 0) {
                    Text(title)
                    Text(" - " + "Very effective")
                }
                .padding(.leading, 15)
                Spacer()
            }
        }
        .frame(width: width, height: 45)
    }
}

struct RectangleFighterView: View {
    let fighterData: FighterData
    var isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 5).fill(isSelected ? Color.yellow : Color.blue).frame(height: 125)
            Image(fighterData.name).resizable().scaleEffect(4.6).aspectRatio(contentMode: .fit).frame(height: 125).offset(y: 100).clipShape(RoundedRectangle(cornerRadius: 5))
            Triangle().fill(Color.green).frame(height: 35).padding(.bottom, 10)
            Rectangle().fill(Color.green).frame(height: 5).padding(.bottom, 5)
            RoundedRectangle(cornerRadius: 5).fill(Color.green).frame(height: 10)
        }
        .contentShape(Rectangle())
    }
}

struct BaseOverviewView: View {
    let base: Base
    
    var width: CGFloat?
    
    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 75)
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Health")
                            Spacer()
                            Text("\(base.health)")
                        }
                        HStack {
                            Text("Attack")
                            Spacer()
                            Text("\(base.attack)")
                        }
                        HStack {
                            Text("Defense")
                            Spacer()
                            Text("\(base.defense)")
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 75)
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Agility")
                            Spacer()
                            Text("\(base.agility)")
                        }
                        HStack {
                            Text("Precision")
                            Spacer()
                            Text("\(base.precision)")
                        }
                        HStack {
                            Text("Sp. Attack")
                            Spacer()
                            Text("\(base.spAttack)")
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .frame(width: width)
    }
}

struct Views_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DetailedActionView(title: "Title", description: "Description")
            SimpleAttackView(title: "Title")
            RectangleFighterView(fighterData: FighterData(name: "magicalgirl_1", element: "Water", skills: [""], base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, spAttack: 100)), isSelected: false).frame(width: 100)
            BaseOverviewView(base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, spAttack: 100))
        }
    }
}
