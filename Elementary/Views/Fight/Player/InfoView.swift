//
//  InfoView.swift
//  Elementary
//
//  Created by Janice Hablützel on 25.08.22.
//

import SwiftUI

struct InfoView: View {
    let fightLogic: FightLogic
    let player: Player
    
    var body: some View {
        ScrollViewReader { value in
            VStack(spacing: General.innerPadding) {
                if fightLogic.singleMode {
                    ZStack {
                        Rectangle().fill(Color("MainPanel")) .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                        VStack(alignment: .leading, spacing: 2) {
                            CustomText(text: Localization.shared.getTranslation(key: player.getCurrentFighter().name).uppercased(), fontSize: General.mediumFont, isBold: true)
                            ForEach(player.getCurrentFighter().hexes, id: \.self) { hex in
                                HStack(spacing: 0) {
                                    if hex.symbol < 60000 {
                                        Text(General.createSymbol(int: hex.symbol)).font(.custom("Font Awesome 5 Free", size: General.smallFont)).foregroundColor(Color(hex.positive ? "Positive" : "Negative")).fixedSize().frame(width: 20, alignment: .leading)
                                    } else {
                                        Text(General.createSymbol(int: hex.symbol)).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color(hex.positive ? "Positive" : "Negative")).fixedSize().frame(width: 20, alignment: .leading)
                                    }
                                    CustomText(text: Localization.shared.getTranslation(key: hex.name + "Descr"), fontSize: General.smallFont)
                                    Spacer()
                                }
                            }
                            if player.getCurrentFighter().hexes.isEmpty {
                                HStack {
                                    CustomText(text: Localization.shared.getTranslation(key: "noHexes"), fontSize: General.smallFont)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.all, General.innerPadding)
                    }
                    .id(0)
                    ZStack {
                        Rectangle().fill(Color("MainPanel")) .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                        VStack(alignment: .leading, spacing: 2) {
                            CustomText(text: Localization.shared.getTranslation(key: fightLogic.players[player.getOppositePlayerId()].getCurrentFighter().name).uppercased(), fontSize: General.mediumFont, isBold: true)
                            ForEach(fightLogic.players[player.getOppositePlayerId()].getCurrentFighter().hexes, id: \.self) { hex in
                                HStack(spacing: 0) {
                                    Text(General.createSymbol(int: hex.symbol)).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color(hex.positive ? "Positive" : "Negative")).fixedSize().frame(width: 25)
                                    CustomText(text: Localization.shared.getTranslation(key: hex.name + "Descr"), fontSize: General.smallFont)
                                    Spacer()
                                }
                            }
                            if fightLogic.players[player.getOppositePlayerId()].getCurrentFighter().hexes.isEmpty {
                                HStack {
                                    CustomText(text: Localization.shared.getTranslation(key: "noHexes"), fontSize: General.smallFont)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.all, General.innerPadding)
                    }
                } else {
                    VStack(spacing: General.innerPadding/2) {
                        ForEach(player.fighters.indices, id: \.self) { index in
                            ZStack {
                                Rectangle().fill(Color("MainPanel")) .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                VStack(alignment: .leading, spacing: 2) {
                                    CustomText(text: Localization.shared.getTranslation(key: player.getFighter(index: index).name).uppercased(), fontSize: General.mediumFont, isBold: true)
                                    ForEach(player.getFighter(index: index).hexes, id: \.self) { hex in
                                        HStack(spacing: 0) {
                                            if hex.symbol < 60000 {
                                                Text(General.createSymbol(int: hex.symbol)).font(.custom("Font Awesome 5 Free", size: General.smallFont)).foregroundColor(Color(hex.positive ? "Positive" : "Negative")).fixedSize().frame(width: 20, alignment: .leading)
                                            } else {
                                                Text(General.createSymbol(int: hex.symbol)).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color(hex.positive ? "Positive" : "Negative")).fixedSize().frame(width: 20, alignment: .leading)
                                            }
                                            CustomText(text: Localization.shared.getTranslation(key: hex.name + "Descr"), fontSize: General.smallFont)
                                            Spacer()
                                        }
                                    }
                                    if player.getFighter(index: index).hexes.isEmpty {
                                        HStack {
                                            CustomText(text: Localization.shared.getTranslation(key: "noHexes"), fontSize: General.smallFont)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding(.all, General.innerPadding)
                            }
                            .id(index)
                        }
                    }
                    VStack(spacing: General.innerPadding/2) {
                        ForEach(fightLogic.players[player.getOppositePlayerId()].fighters.indices, id: \.self) { index in
                            ZStack {
                                Rectangle().fill(Color("MainPanel")) .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                                VStack(alignment: .leading, spacing: 2) {
                                    CustomText(text: Localization.shared.getTranslation(key: fightLogic.players[player.getOppositePlayerId()].getFighter(index: index).name).uppercased(), fontSize: General.mediumFont, isBold: true)
                                    ForEach(player.getFighter(index: index).hexes, id: \.self) { hex in
                                        HStack(spacing: 0) {
                                            if hex.symbol < 60000 {
                                                Text(General.createSymbol(int: hex.symbol)).font(.custom("Font Awesome 5 Free", size: General.smallFont)).foregroundColor(Color(hex.positive ? "Positive" : "Negative")).fixedSize().frame(width: 20, alignment: .leading)
                                            } else {
                                                Text(General.createSymbol(int: hex.symbol)).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color(hex.positive ? "Positive" : "Negative")).fixedSize().frame(width: 20, alignment: .leading)
                                            }
                                            CustomText(text: Localization.shared.getTranslation(key: hex.name + "Descr"), fontSize: General.smallFont)
                                            Spacer()
                                        }
                                    }
                                    if fightLogic.players[player.getOppositePlayerId()].getFighter(index: index).hexes.isEmpty {
                                        HStack {
                                            CustomText(text: Localization.shared.getTranslation(key: "noHexes"), fontSize: General.smallFont)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding(.all, General.innerPadding)
                            }
                        }
                    }
                }
                ZStack {
                    Rectangle().fill(Color("MainPanel")) .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: General.borderWidth))
                    VStack(alignment: .leading, spacing: 2) {
                        CustomText(text: Localization.shared.getTranslation(key: fightLogic.weather?.name ?? "clearSkies").uppercased(), fontSize: General.mediumFont, isBold: true)
                        HStack(spacing: 0) {
                            if let weather = fightLogic.weather {
                                Text(General.createSymbol(int: weather.symbol)).font(.custom("Font Awesome 5 Pro", size: General.smallFont)).foregroundColor(Color.white).fixedSize().frame(width: 25)
                                CustomText(text: Localization.shared.getTranslation(key: weather.name + "Descr"), fontSize: General.smallFont)
                            } else {
                                CustomText(text: Localization.shared.getTranslation(key: "noWeather"), fontSize: General.smallFont)
                            }
                            Spacer()
                        }
                    }
                    .padding(.all, General.innerPadding)
                }
            }
            .onAppear {
                value.scrollTo(0)
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(fightLogic: FightLogic(players: [Player(id: 0, fighters: [GlobalData.shared.fighters[0]]), Player(id: 1, fighters: [GlobalData.shared.fighters[0]])], hasCPUPlayer: false, singleMode: true), player: Player(id: 1, fighters: [GlobalData.shared.fighters[0]]))
    }
}
