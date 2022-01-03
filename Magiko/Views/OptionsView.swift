//
//  OptionsView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct OptionsView: View {
    @Binding var optionsToggle: Bool
    @Binding var offsetX: CGFloat
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 0) {
                Spacer()
                Triangle().fill(Color.pink).frame(width: 134)
                Rectangle().fill(Color.pink).frame(width: 315)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("Options").frame(height: 60).padding(.top, 15)
                ScrollView {
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 40)
                            HStack {
                                Text("Option").frame(width: 100, alignment: .leading)
                                Text("<").frame(width: 40, height: 40)
                                Spacer()
                                Text("100%")
                                Spacer()
                                Text(">").frame(width: 40, height: 40)
                            }
                            .padding(.horizontal, 15)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 40)
                            HStack {
                                Text("Option").frame(width: 100, alignment: .leading)
                                Text("<").frame(width: 40, height: 40)
                                Spacer()
                                Text("100%")
                                Spacer()
                                Text(">").frame(width: 40, height: 40)
                            }
                            .padding(.horizontal, 15)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 40)
                            HStack {
                                Text("Option").frame(width: 100, alignment: .leading)
                                Text("<").frame(width: 40, height: 40)
                                Spacer()
                                Text("100%")
                                Spacer()
                                Text(">").frame(width: 40, height: 40)
                            }
                            .padding(.horizontal, 15)
                        }
                    }
                }
                Spacer().frame(height: 10)
                HStack(spacing: 5) {
                    Spacer()
                    Button("Restore Defaults") {
                        print("Button pressed!")
                    }
                    .buttonStyle(GrowingButton(width: 160))
                    Button("X") {
                        offsetX = -449
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            optionsToggle = false
                        }
                    }
                    .buttonStyle(GrowingButton(width: 40))
                }
            }
            .frame(width: 310).padding(.all, 15)
        }
        .padding(.trailing, offsetX).animation(.linear(duration: 0.2), value: offsetX)
        .onAppear {
            offsetX = 0
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView(optionsToggle: Binding.constant(true), offsetX: Binding.constant(0))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
