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
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color("MainPanel"))
            VStack(spacing: 0) {
                ZStack {
                    Rectangle().fill(Color("Positive")).frame(width: geoWidth, height: geoWidth).padding(.bottom, outerPadding)
                    Text("\u{f890}").font(.custom("Font Awesome 5 Pro", size: 50)).foregroundColor(Color("Text"))
                }
                CustomText(text: Localization.shared.getTranslation(key: titleKey).uppercased(), fontSize: mediumFont, isBold: true)
                CustomText(text: TextFitter.getFittedText(text: Localization.shared.getTranslation(key: titleKey + "Descr"), geoWidth: geoWidth - 1.5 * innerPadding), fontSize: smallFont, alignment: HorizontalAlignment.center)
                Spacer()
            }
        }
        .frame(width: geoWidth).clipped()
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ModeView(titleKey: "tournament", geoWidth: 152)
    }
}
