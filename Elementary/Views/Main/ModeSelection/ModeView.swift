//
//  SwiftUIView.swift
//  Elementary
//
//  Created by Janice Hablützel on 09.11.22.
//

import SwiftUI

struct ModeView: View {
    let titleKey: String
    let geoWidth: CGFloat
    
    let icon: String
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color("MainPanel"))
            VStack(spacing: 0) {
                ZStack {
                    Rectangle().fill(Color("Positive")).frame(width: geoWidth, height: geoWidth)
                    Text(icon).font(.custom("Font Awesome 5 Pro", size: 50)).foregroundColor(Color("Text"))
                }
                Spacer()
                CustomText(text: Localization.shared.getTranslation(key: titleKey).uppercased(), fontSize: General.mediumFont, isBold: true)
                CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: titleKey + "Descr"), geoWidth: geoWidth - 1.5 * General.innerPadding), fontSize: General.smallFont, alignment: HorizontalAlignment.center)
                Spacer()
            }
        }
        .frame(width: geoWidth).clipped()
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ModeView(titleKey: "tournament", geoWidth: 152, icon: "\u{f890}")
    }
}
