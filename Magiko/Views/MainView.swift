//
//  MainView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct MainView: View {
    @State var optionsToggle: Bool = false
    @State var infoToggle: Bool = false
    @State var creditsToggle: Bool = false
    
    @State var offsetX: CGFloat = -449
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Color.red
            Image("magicalgirl").resizable().scaleEffect(2.4).aspectRatio(contentMode: .fit).offset(x: -50, y: 170).padding(.trailing, offsetX < 0 ? 0 : 255).animation(.linear(duration: 0.2), value: offsetX)
            HStack(alignment: .top, spacing: 5) {
                HStack(spacing: 5) {
                    Button("Training") {
                        print("Button pressed!")
                    }
                    .buttonStyle(GrowingButton(width: 135))
                    Button("O") {
                        optionsToggle = true
                    }
                    .buttonStyle(GrowingButton(width: 40))
                    Button("T") {
                        infoToggle = true
                    }
                    .buttonStyle(GrowingButton(width: 40))
                    Button("C") {
                        creditsToggle = true
                    }
                    .buttonStyle(GrowingButton(width: 40))
                }
                .padding(.leading, offsetX < 0 ? 0 : -300).animation(.linear(duration: 0.2), value: offsetX)
                Spacer()
                VStack {
                    Spacer()
                    Button("Fight") {
                        print("Button pressed!")
                    }
                    .buttonStyle(GrowingButton(width: 190))
                }
            }
            .padding(.all, 15)
            if optionsToggle {
                OptionsView(optionsToggle: $optionsToggle, offsetX: $offsetX)
            } else if infoToggle {
                InfoView(infoToggle: $infoToggle, offsetX: $offsetX)
            } else if creditsToggle {
                CreditsView(creditsToggle: $creditsToggle, offsetX: $offsetX)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
.previewInterfaceOrientation(.landscapeRight)
    }
}
