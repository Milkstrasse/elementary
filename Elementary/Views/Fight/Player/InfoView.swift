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
    
    /// Converts a symbol to the correct display format.
    /// - Returns: Returns the symbol in the correct format
    func createSymbol(symbol: UInt16) -> String {
        return String(Character(UnicodeScalar(symbol) ?? "\u{2718}"))
    }
    
    var body: some View {
        ScrollViewReader { value in
            VStack(spacing: innerPadding) {
                ZStack {
                    Rectangle().fill(Color("MainPanel")) .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                    VStack(alignment: .leading, spacing: 2) {
                        CustomText(text: Localization.shared.getTranslation(key: player.getCurrentFighter().name).uppercased(), fontSize: mediumFont, isBold: true)
                        ForEach(player.getCurrentFighter().hexes, id: \.self) { hex in
                            HStack(spacing: 0) {
                                if hex.symbol < 60000 {
                                    Text(createSymbol(symbol: hex.symbol)).font(.custom("Font Awesome 5 Free", size: smallFont)).foregroundColor(Color(hex.positive ? "Positive" : "Negative")).fixedSize().frame(width: 20, alignment: .leading)
                                } else {
                                    Text(createSymbol(symbol: hex.symbol)).font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(Color(hex.positive ? "Positive" : "Negative")).fixedSize().frame(width: 20, alignment: .leading)
                                }
                                CustomText(text: Localization.shared.getTranslation(key: hex.name + "Descr"), fontSize: smallFont)
                                Spacer()
                            }
                        }
                        if player.getCurrentFighter().hexes.isEmpty {
                            HStack {
                                CustomText(text: Localization.shared.getTranslation(key: "noHexes"), fontSize: smallFont)
                                Spacer()
                            }
                        }
                    }
                    .padding(.all, innerPadding)
                }
                .id(0)
                ZStack {
                    Rectangle().fill(Color("MainPanel")) .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                    VStack(alignment: .leading, spacing: 2) {
                        CustomText(text: Localization.shared.getTranslation(key: fightLogic.players[player.id == 0 ? 1 : 0].getCurrentFighter().name).uppercased(), fontSize: mediumFont, isBold: true)
                        ForEach(fightLogic.players[player.id == 0 ? 1 : 0].getCurrentFighter().hexes, id: \.self) { hex in
                            HStack(spacing: 0) {
                                Text(createSymbol(symbol: hex.symbol)).font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(Color(hex.positive ? "Positive" : "Negative")).fixedSize().frame(width: 25)
                                CustomText(text: Localization.shared.getTranslation(key: hex.name + "Descr"), fontSize: smallFont)
                                Spacer()
                            }
                        }
                        if fightLogic.players[player.id == 0 ? 1 : 0].getCurrentFighter().hexes.isEmpty {
                            HStack {
                                CustomText(text: Localization.shared.getTranslation(key: "noHexes"), fontSize: smallFont)
                                Spacer()
                            }
                        }
                    }
                    .padding(.all, innerPadding)
                }
                ZStack {
                    Rectangle().fill(Color("MainPanel")) .overlay(Rectangle().strokeBorder(Color("Border"), lineWidth: borderWidth))
                    VStack(alignment: .leading, spacing: 2) {
                        CustomText(text: Localization.shared.getTranslation(key: fightLogic.weather?.name ?? "clearSkies").uppercased(), fontSize: mediumFont, isBold: true)
                        HStack(spacing: 0) {
                            if let weather = fightLogic.weather {
                                Text(createSymbol(symbol: weather.symbol)).font(.custom("Font Awesome 5 Pro", size: smallFont)).foregroundColor(Color.white).fixedSize().frame(width: 25)
                                CustomText(text: Localization.shared.getTranslation(key: weather.name + "Descr"), fontSize: smallFont)
                            } else {
                                CustomText(text: Localization.shared.getTranslation(key: "noWeather"), fontSize: smallFont)
                            }
                            Spacer()
                        }
                    }
                    .padding(.all, innerPadding)
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
        InfoView(fightLogic: FightLogic(players: [Player(id: 0, fighters: [GlobalData.shared.fighters[0]]), Player(id: 1, fighters: [GlobalData.shared.fighters[0]])]), player: Player(id: 1, fighters: [GlobalData.shared.fighters[0]]))
    }
}
