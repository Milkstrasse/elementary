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
            CustomText(text: label.uppercased(), fontSize: fontSize, isBold: true).padding(.all, outerPadding)
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
                .overlay(Rectangle().strokeBorder(isInverted ? Color.white : Color("Border"), lineWidth: borderWidth))
            CustomText(text: Localization.shared.getTranslation(key: label).uppercased(), fontSize: smallFont, isBold: true).padding(.all, outerPadding)
        }
        .frame(width: width, height: height)
    }
}

struct IconButton: View {
    let label: String
    
    var body: some View {
        ZStack {
            Rectangle().strokeBorder(Color.white, lineWidth: borderWidth).frame(width: smallHeight, height: smallHeight)
            Text(label).font(.custom("Font Awesome 5 Pro", size: mediumFont)).foregroundColor(Color.white).frame(width: smallHeight, height: smallHeight)
        }
        .frame(width: smallHeight, height: smallHeight)
    }
}

struct ClearButton: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            CustomText(text: label.uppercased(), fontSize: smallFont, isBold: true).frame(width: width, height: height, alignment: width > height ? .bottomLeading : .center)
        }
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BasicButton(label: "label", width: 150, height: largeHeight, fontSize: mediumFont)
            BorderedButton(label: "label", width: 150, height: largeHeight, isInverted: false)
            BorderedButton(label: "label", width: 150, height: largeHeight, isInverted: true)
            ClearButton(label: "<", width: smallHeight, height: smallHeight)
        }
    }
}
