//
//  Views.swift
//  Magiko
//
//  Created by Janice Hablützel on 05.01.22.
//

import SwiftUI

struct BigBarView: View {
    var width: CGFloat?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(Color.yellow)
            HStack(spacing: 0) {
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

struct DetailedActionView: View {
    let title: String
    let description: String
    
    var width: CGFloat?
    
    var body: some View {
        ZStack {
            BigBarView()
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    CustomText(key: title)
                    CustomText(key: description)
                }
                .padding(.leading, 15)
                Spacer()
            }
        }
        .frame(width: width, height: 60)
    }
}

struct DetailedSkillView: View {
    let skill: Skill
    
    var width: CGFloat?
    
    func getTranslationKey() -> String {
        var key: String = skill.name.lowercased()
        key = key.replacingOccurrences(of: " ", with: "")
        
        return key + "Descr"
    }
    
    var body: some View {
        ZStack {
            BigBarView()
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    CustomText(key: skill.name)
                    CustomText(key: getTranslationKey())
                }
                .padding(.leading, 15)
                Spacer()
            }
        }
        .frame(width: width, height: 60)
    }
}

struct SimpleAttackView: View {
    let title: String
    
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
                    CustomText(key: title)
                    CustomText(key: " - " + "Very effective")
                }
                .padding(.leading, 15)
                Spacer()
            }
        }
        .frame(width: width, height: 45)
    }
}

struct RectangleFighterView: View {
    let fighter: Fighter
    var isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 5).fill(isSelected ? Color.yellow : Color.blue).frame(height: 125)
            Image(fighter.name).resizable().scaleEffect(4.6).aspectRatio(contentMode: .fit).frame(height: 125).offset(y: 100).clipShape(RoundedRectangle(cornerRadius: 5))
            Triangle().fill(Color.green).frame(height: 35).padding(.bottom, 10)
            Rectangle().fill(Color.green).frame(height: 5).padding(.bottom, 5)
            RoundedRectangle(cornerRadius: 5).fill(Color.green).frame(height: 10)
            CustomText(text: String(fighter.element.name.first ?? "?")).frame(width: 35, height: 35)
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
                            CustomText(key: "health")
                            Spacer()
                            CustomText(text: "\(base.health)")
                        }
                        HStack {
                            CustomText(key: "attack")
                            Spacer()
                            CustomText(text: "\(base.attack)")
                        }
                        HStack {
                            CustomText(key: "defense")
                            Spacer()
                            CustomText(text: "\(base.defense)")
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
                            CustomText(key: "agility")
                            Spacer()
                            CustomText(text: "\(base.agility)")
                        }
                        HStack {
                            CustomText(key: "precision")
                            Spacer()
                            CustomText(text: "\(base.precision)")
                        }
                        HStack {
                            CustomText(key: "stamina")
                            Spacer()
                            CustomText(text: "\(base.stamina)")
                        }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .frame(width: width)
    }
}

struct FighterView: View {
    var fighter: Fighter?
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(isSelected ? Color.blue : Color.purple)
            if fighter != nil {
                Image(fighter!.name).resizable().scaleEffect(6.4).aspectRatio(contentMode: .fit).offset(y: 95).clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                CustomText(text: "+")
            }
        }
        .frame(width: 70, height: 70).contentShape(Rectangle())
    }
}

struct CustomText: View {
    var text: String
    var lineLimit: Int?
    
    init(text: String) {
        self.text = text
    }
    
    init(key: String) {
        self.text = Localization.shared.getTranslation(key: key)
        self.lineLimit = 1
    }
    
    var body: some View {
        Text(text).lineLimit(lineLimit)
    }
}

struct EffectView: View {
    let effect: Effect
    let battling: Bool
    var weather: Bool = false
    
    @State var opacity: Double = 1
    
    func getColor() -> Color {
        if weather {
            return Color.yellow
        }
        
        if effect.positive {
            return Color.green
        } else {
            return Color.purple
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.red).frame(width: 30, height: 30)
            Group {
                Rectangle().fill(getColor()).frame(width: 30, height: 30)
                Text(effect.symbol).frame(width: 30, height: 30)
            }
            .opacity(opacity).animation(.linear(duration: 0.5).repeatForever(autoreverses: true), value: opacity)
        }
        .onChange(of: battling) { _ in
            if effect.duration == 1 {
                opacity = 0
            }
        }
    }
}

struct Views_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DetailedActionView(title: "Title", description: "Description")
            SimpleAttackView(title: "Title")
            RectangleFighterView(fighter: exampleFighter, isSelected: false).frame(width: 100)
            FighterView(fighter: exampleFighter, isSelected: false)
            BaseOverviewView(base: Base(health: 100, attack: 100, defense: 100, agility: 100, precision: 100, stamina: 100))
            EffectView(effect: Effect(name: "sample", symbol: "%", duration: 3, positive: true), battling: false)
        }
    }
}
