//
//  OverviewView.swift
//  Magiko
//
//  Created by Janice Hablützel on 03.01.22.
//

import SwiftUI

struct OverviewView: View {
    @State var fighterSelected: Bool = false
    @State var infoToggle: Bool = false
    
    @Binding var currentFighter: String
    
    @Binding var overviewToggle: Bool
    @Binding var offsetX: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            if fighterSelected {
                HStack(alignment: .top) {
                    Button(infoToggle ? "X" : "?") {
                        infoToggle = !infoToggle
                    }
                    .buttonStyle(GrowingButton(width: 40))
                    Spacer()
                    ZStack {
                        Color.red
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Nickname")
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 5) {
                                    HStack(spacing: 5) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 75)
                                            HStack(spacing: 0) {
                                                VStack(spacing: 0) {
                                                    HStack {
                                                        Text("Stat")
                                                        Spacer()
                                                        Text("100")
                                                    }
                                                    HStack {
                                                        Text("Stat")
                                                        Spacer()
                                                        Text("100")
                                                    }
                                                    HStack {
                                                        Text("Stat")
                                                        Spacer()
                                                        Text("100")
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
                                                        Text("Stat")
                                                        Spacer()
                                                        Text("100")
                                                    }
                                                    HStack {
                                                        Text("Stat")
                                                        Spacer()
                                                        Text("100")
                                                    }
                                                    HStack {
                                                        Text("Stat")
                                                        Spacer()
                                                        Text("100")
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 15)
                                        }
                                    }
                                    .padding(.bottom, 5)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5).fill(Color.yellow)
                                        HStack(spacing: 0) {
                                            VStack(alignment: .leading) {
                                                Text("Attack")
                                                Text("Description")
                                            }
                                            .padding(.leading, 15)
                                            Spacer()
                                            Triangle().fill(Color.green).frame(width: 22)
                                            ZStack(alignment: .leading) {
                                                Rectangle().fill(Color.green).frame(width: 25)
                                                RoundedRectangle(cornerRadius: 5).fill(Color.green).frame(width: 55)
                                            }
                                        }
                                    }
                                    .frame(height: 60)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5).fill(Color.yellow)
                                        HStack(spacing: 0) {
                                            VStack(alignment: .leading) {
                                                Text("Attack")
                                                Text("Description")
                                            }
                                            .padding(.leading, 15)
                                            Spacer()
                                            Triangle().fill(Color.green).frame(width: 22)
                                            ZStack(alignment: .leading) {
                                                Rectangle().fill(Color.green).frame(width: 25)
                                                RoundedRectangle(cornerRadius: 5).fill(Color.green).frame(width: 55)
                                            }
                                        }
                                    }
                                    .frame(height: 60)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5).fill(Color.yellow)
                                        HStack(spacing: 0) {
                                            VStack(alignment: .leading) {
                                                Text("Attack")
                                                Text("Description")
                                            }
                                            .padding(.leading, 15)
                                            Spacer()
                                            Triangle().fill(Color.green).frame(width: 22)
                                            ZStack(alignment: .leading) {
                                                Rectangle().fill(Color.green).frame(width: 25)
                                                RoundedRectangle(cornerRadius: 5).fill(Color.green).frame(width: 55)
                                            }
                                        }
                                    }
                                    .frame(height: 60)
                                }
                            }
                        }
                    }
                    .frame(width: 345).offset(x: infoToggle ? 0 : 224).animation(.linear(duration: 0.2), value: infoToggle)
                }
                .padding(.all, 15)
            }
            ZStack(alignment: .trailing) {
                HStack(spacing: 0) {
                    Spacer()
                    Triangle().fill(Color.pink).frame(width: 134)
                    Rectangle().fill(Color.pink).frame(width: 315)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Overview").frame(height: 60).padding(.top, 15)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Button(action: {
                                    fighterSelected = true
                                    currentFighter = "magicalgirl_2"
                                }) {
                                    RectangleFighterView()
                                }
                                Button(action: {
                                    fighterSelected = true
                                    currentFighter = "magicalgirl_2"
                                }) {
                                    RectangleFighterView()
                                }
                                Button(action: {
                                    fighterSelected = true
                                    currentFighter = "magicalgirl_2"
                                }) {
                                    RectangleFighterView()
                                }
                            }
                            HStack(spacing: 8) {
                                Button(action: {
                                    fighterSelected = true
                                    currentFighter = "magicalgirl_2"
                                }) {
                                    RectangleFighterView()
                                }
                                Button(action: {
                                    fighterSelected = true
                                    currentFighter = "magicalgirl_2"
                                }) {
                                    RectangleFighterView()
                                }
                                Button(action: {
                                    fighterSelected = true
                                    currentFighter = "magicalgirl_2"
                                }) {
                                    RectangleFighterView()
                                }
                            }
                        }
                    }
                    Spacer().frame(height: 10)
                    HStack(spacing: 5) {
                        Spacer()
                        Button("<All Types>") {
                            print("Button pressed!")
                        }
                        .buttonStyle(GrowingButton(width: 160))
                        Button("X") {
                            offsetX = -449
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                overviewToggle = false
                            }
                        }
                        .buttonStyle(GrowingButton(width: 40))
                    }
                }
                .frame(width: 310).padding(.all, 15)
            }
            .padding(.trailing, offsetX).animation(.linear(duration: 0.2), value: offsetX).offset(x: infoToggle ? 449 : 0).animation(.linear(duration: 0.2), value: infoToggle)
        }
        .onAppear {
            offsetX = 0
        }
    }
}

struct RectangleFighterView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 5).fill(Color.yellow).frame(height: 125)
            Image("magicalgirl_2").resizable().scaleEffect(4.6).aspectRatio(contentMode: .fit).frame(height: 125).offset(y: 100).clipShape(RoundedRectangle(cornerRadius: 5))
            Triangle().fill(Color.green).frame(height: 35).padding(.bottom, 10)
            Rectangle().fill(Color.green).frame(height: 5).padding(.bottom, 5)
            RoundedRectangle(cornerRadius: 5).fill(Color.green).frame(height: 10)
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(currentFighter: Binding.constant("magicalgirl_1"), overviewToggle: Binding.constant(true), offsetX: Binding.constant(0))
.previewInterfaceOrientation(.landscapeLeft)
    }
}
