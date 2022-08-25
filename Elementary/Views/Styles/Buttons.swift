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
    
    var body: some View {
        ZStack(alignment: width > height ? .leading : .center) {
            Rectangle().fill(Color("Panel")).frame(width: width, height: height)
            CustomText(text: label.uppercased(), fontSize: fontSize, isBold: true).padding(.all, outerPadding)
        }
        .frame(width: width, height: height)
    }
}

struct IconButton: View {
    let label: String
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color("Background1")).frame(width: smallHeight, height: smallHeight)
                .overlay(Rectangle().strokeBorder(Color.white, lineWidth: borderWidth))
            Text(label).font(.custom("Font Awesome 5 Free", size: 14)).foregroundColor(Color.white).frame(width: smallHeight, height: smallHeight)
        }
        .frame(width: smallHeight, height: smallHeight)
    }
}

struct BorderedButton: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    
    let isInverted: Bool
    
    var body: some View {
        ZStack(alignment: width > height ? .leading : .center) {
            Rectangle().fill(isInverted ? Color("Background1") : Color("Panel")).frame(width: width, height: height)
                .overlay(Rectangle().strokeBorder(isInverted ? Color.white : Color("Border1"), lineWidth: borderWidth))
            CustomText(text: label.uppercased(), fontSize: 14, isBold: true).padding(.all, outerPadding)
        }
        .frame(width: width, height: height)
    }
}

struct ClearButton: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            CustomText(text: label.uppercased(), fontSize: 14, isBold: true).frame(width: width, height: height, alignment: width > height ? .bottomLeading : .center)
        }
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BasicButton(label: "label", width: 150, height: largeHeight, fontSize: 16)
            BorderedButton(label: "label", width: 150, height: largeHeight, isInverted: false)
            BorderedButton(label: "label", width: 150, height: largeHeight, isInverted: true)
            ClearButton(label: "<", width: smallHeight, height: smallHeight)
        }
    }
}
