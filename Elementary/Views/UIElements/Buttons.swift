//
//  Buttons.swift
//  Elementary
//
//  Created by Janice Hablützel on 19.08.22.
//

import SwiftUI

struct BasicButton: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    
    let fontSize: CGFloat
    
    var isInverted: Bool = false
    
    var body: some View {
        ZStack(alignment: width > height ? .leading : .center) {
            Rectangle().fill(isInverted ? Color("Negative") : Color("MainPanel")).frame(width: width, height: height)
            CustomText(text: label.uppercased(), fontSize: fontSize, isBold: true).padding(.all, General.outerPadding)
        }
        .frame(width: width, height: height)
    }
}

struct BorderedButton: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    
    let isInverted: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(isInverted ? Color("Negative") : Color("MainPanel")).frame(width: width, height: height)
                .overlay(Rectangle().strokeBorder(isInverted ? Color.white : Color("Border"), lineWidth: General.borderWidth))
            CustomText(text: Localization.shared.getTranslation(key: label).uppercased(), fontSize: General.smallFont, isBold: true).padding(.all, General.outerPadding)
        }
        .frame(width: width, height: height)
    }
}

struct IconButton: View {
    let label: String
    
    var body: some View {
        ZStack {
            Rectangle().strokeBorder(Color.white, lineWidth: General.borderWidth).frame(width: General.smallHeight, height: General.smallHeight)
            Text(label).font(.custom("Font Awesome 5 Pro", size: General.mediumFont)).foregroundColor(Color.white).frame(width: General.smallHeight, height: General.smallHeight)
        }
        .frame(width: General.smallHeight, height: General.smallHeight)
    }
}

struct ClearButton: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            CustomText(text: label.uppercased(), fontSize: General.smallFont, isBold: true).frame(width: width, height: height, alignment: width > height ? .bottomLeading : .center)
        }
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BasicButton(label: "label", width: 150, height: General.largeHeight, fontSize: General.mediumFont)
            BorderedButton(label: "label", width: 150, height: General.largeHeight, isInverted: false)
            BorderedButton(label: "label", width: 150, height: General.largeHeight, isInverted: true)
            ClearButton(label: "<", width: General.smallHeight, height: General.smallHeight)
        }
    }
}
